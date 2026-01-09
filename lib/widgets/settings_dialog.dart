import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../theme/app_colors.dart';
import '../models/vless_server.dart';
import '../providers/vpn_provider.dart';

class SettingsDialog extends StatefulWidget {
  const SettingsDialog({super.key});

  @override
  State<SettingsDialog> createState() => _SettingsDialogState();
}

class _SettingsDialogState extends State<SettingsDialog> {
  final TextEditingController _vlessController = TextEditingController();
  bool _isValidating = false;
  String? _errorMessage;
  String? _successMessage;
  Map<String, dynamic>? _parsedConfig;

  @override
  void dispose() {
    _vlessController.dispose();
    super.dispose();
  }

  String _getCountryFlag(String address) {
    // Простая логика определения страны по домену
    if (address.contains('.ru') || address.contains('ru.')) {
      return '🇷🇺';
    } else if (address.contains('.nl') || address.contains('nl.')) {
      return '🇳🇱';
    } else if (address.contains('.us') || address.contains('us.')) {
      return '🇺🇸';
    } else if (address.contains('.de') || address.contains('de.')) {
      return '🇩🇪';
    } else if (address.contains('.uk') || address.contains('uk.')) {
      return '🇬🇧';
    } else if (address.contains('.jp') || address.contains('jp.')) {
      return '🇯🇵';
    } else if (address.contains('.cn') || address.contains('cn.')) {
      return '🇨🇳';
    }
    return '🌐';
  }

  String _getCountryName(String address) {
    if (address.contains('.ru') || address.contains('ru.')) {
      return 'Russia';
    } else if (address.contains('.nl') || address.contains('nl.')) {
      return 'Netherlands';
    } else if (address.contains('.us') || address.contains('us.')) {
      return 'United States';
    } else if (address.contains('.de') || address.contains('de.')) {
      return 'Germany';
    } else if (address.contains('.uk') || address.contains('uk.')) {
      return 'United Kingdom';
    } else if (address.contains('.jp') || address.contains('jp.')) {
      return 'Japan';
    } else if (address.contains('.cn') || address.contains('cn.')) {
      return 'China';
    }
    return 'Unknown';
  }

  Future<void> _addConfiguration() async {
    final url = _vlessController.text.trim();
    
    if (url.isEmpty) {
      setState(() {
        _errorMessage = 'Пожалуйста, введите VLESS ссылку';
        _successMessage = null;
        _parsedConfig = null;
      });
      return;
    }

    setState(() {
      _isValidating = true;
      _errorMessage = null;
      _successMessage = null;
      _parsedConfig = null;
    });

    try {
      // Парсим VLESS URL вручную
      if (!url.startsWith('vless://')) {
        throw Exception('Неверный формат VLESS URL. Должен начинаться с vless://');
      }

      // Извлекаем UUID из URL (обычно это часть между vless:// и @)
      String uuid = '';
      String address = '';
      int port = 443;
      String? remark;
      
      try {
        // Формат: vless://uuid@address:port?params#remark
        final uri = Uri.parse(url);
        
        // UUID из userInfo
        uuid = uri.userInfo;
        if (uuid.isEmpty) {
          // Пытаемся извлечь из строки напрямую
          final match = RegExp(r'vless://([^@]+)@').firstMatch(url);
          if (match != null) {
            uuid = match.group(1) ?? '';
          }
        }
        
        // Адрес и порт
        address = uri.host;
        port = uri.port;
        if (port == 0) port = 443;
        
        // Замечание (remark) из fragment
        remark = uri.fragment.isNotEmpty ? Uri.decodeComponent(uri.fragment) : null;
        
        // Проверка валидности UUID
        if (uuid.isEmpty || uuid.length < 8) {
          throw Exception('Неверный UUID в VLESS URL');
        }
        
        // Проверка адреса
        if (address.isEmpty) {
          throw Exception('Неверный адрес сервера');
        }
      } catch (e) {
        throw Exception('Ошибка парсинга URL: ${e.toString()}');
      }

      // Извлекаем дополнительные параметры из query string
      String? path, host, sni, flow, encryption, mode, security, network;
      try {
        final uri = Uri.parse(url);
        path = uri.queryParameters['path'];
        host = uri.queryParameters['host'];
        sni = uri.queryParameters['sni'];
        flow = uri.queryParameters['flow'];
        encryption = uri.queryParameters['encryption'];
        mode = uri.queryParameters['mode'];
        security = uri.queryParameters['security'];
        network = uri.queryParameters['type'] ?? uri.queryParameters['network'];
      } catch (e) {
        // Игнорируем ошибки парсинга query параметров
      }

      // Создаем VlessServer из распарсенных данных
      // Используем префикс 'custom-' для идентификации пользовательских серверов
      final server = VlessServer(
        id: 'custom-${const Uuid().v4()}',
        name: remark ?? 'Custom Server',
        address: address,
        port: port,
        uuid: uuid,
        flow: flow,
        encryption: encryption,
        network: network ?? 'tcp',
        security: security ?? 'none',
        sni: sni,
        path: path,
        host: host,
        mode: mode,
        country: _getCountryName(address),
        flag: _getCountryFlag(address),
        isTest: false,
        ping: 0,
        isActive: false,
      );

      // Добавляем сервер в список через Provider
      final vpnProvider = Provider.of<VpnProvider>(context, listen: false);
      vpnProvider.addServer(server);

      setState(() {
        _parsedConfig = {
          'Адрес': address,
          'Порт': port.toString(),
          'UUID': uuid.substring(0, 8) + '...',
          'Имя': remark ?? 'Custom Server',
          'Сеть': network ?? 'tcp',
          'Безопасность': security ?? 'none',
        };
        _successMessage = 'Конфигурация успешно добавлена!\nСервер появится в списке.';
        _errorMessage = null;
      });

      // Закрываем диалог через 2 секунды после успешного добавления
      Future.delayed(const Duration(milliseconds: 2000), () {
        if (mounted) {
          Navigator.of(context).pop();
        }
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Ошибка валидации: ${e.toString()}';
        _successMessage = null;
        _parsedConfig = null;
      });
    } finally {
      setState(() {
        _isValidating = false;
      });
    }
  }

