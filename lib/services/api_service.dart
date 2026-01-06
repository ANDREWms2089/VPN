import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/vless_server.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  // Автоматическое определение URL бэкенда в зависимости от платформы
  static String get baseUrl {
    // Для Android эмулятора используем специальный IP
    if (!kIsWeb && Platform.isAndroid) {
      // Android эмулятор использует 10.0.2.2 для доступа к localhost хоста
      return 'http://10.0.2.2:3000/api';
    }
    // Для iOS симулятора и десктопа - localhost
    // В production замените на реальный URL вашего сервера
    // Например: 'https://your-backend-api.com/api'
    return 'http://localhost:3000/api';
  }
  
  // Использовать реальный API вместо моковых данных
  // Установите false для подключения к реальному бэкенду
  static const bool useMockData = false;

  Future<List<VlessServer>> getServers() async {
    try {
      if (useMockData) {
        // Временные тестовые данные
        await Future.delayed(const Duration(seconds: 1));
        return _getMockServers();
      }

      // Пытаемся подключиться к бэкенду с таймаутом
      final response = await http.get(
        Uri.parse('$baseUrl/servers'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(
        const Duration(seconds: 5),
        onTimeout: () {
          throw Exception('Backend connection timeout. Please make sure the backend is running on $baseUrl');
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        // Поддержка нового формата ответа с оберткой
        if (data is Map && data.containsKey('servers')) {
          final List<dynamic> serversList = data['servers'] as List;
          return serversList.map((json) => VlessServer.fromJson(json)).toList();
        } else if (data is List) {
          // Старый формат (просто массив)
          return data.map((json) => VlessServer.fromJson(json)).toList();
        } else {
          throw Exception('Invalid response format');
        }
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['error'] ?? 'Failed to load servers: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('API Error: $e');
      
      // Автоматический fallback на моковые данные, если бэкенд недоступен
      if (!useMockData) {
        final errorMessage = e.toString().toLowerCase();
        if (errorMessage.contains('connection refused') || 
            errorMessage.contains('connection timeout') ||
            errorMessage.contains('failed host lookup') ||
            errorMessage.contains('network is unreachable')) {
          debugPrint('Backend is not available. Using mock data as fallback.');
          debugPrint('To use real backend, make sure it\'s running on $baseUrl');
          // Возвращаем моковые данные вместо ошибки
          return _getMockServers();
        }
        // Для других ошибок пробрасываем исключение
        throw Exception('Failed to load servers: $e');
      }
      // Если useMockData = true, используем моковые данные
      return _getMockServers();
    }
  }

  Future<int> pingServer(VlessServer server) async {
    try {
      if (useMockData) {
        // Симуляция ping
        await Future.delayed(const Duration(milliseconds: 500));
        return server.ping;
      }

      final response = await http.get(
        Uri.parse('$baseUrl/servers/${server.id}/ping'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data is Map && data.containsKey('ping')) {
          return data['ping'] as int;
        }
      }
      return server.ping;
    } catch (e) {
      // Игнорируем ошибки ping
      return server.ping;
    }
  }

  List<VlessServer> _getMockServers() {
    return [
      // Реальный сервер из Нидерландов (Reality)
      VlessServer(
        id: 'nl-reality-1',
        name: 'Нидерланды 10Гбит/с',
        address: '10.nl.vpnpplvpn.top',
        port: 443,
        uuid: '58a6ce24-fe00-4a0e-8c69-a3381f5a5da1',
        flow: 'xtls-rprx-vision',
        encryption: 'none',
        network: 'tcp',
        security: 'reality',
        sni: null,
        path: null,
        host: null,
        mode: null,
        realityServerName: 'vpnforppl.top',
        realityShortId: '4cd45277ddedbf1f',
        realityPublicKey: 'XWP3eu958tmcTzF5TvelcQMxfKd632VaNlG6nrqHwRU',
        realityFingerprint: 'chrome',
        realitySpiderX: '',
        country: 'Netherlands',
        flag: '🇳🇱',
        ping: 35,
        isTest: false,
      ),
      // Реальный сервер из России (Reality)
      VlessServer(
        id: 'ru-reality-1',
        name: 'Россия (31210_25141)',
        address: 'ru.node.vpnpplvpn.top',
        port: 443,
        uuid: '58a6ce24-fe00-4a0e-8c69-a3381f5a5da1',
        flow: 'xtls-rprx-vision',
        encryption: 'none',
        network: 'tcp',
        security: 'reality',
        sni: null,
        path: null,
        host: null,
        mode: null,
        realityServerName: 'ru.vpnforppl.top',
        realityShortId: '1e943a831d22faf6',
        realityPublicKey: 'V79PDGag0UzOlSyK7Pa2t7YJeSRJhCN78P9vewwlznU',
        realityFingerprint: 'chrome',
        realitySpiderX: '',
        country: 'Russia',
        flag: '🇷🇺',
        ping: 20,
        isTest: false,
      ),
      // Реальный сервер из Санкт-Петербурга
      VlessServer(
        id: 'spb-1',
        name: 'Россия, Санкт-Петербург',
        address: '212.233.98.231',
        port: 443,
        uuid: '7eb12e3a-6515-4e02-8c8a-c6d2af91b31d',
        flow: null,
        encryption: 'none',
        network: 'xhttp',
        security: 'none',
        sni: null,
        path: '/',
        host: '',
        mode: 'auto',
        realityServerName: null,
        realityShortId: null,
        realityPublicKey: null,
        realityFingerprint: null,
        realitySpiderX: null,
        country: 'Russia',
        flag: '🇷🇺',
        ping: 25,
        isTest: false,
      ),
      // Тестовые серверы (для демонстрации)
      VlessServer(
        id: 'test-1',
        name: 'Netherlands #1 (Тест)',
        address: 'nl1.example.com',
        port: 443,
        uuid: '12345678-1234-1234-1234-123456789abc',
        flow: 'xtls-rprx-vision',
        encryption: 'none',
        network: 'tcp',
        security: 'tls',
        sni: 'nl1.example.com',
        path: null,
        host: null,
        mode: null,
        realityServerName: null,
        realityShortId: null,
        realityPublicKey: null,
        realityFingerprint: null,
        realitySpiderX: null,
        country: 'Netherlands',
        flag: '🇳🇱',
        ping: 45,
        isTest: true,
      ),
      VlessServer(
        id: 'test-2',
        name: 'United States #1 (Тест)',
        address: 'us1.example.com',
        port: 443,
        uuid: '12345678-1234-1234-1234-123456789abd',
        flow: 'xtls-rprx-vision',
        encryption: 'none',
        network: 'tcp',
        security: 'tls',
        sni: 'us1.example.com',
        path: null,
        host: null,
        mode: null,
        realityServerName: null,
        realityShortId: null,
        realityPublicKey: null,
        realityFingerprint: null,
        realitySpiderX: null,
        country: 'United States',
        flag: '🇺🇸',
        ping: 120,
        isTest: true,
      ),
      VlessServer(
        id: 'test-3',
        name: 'Germany #1 (Тест)',
        address: 'de1.example.com',
        port: 443,
        uuid: '12345678-1234-1234-1234-123456789abe',
        flow: 'xtls-rprx-vision',
        encryption: 'none',
        network: 'tcp',
        security: 'tls',
        sni: 'de1.example.com',
        path: null,
        host: null,
        mode: null,
        realityServerName: null,
        realityShortId: null,
        realityPublicKey: null,
        realityFingerprint: null,
        realitySpiderX: null,
        country: 'Germany',
        flag: '🇩🇪',
        ping: 65,
        isTest: true,
      ),
      VlessServer(
        id: 'test-4',
        name: 'Japan #1 (Тест)',
        address: 'jp1.example.com',
        port: 443,
        uuid: '12345678-1234-1234-1234-123456789abf',
        flow: 'xtls-rprx-vision',
        encryption: 'none',
        network: 'tcp',
        security: 'tls',
        sni: 'jp1.example.com',
        path: null,
        host: null,
        mode: null,
        realityServerName: null,
        realityShortId: null,
        realityPublicKey: null,
        realityFingerprint: null,
        realitySpiderX: null,
        country: 'Japan',
        flag: '🇯🇵',
        ping: 180,
        isTest: true,
      ),
    ];
  }
}

