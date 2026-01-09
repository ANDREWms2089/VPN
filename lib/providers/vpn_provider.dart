import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/vless_server.dart';
import '../models/vpn_status.dart';
import '../services/vpn_service.dart';
import '../services/api_service.dart';

class VpnProvider with ChangeNotifier {
  final VpnService _vpnService = VpnService();
  final ApiService _apiService = ApiService();

  VpnStatus _status = VpnStatus(status: VpnConnectionStatus.disconnected);
  List<VlessServer> _servers = [];
  bool _isLoading = false;
  String? _error;
  StreamSubscription<VpnStatus>? _statusSubscription;

  VpnStatus get status => _status;
  List<VlessServer> get servers => _servers;
  bool get isLoading => _isLoading;
  String? get error => _error;

  VpnProvider() {
    _statusSubscription = _vpnService.statusStream.listen(
      (status) {
        _status = status;
        notifyListeners();
      },
      onError: (error) {
        debugPrint('VPN status stream error: $error');
      },
    );
    _initializeVpnService();
    loadServers();
  }

  Future<void> _initializeVpnService() async {
    try {
      await _vpnService.initialize();
      debugPrint('VPN Service initialized');
    } catch (e) {
      debugPrint('Error initializing VPN Service: $e');
    }
  }

  Future<void> loadServers() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final loadedServers = await _apiService.getServers();
      // Сохраняем пользовательские серверы (добавленные вручную)
      final userServers = _servers.where((s) => s.id.startsWith('custom-') || !loadedServers.any((ls) => ls.id == s.id)).toList();
      // Объединяем загруженные серверы с пользовательскими
      _servers = [...loadedServers, ...userServers];
      _error = null;
      debugPrint('Loaded ${loadedServers.length} servers from API, ${userServers.length} custom servers');
    } catch (e) {
      _error = 'Failed to load servers: ${e.toString()}';
      debugPrint('Error loading servers: $_error');
      // Если серверы не загрузились, оставляем существующий список (включая пользовательские)
      if (_servers.isEmpty) {
        _error = 'Unable to connect to backend. Using default servers.';
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> connect(VlessServer server) async {
    try {
      await _vpnService.connect(server);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> disconnect() async {
    try {
      await _vpnService.disconnect();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> pingServer(VlessServer server) async {
    await _apiService.pingServer(server);
    // Обновить ping в списке серверов
    final index = _servers.indexWhere((s) => s.id == server.id);
    if (index != -1) {
      // В реальном приложении здесь будет обновление ping
      notifyListeners();
    }
  }

  void addServer(VlessServer server) {
    // Проверяем, нет ли уже сервера с таким же адресом и портом
    final exists = _servers.any((s) => 
      s.address == server.address && s.port == server.port && s.uuid == server.uuid
    );
    
    if (!exists) {
      _servers.add(server);
      notifyListeners();
      debugPrint('Server added: ${server.name}');
    } else {
      debugPrint('Server already exists: ${server.name}');
    }
  }

  @override
  void dispose() {
    _statusSubscription?.cancel();
    _statusSubscription = null;
    _vpnService.dispose();
    super.dispose();
  }
}