  void _clearFields() {
    _vlessController.clear();
    setState(() {
      _errorMessage = null;
      _successMessage = null;
      _parsedConfig = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: AppColors.cardGradient,
          borderRadius: BorderRadius.circular(20),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Заголовок
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Настройки',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Sansation',
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.darkOrange,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    color: AppColors.darkOrange,
                    onPressed: () => Navigator.of(context).pop(),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              
              // Поле ввода VLESS ссылки
              Text(
                'VLESS Ссылка',
                textAlign: TextAlign.left,
                style: TextStyle(
                  fontFamily: 'Sansation',
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.darkOrange,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _vlessController,
                decoration: InputDecoration(
                  hintText: 'vless://...',
                  hintStyle: TextStyle(
                    fontFamily: 'Sansation',
                    color: Colors.grey.shade400,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: AppColors.primaryOrange),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: AppColors.primaryOrange.withValues(alpha: 0.5)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.primaryOrange, width: 2),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                style: const TextStyle(
                  fontFamily: 'Sansation',
                  fontSize: 14,
                ),
                maxLines: 3,
                minLines: 1,
              ),
              const SizedBox(height: 16),
              
              // Кнопка добавления конфигурации
              ElevatedButton(
                onPressed: _isValidating ? null : _addConfiguration,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryOrange,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isValidating
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Text(
                        'Добавить конфигурацию',
                        style: TextStyle(
                          fontFamily: 'Sansation',
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
              const SizedBox(height: 16),
              
              // Сообщение об ошибке
              if (_errorMessage != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.error_outline, color: Colors.red.shade700, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: TextStyle(
                            fontFamily: 'Sansation',
                            fontSize: 14,
                            color: Colors.red.shade700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              
              // Сообщение об успехе
              if (_successMessage != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.green.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.check_circle_outline, color: Colors.green.shade700, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _successMessage!,
                          style: TextStyle(
                            fontFamily: 'Sansation',
                            fontSize: 14,
                            color: Colors.green.shade700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              
              // Информация о распарсенной конфигурации
              if (_parsedConfig != null) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.paleOrange,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Информация о конфигурации:',
                        style: TextStyle(
                          fontFamily: 'Sansation',
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.darkOrange,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ..._parsedConfig!.entries.map((entry) => Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Text(
                          '${entry.key}: ${entry.value}',
                          style: const TextStyle(
                            fontFamily: 'Sansation',
                            fontSize: 12,
                            color: Colors.black87,
                          ),
                        ),
                      )),
                    ],
                  ),
                ),
              ],
              
              const SizedBox(height: 16),
              
              // Кнопка очистки
              TextButton(
                onPressed: _clearFields,
                child: Text(
                  'Очистить',
                  style: TextStyle(
                    fontFamily: 'Sansation',
                    fontSize: 14,
                    color: AppColors.darkOrange,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

