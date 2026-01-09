import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_v2ray_plus/flutter_v2ray.dart';
import 'package:flutter_v2ray_plus/model/vless_status.dart';
import '../models/vless_server.dart';
import '../models/vpn_status.dart';
import 'config_generator.dart';

// Проверка платформы
bool get _isAndroid => defaultTargetPlatform == TargetPlatform.android;
bool get _isIOS => defaultTargetPlatform == TargetPlatform.iOS;
bool get _isMobile => _isAndroid || _isIOS;

/// VPN Service с реальным подключением через flutter_v2ray_plus
class VpnService {
  static final VpnService _instance = VpnService._internal();
  factory VpnService() => _instance;
  VpnService._internal();

  FlutterV2ray? _flutterV2ray;
  bool _isInitialized = false;
  static const MethodChannel _channel = MethodChannel(
    'com.example.vpn_front/vpn',
  );

  final StreamController<VpnStatus> _statusController =
      StreamController<VpnStatus>.broadcast();

  VpnStatus _currentStatus = VpnStatus(
    status: VpnConnectionStatus.disconnected,
  );
  Timer? _speedTimer;
  StreamSubscription? _statusSubscription;
  DateTime? _lastSpeedLogTime;

  Stream<VpnStatus> get statusStream => _statusController.stream;
  VpnStatus get currentStatus => _currentStatus;

  /// Инициализация VPN сервиса
  Future<void> initialize() async {
    if (_isInitialized) return;

    // VPN работает только на мобильных платформах
    if (!_isMobile) {
      debugPrint(
        'VPN is not supported on this platform (${defaultTargetPlatform})',
      );
      _updateStatus(
        VpnStatus(
          status: VpnConnectionStatus.error,
          errorMessage: 'VPN is not supported on this platform',
        ),
      );
      return;
    }

    try {
      _flutterV2ray = FlutterV2ray();
      await _flutterV2ray!.initializeVless(
        notificationIconResourceType: "mipmap",
        notificationIconResourceName: "ic_launcher",
      );

      // Подписываемся на изменения статуса с сохранением подписки
      _statusSubscription?.cancel();
      _statusSubscription = _flutterV2ray!.onStatusChanged.listen(
        (status) {
          _handleV2RayStatusChanged(status);
        },
        onError: (error) {
          debugPrint('V2Ray status stream error: $error');
        },
      );

      _isInitialized = true;
    } catch (e) {
      debugPrint('VPN init error: $e');
      _updateStatus(
        VpnStatus(
          status: VpnConnectionStatus.error,
          errorMessage: 'Failed to initialize VPN Service: $e',
        ),
      );
    }
  }

  /// Обработка изменений статуса от V2Ray
  void _handleV2RayStatusChanged(dynamic status) {
    // flutter_v2ray_plus возвращает VlessStatus объект
    if (status is! VlessStatus) {
      debugPrint(
        'V2Ray status is not VlessStatus: ${status.runtimeType} - $status',
      );
      return;
    }

    final vlessStatus = status;
    final state = vlessStatus.state.toUpperCase();

    // Логируем только изменения статуса
    final currentStateStr = _currentStatus.status
        .toString()
        .split('.')
        .last
        .toUpperCase();
    if (state != currentStateStr) {
      debugPrint('VPN: $currentStateStr → $state');
    }

    VpnConnectionStatus vpnStatus;

    switch (state) {
      case 'CONNECTING':
        vpnStatus = VpnConnectionStatus.connecting;
        _updateStatus(
          VpnStatus(
            status: vpnStatus,
            currentServer: _currentStatus.currentServer,
          ),
        );
        break;

      case 'CONNECTED':
        vpnStatus = VpnConnectionStatus.connected;
        // Обновляем скорость при каждом обновлении статуса CONNECTED
        final connectedAt = _currentStatus.isConnected
            ? _currentStatus.connectedAt
            : DateTime.now();

        // Получаем скорость из VlessStatus (обновляется библиотекой автоматически)
        final uploadSpeed = vlessStatus.uploadSpeed;
        final downloadSpeed = vlessStatus.downloadSpeed;

        // Диагностика: логируем все данные из VlessStatus
        debugPrint(
          'VlessStatus: uploadSpeed=$uploadSpeed, downloadSpeed=$downloadSpeed, upload=${vlessStatus.upload}, download=${vlessStatus.download}, duration=${vlessStatus.duration}',
        );

        // Логируем скорость периодически (каждые 3 секунды)
        final now = DateTime.now();
        final lastLog = _lastSpeedLogTime;
        if (lastLog == null || now.difference(lastLog).inSeconds >= 3) {
          debugPrint(
            'VPN speed: ↑ ${_formatBytes(uploadSpeed)}/s ↓ ${_formatBytes(downloadSpeed)}/s',
          );
          _lastSpeedLogTime = now;
        }

        _updateStatus(
          _currentStatus.copyWith(
            status: vpnStatus,
            connectedAt: connectedAt ?? DateTime.now(),
            uploadSpeed: uploadSpeed,
            downloadSpeed: downloadSpeed,
          ),
        );
        _startSpeedMonitoring();
        break;

      case 'DISCONNECTING':
        vpnStatus = VpnConnectionStatus.disconnecting;
        _updateStatus(
          VpnStatus(
            status: vpnStatus,
            currentServer: _currentStatus.currentServer,
          ),
        );
        break;

      case 'DISCONNECTED':
        vpnStatus = VpnConnectionStatus.disconnected;
        _stopSpeedMonitoring();

        // Сохраняем информацию о текущем статусе до обновления
        final wasConnected = _currentStatus.isConnected;
        final wasConnecting = _currentStatus.isConnecting;
        final currentServer = _currentStatus.currentServer;
        final connectedAt = _currentStatus.connectedAt;

        // Диагностика: почему произошло отключение
        if (wasConnected) {
          final connectedDuration = connectedAt != null
              ? DateTime.now().difference(connectedAt)
              : null;

          final duration = connectedDuration?.inSeconds ?? 0;
          debugPrint(
            'VPN disconnected after ${duration}s: ${currentServer?.name ?? "unknown"}',
          );

          _updateStatus(
            VpnStatus(
              status: vpnStatus,
              currentServer: null,
              errorMessage: 'Connection lost after $duration seconds',
            ),
          );
        } else if (wasConnecting) {
          debugPrint(
            'VPN connection failed: ${currentServer?.name ?? "unknown"}',
          );
          _updateStatus(VpnStatus(status: vpnStatus, currentServer: null));
        } else {
          _updateStatus(VpnStatus(status: vpnStatus, currentServer: null));
        }
        break;

      default:
        debugPrint('Unknown V2Ray status: $state');
        // Пытаемся определить статус по содержимому
        if (state.contains('ERROR') || state.contains('FAILED')) {
          vpnStatus = VpnConnectionStatus.error;
          _stopSpeedMonitoring();
          _updateStatus(
            VpnStatus(
              status: vpnStatus,
              currentServer: _currentStatus.currentServer,
              errorMessage: 'Connection error: $state',
            ),
          );
        }
        break;
    }
  }

