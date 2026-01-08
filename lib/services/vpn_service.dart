import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_v2ray/flutter_v2ray.dart';
import '../models/vless_server.dart';
import '../models/vpn_status.dart';
import 'config_generator.dart';

/// VPN Service с использованием flutter_v2ray пакета
/// Обеспечивает реальное VPN подключение через v2ray/xray core
class VpnService {
  static final VpnService _instance = VpnService._internal();
  factory VpnService() => _instance;
  VpnService._internal();

  FlutterV2ray? _flutterV2ray;
  bool _isInitialized = false;
  
  final StreamController<VpnStatus> _statusController =
      StreamController<VpnStatus>.broadcast();
  
  VpnStatus _currentStatus = VpnStatus(status: VpnConnectionStatus.disconnected);
  Timer? _speedTimer;

  Stream<VpnStatus> get statusStream => _statusController.stream;
  VpnStatus get currentStatus => _currentStatus;

  /// Инициализация V2Ray (вызывается один раз при запуске приложения)
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      _flutterV2ray = FlutterV2ray(
        onStatusChanged: _handleV2RayStatusChanged,
      );

      // Инициализация V2Ray
      await _flutterV2ray!.initializeV2Ray(
        notificationIconResourceType: "mipmap",
        notificationIconResourceName: "ic_launcher",
      );

      _isInitialized = true;
      debugPrint('V2Ray initialized successfully');
    } catch (e) {
      debugPrint('Error initializing V2Ray: $e');
      _updateStatus(VpnStatus(
        status: VpnConnectionStatus.error,
        errorMessage: 'Failed to initialize V2Ray: $e',
      ));
    }
  }

  /// Обработка изменений статуса от V2Ray
  void _handleV2RayStatusChanged(V2RayStatus v2rayStatus) {
    debugPrint('V2Ray status changed: ${v2rayStatus.state}');
    
    VpnConnectionStatus vpnStatus;
    final state = v2rayStatus.state.toUpperCase();
    
    switch (state) {
      case 'CONNECTING':
        vpnStatus = VpnConnectionStatus.connecting;
        break;
      case 'CONNECTED':
        vpnStatus = VpnConnectionStatus.connected;
        if (_currentStatus.currentServer != null) {
          _updateStatus(_currentStatus.copyWith(
            status: vpnStatus,
            connectedAt: DateTime.now(),
            uploadSpeed: v2rayStatus.uploadSpeed,
            downloadSpeed: v2rayStatus.downloadSpeed,
          ));
          _startSpeedMonitoring();
        }
        break;
      case 'DISCONNECTING':
        vpnStatus = VpnConnectionStatus.disconnecting;
        break;
      case 'DISCONNECTED':
        vpnStatus = VpnConnectionStatus.disconnected;
        _stopSpeedMonitoring();
        _updateStatus(VpnStatus(
          status: vpnStatus,
          currentServer: null,
        ));
        break;
      case 'FAILED':
        vpnStatus = VpnConnectionStatus.error;
        _stopSpeedMonitoring();
        _updateStatus(VpnStatus(
          status: vpnStatus,
          currentServer: _currentStatus.currentServer,
          errorMessage: 'Connection failed',
        ));
        break;
      default:
        debugPrint('Unknown V2Ray status: $state');
        return;
    }
    
    // Обновляем статус если он изменился
    if (_currentStatus.status != vpnStatus) {
      _updateStatus(VpnStatus(
        status: vpnStatus,
        currentServer: _currentStatus.currentServer,
      ));
    }
  }

  /// Проверка разрешения на использование VPN
  /// В Android требуется явное разрешение пользователя
  Future<bool> requestVpnPermission() async {
    if (_flutterV2ray == null) {
      await initialize();
    }

    try {
      final hasPermission = await _flutterV2ray!.requestPermission();
      return hasPermission;
    } catch (e) {
      debugPrint('Error requesting VPN permission: $e');
      return false;
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

    // Проверяем разрешение на VPN
    final hasPermission = await requestVpnPermission();
    if (!hasPermission) {
      _updateStatus(VpnStatus(
        status: VpnConnectionStatus.error,
        currentServer: server,
        errorMessage: 'VPN permission denied. Please grant VPN permission in system settings.',
      ));
      return;
    }

    _updateStatus(VpnStatus(
      status: VpnConnectionStatus.connecting,
      currentServer: server,
    ));

    try {
      // Генерируем config.json для v2ray/xray
      final configJson = ConfigGenerator.toJsonString(server);
      debugPrint('Connecting to VPN server: ${server.name}');
      debugPrint('Generated config: $configJson');

      // Запускаем V2Ray с конфигурацией
      await _flutterV2ray!.startV2Ray(
        remark: server.name,
        config: configJson,
        blockedApps: null, // Можно указать приложения для исключения
        bypassSubnets: ['0.0.0.0/0'], // Маршрутизировать весь трафик
        proxyOnly: false, // Использовать VPN туннель, а не только прокси
        notificationDisconnectButtonName: "DISCONNECT",
      );

      // Статус будет обновлен через callback _handleV2RayStatusChanged
      debugPrint('V2Ray start command sent');
    } catch (e) {
      debugPrint('VPN connection error: $e');
      _updateStatus(VpnStatus(
        status: VpnConnectionStatus.error,
        currentServer: server,
        errorMessage: 'Connection failed: ${e.toString()}',
      ));
    }
  }

  /// Отключение от VPN
  Future<void> disconnect() async {
    if (_currentStatus.isDisconnected) {
      return;
    }

    if (_flutterV2ray == null) {
      _updateStatus(VpnStatus(
        status: VpnConnectionStatus.disconnected,
      ));
      return;
    }

    _updateStatus(VpnStatus(
      status: VpnConnectionStatus.disconnecting,
      currentServer: _currentStatus.currentServer,
    ));

    try {
      // Останавливаем V2Ray
      await _flutterV2ray!.stopV2Ray();
      
      // Статус будет обновлен через callback
      debugPrint('V2Ray stop command sent');
    } catch (e) {
      debugPrint('VPN disconnection error: $e');
      // Даже при ошибке отключения сбрасываем статус
      _stopSpeedMonitoring();
      _updateStatus(VpnStatus(
        status: VpnConnectionStatus.disconnected,
      ));
    }
  }

  void _updateStatus(VpnStatus status) {
    _currentStatus = status;
    _statusController.add(status);
  }

  void _startSpeedMonitoring() {
    _speedTimer?.cancel();
    // Статистика скорости обновляется автоматически через callback _handleV2RayStatusChanged
    // Таймер не нужен, так как V2Ray сам отправляет обновления статуса со статистикой
    // Но оставляем для совместимости на случай, если callback не вызывается регулярно
    _speedTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      if (!_currentStatus.isConnected) {
        timer.cancel();
      }
      // Статистика обновляется через callback, здесь просто проверяем подключение
    });
  }

  void _stopSpeedMonitoring() {
    _speedTimer?.cancel();
  }

  void dispose() {
    _speedTimer?.cancel();
    _statusController.close();
    _flutterV2ray = null;
    _isInitialized = false;
  }
}
