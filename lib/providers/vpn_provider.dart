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

  VpnStatus get status => _status;
  List<VlessServer> get servers => _servers;
  bool get isLoading => _isLoading;
  String? get error => _error;

  VpnProvider() {
    _vpnService.statusStream.listen((status) {
      _status = status;
      notifyListeners();
    });
    loadServers();
  }

  Future<void> loadServers() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _servers = await _apiService.getServers();
      _error = null;
      debugPrint('Loaded ${_servers.length} servers');
    } catch (e) {
      _error = 'Failed to load servers: ${e.toString()}';
      debugPrint('Error loading servers: $_error');
      // Если серверы не загрузились, оставляем пустой список
      // но не показываем критическую ошибку, так как есть fallback
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

  @override
  void dispose() {
    _vpnService.dispose();
    super.dispose();
  }
}

