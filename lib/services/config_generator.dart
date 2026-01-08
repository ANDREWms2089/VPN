import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../models/vless_server.dart';

/// Генератор конфигурации v2ray/xray в формате JSON
/// Создает config.json для работы с VLESS протоколом
class ConfigGenerator {
  /// Генерирует полную конфигурацию v2ray/xray из VlessServer
  static Map<String, dynamic> generateConfig(VlessServer server) {
    // Базовая структура конфигурации
    final config = <String, dynamic>{
      'log': {
        'loglevel': 'warning',
      },
      'inbounds': _generateInbounds(),
      'outbounds': [
        _generateOutbound(server),
        {
          'protocol': 'freedom',
          'tag': 'direct',
          'settings': {},
        },
        {
          'protocol': 'blackhole',
          'tag': 'blocked',
          'settings': {},
        },
      ],
      'routing': _generateRouting(),
      'dns': {
        'servers': [
          '8.8.8.8',
          '8.8.4.4',
          '1.1.1.1',
        ],
      },
    };

    return config;
  }

  /// Генерирует inbound конфигурацию (локальный SOCKS/HTTP прокси)
  static List<Map<String, dynamic>> _generateInbounds() {
    return [
      {
        'port': 10808,
        'protocol': 'socks',
        'settings': {
          'auth': 'noauth',
          'udp': true,
        },
        'tag': 'socks',
      },
      {
        'port': 10809,
        'protocol': 'http',
        'settings': {},
        'tag': 'http',
      },
    ];
  }

  /// Генерирует outbound конфигурацию для VLESS сервера
  static Map<String, dynamic> _generateOutbound(VlessServer server) {
    final outbound = <String, dynamic>{
      'protocol': 'vless',
      'settings': {
        'vnext': [
          {
            'address': server.address,
            'port': server.port,
            'users': [
              {
                'id': server.uuid,
                'encryption': server.encryption ?? 'none',
                'flow': server.flow,
              }
            ],
          }
        ],
      },
      'streamSettings': _generateStreamSettings(server),
      'tag': 'proxy',
    };

    return outbound;
  }

  /// Генерирует streamSettings для транспорта (TCP/WS/GRPC/etc)
  static Map<String, dynamic> _generateStreamSettings(VlessServer server) {
    final network = server.network?.toLowerCase() ?? 'tcp';
    final streamSettings = <String, dynamic>{
      'network': network,
    };

    // Настройки безопасности (TLS/Reality)
    if (server.security != null && server.security != 'none') {
      streamSettings['security'] = server.security;

      final tlsSettings = <String, dynamic>{};

      if (server.security == 'reality') {
        // Reality настройки
        if (server.realityServerName != null) {
          tlsSettings['serverName'] = server.realityServerName;
        }
        if (server.realityFingerprint != null) {
          tlsSettings['fingerprint'] = server.realityFingerprint;
        }
        if (server.realityPublicKey != null) {
          tlsSettings['publicKey'] = server.realityPublicKey;
        }
        if (server.realityShortId != null) {
          tlsSettings['shortId'] = server.realityShortId;
        }
        if (server.realitySpiderX != null) {
          tlsSettings['spiderX'] = server.realitySpiderX;
        }
        streamSettings['realitySettings'] = tlsSettings;
      } else if (server.security == 'tls') {
        // TLS настройки
        if (server.sni != null && server.sni!.isNotEmpty) {
          tlsSettings['serverName'] = server.sni;
        }
        tlsSettings['allowInsecure'] = false;
        streamSettings['tlsSettings'] = tlsSettings;
      }

      if (tlsSettings.isNotEmpty && server.security != 'reality') {
        streamSettings['${server.security}Settings'] = tlsSettings;
      }
    }

    // Настройки транспорта по типу сети
    switch (network) {
      case 'ws':
        streamSettings['wsSettings'] = {
          'path': server.path ?? '/',
          'headers': {
            if (server.host != null) 'Host': server.host!,
          },
        };
        break;
      case 'grpc':
        streamSettings['grpcSettings'] = {
          'serviceName': server.path ?? '',
          'multiMode': server.mode == 'multi',
        };
        break;
      case 'http':
        streamSettings['httpSettings'] = {
          'path': server.path ?? '/',
          'host': server.host?.split(',') ?? [],
        };
        break;
      case 'tcp':
      default:
        if (server.host != null || server.path != null) {
          streamSettings['tcpSettings'] = {
            'header': {
              'type': 'http',
              'request': {
                'version': '1.1',
                'method': 'GET',
                'path': [server.path ?? '/'],
                'headers': {
                  if (server.host != null) 'Host': [server.host!],
                  'User-Agent': [
                    'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
                  ],
                  'Accept-Encoding': ['gzip, deflate'],
                  'Connection': ['keep-alive'],
                  'Pragma': 'no-cache',
                },
              },
            },
          };
        }
        break;
    }

    return streamSettings;
  }

  /// Генерирует routing правила
  static Map<String, dynamic> _generateRouting() {
    return {
      'domainStrategy': 'IPIfNonMatch',
      'rules': [
        {
          'type': 'field',
          'ip': ['geoip:private'],
          'outboundTag': 'direct',
        },
        {
          'type': 'field',
          'protocol': ['bittorrent'],
          'outboundTag': 'blocked',
        },
        {
          'type': 'field',
          'domain': ['geosite:category-ads-all'],
          'outboundTag': 'blocked',
        },
      ],
    };
  }

  /// Конвертирует конфигурацию в JSON строку
  static String toJsonString(VlessServer server, {bool pretty = false}) {
    final config = generateConfig(server);
    if (pretty) {
      const encoder = JsonEncoder.withIndent('  ');
      return encoder.convert(config);
    }
    return jsonEncode(config);
  }

  /// Сохраняет конфигурацию в файл (для отладки)
  static Future<void> saveToFile(VlessServer server, String filePath) async {
    final configJson = toJsonString(server, pretty: true);
    // В реальном приложении можно использовать dart:io
    // await File(filePath).writeAsString(configJson);
    debugPrint('Config saved to: $filePath\n$configJson');
  }
}