  /// Проверка разрешения на использование VPN
  Future<bool> requestVpnPermission() async {
    if (!_isInitialized) {
      await initialize();
    }

    try {
      if (_flutterV2ray == null) {
        return false;
      }

      // Запрашиваем разрешение через нативный код
      return await _requestVpnPermissionNative();
    } catch (e) {
      debugPrint('Error requesting VPN permission: $e');
      return false;
    }
  }

  /// Запрос VPN разрешения через нативный код (Android)
  Future<bool> _requestVpnPermissionNative() async {
    if (!_isAndroid) {
      return true; // На iOS VPN разрешения обрабатываются по-другому
    }

    try {
      final result = await _channel.invokeMethod<bool>('requestVpnPermission');
      return result ?? false;
    } catch (e) {
      debugPrint('Error in _requestVpnPermissionNative: $e');
      // Если метод не реализован, возвращаем true и полагаемся на библиотеку
      return true;
    }
  }

  /// Подключение к VPN серверу
  Future<void> connect(VlessServer server) async {
    if (_currentStatus.isConnecting || _currentStatus.isConnected) {
      debugPrint('VPN is already connecting or connected');
      return;
    }

    // Инициализируем если еще не инициализировано
    if (!_isInitialized) {
      await initialize();
    }

    if (_flutterV2ray == null) {
      _updateStatus(
        VpnStatus(
          status: VpnConnectionStatus.error,
          currentServer: server,
          errorMessage: 'VPN Service not initialized',
        ),
      );
      return;
    }

    _updateStatus(
      VpnStatus(status: VpnConnectionStatus.connecting, currentServer: server),
    );

    try {
      final configJson = ConfigGenerator.toJsonString(server);

      if (_flutterV2ray == null) {
        throw Exception('FlutterV2ray is not initialized');
      }

      if (_isAndroid) {
        try {
          await _requestVpnPermissionNative();
        } catch (e) {
          // Продолжаем попытку подключения
        }
      }

      await _flutterV2ray!.startVless(
        remark: server.name,
        config: configJson,
        proxyOnly: false,
        bypassSubnets: null,
        dnsServers: ['8.8.8.8', '8.8.4.4', '1.1.1.1'],
        showNotificationDisconnectButton: true,
        notificationDisconnectButtonName: "DISCONNECT",
      );
    } catch (e) {
      debugPrint('VPN connection error: $e');
      _updateStatus(
        VpnStatus(
          status: VpnConnectionStatus.error,
          currentServer: server,
          errorMessage: 'Connection failed: ${e.toString()}',
        ),
      );
    }
  }

  /// Отключение от VPN
  Future<void> disconnect() async {
    if (_currentStatus.isDisconnected) return;

    if (_flutterV2ray == null) {
      _updateStatus(VpnStatus(status: VpnConnectionStatus.disconnected));
      return;
    }

    _updateStatus(
      VpnStatus(
        status: VpnConnectionStatus.disconnecting,
        currentServer: _currentStatus.currentServer,
      ),
    );

    try {
      await _flutterV2ray!.stopVless();
    } catch (e) {
      debugPrint('VPN disconnect error: $e');
      // Даже при ошибке отключения сбрасываем статус
      _stopSpeedMonitoring();
      _updateStatus(VpnStatus(status: VpnConnectionStatus.disconnected));
    }
  }

  void _updateStatus(VpnStatus status) {
    _currentStatus = status;
    _statusController.add(status);
  }

  void _startSpeedMonitoring() {
    _speedTimer?.cancel();
    if (!_currentStatus.isConnected) return;

    // Скорость обновляется автоматически через onStatusChanged
    // Таймер не нужен, так как библиотека сама отправляет обновления
  }

  void _stopSpeedMonitoring() {
    _speedTimer?.cancel();
    _speedTimer = null;
  }

  String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  void dispose() {
    _speedTimer?.cancel();
    _speedTimer = null;
    _statusSubscription?.cancel();
    _statusSubscription = null;
    _statusController.close();
    _flutterV2ray = null;
    _isInitialized = false;
  }
}
