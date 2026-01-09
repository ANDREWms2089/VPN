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
      // Для VPN режима inbounds не нужны - flutter_v2ray_plus создает VPN интерфейс автоматически
      'inbounds': [],
      'outbounds': [
        _generateOutbound(server),
        {
          'protocol': 'freedom',
          'tag': 'direct',
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
                // flow добавляем только если он указан (не null и не пустой)
                if (server.flow != null && server.flow!.isNotEmpty)
                  'flow': server.flow!,
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

      if (server.security == 'reality') {
        // Reality настройки
        final realitySettings = <String, dynamic>{};
        if (server.realityServerName != null && server.realityServerName!.isNotEmpty) {
          realitySettings['serverName'] = server.realityServerName;
        }
        if (server.realityFingerprint != null && server.realityFingerprint!.isNotEmpty) {
          realitySettings['fingerprint'] = server.realityFingerprint;
        }
        if (server.realityPublicKey != null && server.realityPublicKey!.isNotEmpty) {
          realitySettings['publicKey'] = server.realityPublicKey;
        }
        if (server.realityShortId != null && server.realityShortId!.isNotEmpty) {
          realitySettings['shortId'] = server.realityShortId;
        }
        if (server.realitySpiderX != null && server.realitySpiderX!.isNotEmpty) {
          realitySettings['spiderX'] = server.realitySpiderX;
        }
        if (realitySettings.isNotEmpty) {
          streamSettings['realitySettings'] = realitySettings;
        }
      } else if (server.security == 'tls') {
        // TLS настройки
        final tlsConfig = <String, dynamic>{
          'allowInsecure': false,
        };
        // serverName для TLS (используем sni или address как fallback)
        if (server.sni != null && server.sni!.isNotEmpty) {
          tlsConfig['serverName'] = server.sni;
        } else if (server.address.isNotEmpty) {
          tlsConfig['serverName'] = server.address;
        }
        streamSettings['tlsSettings'] = tlsConfig;
      }
    }

    // Настройки транспорта по типу сети
    switch (network) {
      case 'ws':
        final wsHeaders = <String, String>{};
        // Для WebSocket Host должен быть в заголовках, если указан
        if (server.host != null && server.host!.isNotEmpty) {
          wsHeaders['Host'] = server.host!;
        } else if (server.address.isNotEmpty) {
          // Если host не указан, используем address как fallback
          wsHeaders['Host'] = server.address;
        }
        streamSettings['wsSettings'] = {
          'path': server.path ?? '/',
          if (wsHeaders.isNotEmpty) 'headers': wsHeaders,
        };
        break;
      case 'grpc':
        streamSettings['grpcSettings'] = {
          'serviceName': server.path ?? '',
          'multiMode': server.mode == 'multi',
        };
        break;
      case 'http':
      case 'xhttp':
        streamSettings['httpSettings'] = {
          'path': server.path ?? '/',
          'host': (server.host?.isNotEmpty == true) 
              ? server.host!.split(',').map((h) => h.trim()).where((h) => h.isNotEmpty).toList()
              : [],
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
                  if (server.host != null && server.host!.isNotEmpty) 'Host': [server.host!],
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
        // Только приватные IP идут напрямую (локальная сеть)
        {
          'type': 'field',
          'ip': ['geoip:private'],
          'outboundTag': 'direct',
        },
        // Весь остальной трафик идет через VPN (proxy - первый outbound)
        // Явное правило не требуется, так как proxy используется по умолчанию
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
