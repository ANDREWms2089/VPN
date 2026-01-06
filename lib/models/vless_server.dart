class VlessServer {
  final String id;
  final String name;
  final String address;
  final int port;
  final String uuid;
  final String? flow;
  final String? encryption;
  final String? network;
  final String? security;
  final String? sni;
  final String? path;
  final String? host;
  final String? mode;
  // Reality параметры
  final String? realityServerName; // serverName для Reality
  final String? realityShortId; // shortId для Reality
  final String? realityPublicKey; // publicKey для Reality
  final String? realityFingerprint; // fingerprint для Reality
  final String? realitySpiderX; // spiderX для Reality
  final String country;
  final String flag;
  final bool isTest; // Флаг для тестовых серверов
  final int ping;
  final bool isActive;

  VlessServer({
    required this.id,
    required this.name,
    required this.address,
    required this.port,
    required this.uuid,
    this.flow,
    this.encryption,
    this.network,
    this.security,
    this.sni,
    this.path,
    this.host,
    this.mode,
    this.realityServerName,
    this.realityShortId,
    this.realityPublicKey,
    this.realityFingerprint,
    this.realitySpiderX,
    required this.country,
    required this.flag,
    this.ping = 0,
    this.isActive = false,
    this.isTest = false,
  });

  factory VlessServer.fromJson(Map<String, dynamic> json) {
    return VlessServer(
      id: json['id'] as String,
      name: json['name'] as String,
      address: json['address'] as String,
      port: json['port'] as int,
      uuid: json['uuid'] as String,
      flow: json['flow'] as String?,
      encryption: json['encryption'] as String?,
      network: json['network'] as String? ?? 'tcp',
      security: json['security'] as String? ?? 'none',
      sni: json['sni'] as String?,
      path: json['path'] as String?,
      host: json['host'] as String?,
      mode: json['mode'] as String?,
      realityServerName: json['realityServerName'] as String?,
      realityShortId: json['realityShortId'] as String?,
      realityPublicKey: json['realityPublicKey'] as String?,
      realityFingerprint: json['realityFingerprint'] as String?,
      realitySpiderX: json['realitySpiderX'] as String?,
      country: json['country'] as String,
      flag: json['flag'] as String,
      ping: json['ping'] as int? ?? 0,
      isActive: json['isActive'] as bool? ?? false,
      isTest: json['isTest'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'port': port,
      'uuid': uuid,
      'flow': flow,
      'encryption': encryption,
      'network': network,
      'security': security,
      'sni': sni,
      'path': path,
      'host': host,
      'mode': mode,
      'realityServerName': realityServerName,
      'realityShortId': realityShortId,
      'realityPublicKey': realityPublicKey,
      'realityFingerprint': realityFingerprint,
      'realitySpiderX': realitySpiderX,
      'country': country,
      'flag': flag,
      'ping': ping,
      'isActive': isActive,
      'isTest': isTest,
    };
  }

  // Генерация VLESS URL
  String toVlessUrl() {
    final params = <String>[];
    if (network != null && network!.isNotEmpty) {
      params.add('type=${Uri.encodeComponent(network!)}');
    }
    if (encryption != null && encryption!.isNotEmpty) {
      params.add('encryption=${Uri.encodeComponent(encryption!)}');
    }
    if (path != null && path!.isNotEmpty) {
      params.add('path=${Uri.encodeComponent(path!)}');
    }
    if (host != null && host!.isNotEmpty) {
      params.add('host=${Uri.encodeComponent(host!)}');
    }
    if (mode != null && mode!.isNotEmpty) {
      params.add('mode=${Uri.encodeComponent(mode!)}');
    }
    if (security != null && security!.isNotEmpty) {
      params.add('security=${Uri.encodeComponent(security!)}');
    }
    if (flow != null && flow!.isNotEmpty) {
      params.add('flow=${Uri.encodeComponent(flow!)}');
    }
    if (sni != null && sni!.isNotEmpty) {
      params.add('sni=${Uri.encodeComponent(sni!)}');
    }
    // Reality параметры
    if (realityFingerprint != null && realityFingerprint!.isNotEmpty) {
      params.add('fp=${Uri.encodeComponent(realityFingerprint!)}');
    }
    if (realityPublicKey != null && realityPublicKey!.isNotEmpty) {
      params.add('pbk=${Uri.encodeComponent(realityPublicKey!)}');
    }
    if (realityShortId != null && realityShortId!.isNotEmpty) {
      params.add('sid=${Uri.encodeComponent(realityShortId!)}');
    }
    if (realitySpiderX != null && realitySpiderX!.isNotEmpty) {
      params.add('spx=${Uri.encodeComponent(realitySpiderX!)}');
    }
    // Для Reality serverName используется как sni
    if (realityServerName != null && realityServerName!.isNotEmpty) {
      if (sni == null || sni!.isEmpty) {
        params.add('sni=${Uri.encodeComponent(realityServerName!)}');
      }
    }

    final query = params.isEmpty ? '' : '?${params.join('&')}';
    return 'vless://$uuid@$address:$port$query#${Uri.encodeComponent(name)}';
  }
}

