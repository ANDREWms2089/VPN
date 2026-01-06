import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import '../models/vless_server.dart';
import '../models/vpn_status.dart';

class VpnService {
  static final VpnService _instance = VpnService._internal();
  factory VpnService() => _instance;
  VpnService._internal();

  // MethodChannel для связи с нативным кодом
  static const MethodChannel _channel = MethodChannel('vpn_service');
  
  final StreamController<VpnStatus> _statusController =
      StreamController<VpnStatus>.broadcast();
  
  VpnStatus _currentStatus = VpnStatus(status: VpnConnectionStatus.disconnected);
  Timer? _connectionTimer;
  Timer? _speedTimer;

  Stream<VpnStatus> get statusStream => _statusController.stream;
  VpnStatus get currentStatus => _currentStatus;

  /// Проверка разрешения на использование VPN
  /// В Android требуется явное разрешение пользователя
  Future<bool> requestVpnPermission() async {
    try {
      final result = await _channel.invokeMethod<bool>('requestVpnPermission');
      return result ?? false;
    } catch (e) {
      debugPrint('Error requesting VPN permission: $e');
      // В режиме симуляции возвращаем true
      return true;
    }
  }

  /// Подключение к VPN серверу
  Future<void> connect(VlessServer server) async {
    if (_currentStatus.isConnecting || _currentStatus.isConnected) {
      return;
    }

    // Проверяем разрешение на VPN
    final hasPermission = await requestVpnPermission();
    if (!hasPermission) {
      _updateStatus(VpnStatus(
        status: VpnConnectionStatus.error,
        currentServer: server,
        errorMessage: 'VPN permission denied',
      ));
      return;
    }

    _updateStatus(VpnStatus(
      status: VpnConnectionStatus.connecting,
      currentServer: server,
    ));

    try {
      // Генерируем VLESS URL для передачи в нативный код
      final vlessUrl = server.toVlessUrl();
      debugPrint('Connecting to VPN: $vlessUrl');

      // В реальном приложении здесь будет вызов нативного VPN API
      // Для Android: используйте VpnService API
      // Для iOS: используйте Network Extension API
      // Для VLESS протокола требуется интеграция с v2ray/xray core
      
      // TODO: Интегрировать v2ray/xray core для реального VPN подключения
      // Пример для Android:
      // final result = await _channel.invokeMethod('connectVpn', {
      //   'vlessUrl': vlessUrl,
      //   'serverConfig': server.toJson(),
      // });
      
      // Временная симуляция (удалите после интеграции реального VPN)
      await Future.delayed(const Duration(seconds: 2));

      _updateStatus(VpnStatus(
        status: VpnConnectionStatus.connected,
        currentServer: server,
        connectedAt: DateTime.now(),
      ));

      _startSpeedMonitoring();
    } catch (e) {
      _updateStatus(VpnStatus(
        status: VpnConnectionStatus.error,
        currentServer: server,
        errorMessage: e.toString(),
      ));
    }
  }

  /// Отключение от VPN
  Future<void> disconnect() async {
    if (_currentStatus.isDisconnected) {
      return;
    }

    _updateStatus(VpnStatus(
      status: VpnConnectionStatus.disconnecting,
      currentServer: _currentStatus.currentServer,
    ));

    try {
      // В реальном приложении здесь будет вызов нативного VPN API
      // await _channel.invokeMethod('disconnectVpn');
      
      // Временная симуляция (удалите после интеграции реального VPN)
      await Future.delayed(const Duration(seconds: 1));

      _stopSpeedMonitoring();

      _updateStatus(VpnStatus(
        status: VpnConnectionStatus.disconnected,
      ));
    } catch (e) {
      _updateStatus(VpnStatus(
        status: VpnConnectionStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  void _updateStatus(VpnStatus status) {
    _currentStatus = status;
    _statusController.add(status);
  }

  void _startSpeedMonitoring() {
    _speedTimer?.cancel();
    _speedTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_currentStatus.isConnected) {
        // Симуляция скорости (в реальном приложении получать от VPN API)
        final uploadSpeed = (1000 + (timer.tick * 50)) % 10000;
        final downloadSpeed = (5000 + (timer.tick * 100)) % 50000;

        _updateStatus(_currentStatus.copyWith(
          uploadSpeed: uploadSpeed,
          downloadSpeed: downloadSpeed,
        ));
      } else {
        timer.cancel();
      }
    });
  }

  void _stopSpeedMonitoring() {
    _speedTimer?.cancel();
  }

  void dispose() {
    _connectionTimer?.cancel();
    _speedTimer?.cancel();
    _statusController.close();
  }
}

