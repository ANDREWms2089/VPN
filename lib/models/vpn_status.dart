import 'vless_server.dart';

enum VpnConnectionStatus {
  disconnected,
  connecting,
  connected,
  disconnecting,
  error,
}

class VpnStatus {
  final VpnConnectionStatus status;
  final VlessServer? currentServer;
  final String? errorMessage;
  final DateTime? connectedAt;
  final int? uploadSpeed;
  final int? downloadSpeed;

  VpnStatus({
    required this.status,
    this.currentServer,
    this.errorMessage,
    this.connectedAt,
    this.uploadSpeed,
    this.downloadSpeed,
  });

  VpnStatus copyWith({
    VpnConnectionStatus? status,
    VlessServer? currentServer,
    String? errorMessage,
    DateTime? connectedAt,
    int? uploadSpeed,
    int? downloadSpeed,
  }) {
    return VpnStatus(
      status: status ?? this.status,
      currentServer: currentServer ?? this.currentServer,
      errorMessage: errorMessage ?? this.errorMessage,
      connectedAt: connectedAt ?? this.connectedAt,
      uploadSpeed: uploadSpeed ?? this.uploadSpeed,
      downloadSpeed: downloadSpeed ?? this.downloadSpeed,
    );
  }

  bool get isConnected => status == VpnConnectionStatus.connected;
  bool get isConnecting => status == VpnConnectionStatus.connecting;
  bool get isDisconnected => status == VpnConnectionStatus.disconnected;
}

