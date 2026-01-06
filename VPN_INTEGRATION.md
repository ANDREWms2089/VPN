# Интеграция реального VPN подключения

## Текущее состояние

Сейчас приложение использует **симуляцию VPN подключения**. Для реального VPN подключения требуется интеграция с нативными VPN API и v2ray/xray core.

## Что нужно для реального VPN

### 1. Android

#### Разрешения (уже добавлены в AndroidManifest.xml):
- `BIND_VPN_SERVICE` - для создания VPN сервиса
- `FOREGROUND_SERVICE` - для работы VPN в фоне
- `WAKE_LOCK` - для поддержания соединения

#### Необходимые шаги:

1. **Создать VpnService класс** в Kotlin/Java:
   ```kotlin
   // android/app/src/main/kotlin/com/example/vpn_front/VpnService.kt
   package com.example.vpn_front
   
   import android.net.VpnService
   import android.os.ParcelFileDescriptor
   import io.flutter.plugin.common.MethodChannel
   
   class MyVpnService : VpnService() {
       private var vpnInterface: ParcelFileDescriptor? = null
       
       fun startVpn(config: String) {
           val builder = Builder()
           builder.setSession("VPN Secure")
           builder.addAddress("10.0.0.2", 30)
           builder.addDnsServer("8.8.8.8")
           builder.addRoute("0.0.0.0", 0)
           vpnInterface = builder.establish()
       }
   }
   ```

2. **Интегрировать v2ray/xray core**:
   - Добавить v2ray/xray библиотеку в `android/app/build.gradle.kts`
   - Использовать v2ray/xray для обработки VLESS протокола
   - Настроить туннель через VpnService

3. **Создать MethodChannel** для связи Flutter <-> Native:
   ```kotlin
   // В MainActivity.kt
   private val CHANNEL = "vpn_service"
   
   override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
       MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
           .setMethodCallHandler { call, result ->
               when (call.method) {
                   "requestVpnPermission" -> {
                       val intent = VpnService.prepare(this)
                       if (intent != null) {
                           startActivityForResult(intent, 0)
                       } else {
                           result.success(true)
                       }
                   }
                   "connectVpn" -> {
                       // Запустить VPN с v2ray/xray
                       result.success(true)
                   }
                   "disconnectVpn" -> {
                       // Остановить VPN
                       result.success(true)
                   }
               }
           }
   }
   ```

### 2. iOS

#### Разрешения (уже добавлены в Info.plist):
- Network Extensions entitlement
- App Transport Security настройки

#### Необходимые шаги:

1. **Создать Network Extension**:
   - Packet Tunnel Provider для VPN
   - App Proxy Provider для прокси

2. **Добавить Entitlements**:
   ```xml
   <!-- ios/Runner/Runner.entitlements -->
   <key>com.apple.developer.networking.networkextension</key>
   <array>
       <string>app-proxy-provider</string>
       <string>packet-tunnel-provider</string>
   </array>
   ```

3. **Интегрировать v2ray/xray core**:
   - Добавить v2ray/xray framework
   - Настроить через Network Extension

### 3. VLESS протокол

VLESS требует специальной обработки через v2ray/xray:

1. **Парсинг VLESS URL** (уже реализовано в `VlessServer.toVlessUrl()`)
2. **Конвертация в v2ray конфигурацию**:
   ```dart
   Map<String, dynamic> toV2rayConfig(VlessServer server) {
     return {
       "outbounds": [{
         "protocol": "vless",
         "settings": {
           "vnext": [{
             "address": server.address,
             "port": server.port,
             "users": [{
               "id": server.uuid,
               "encryption": server.encryption ?? "none",
               "flow": server.flow,
             }]
           }]
         },
         "streamSettings": {
           "network": server.network ?? "tcp",
           "security": server.security ?? "none",
           // Reality настройки
           if (server.security == "reality") {
             "realitySettings": {
               "serverName": server.realityServerName,
               "shortId": server.realityShortId,
               "publicKey": server.realityPublicKey,
               "fingerprint": server.realityFingerprint,
             }
           }
         }
       }]
     };
   }
   ```

3. **Передача конфигурации в v2ray/xray core**

## Рекомендуемые библиотеки

### Для v2ray/xray интеграции:

1. **v2ray-core** (Go) - можно использовать через FFI
2. **xray-core** (Go) - форк v2ray с дополнительными функциями
3. **v2rayNG** (Android) - готовое Android приложение, можно использовать как библиотеку

### Альтернативные подходы:

1. **Flutter VPN плагины** (ограниченная поддержка VLESS):
   - `flutter_vpn` - базовая VPN функциональность
   - Требуется доработка для VLESS

2. **Собственная реализация**:
   - Использовать VpnService (Android) / Network Extension (iOS)
   - Интегрировать v2ray/xray через FFI или нативный код

## Текущая реализация

Сейчас `VpnService.connect()` использует симуляцию:
- Задержка 2 секунды
- Генерация случайной скорости
- Нет реального VPN туннеля

## Следующие шаги

1. ✅ Добавлены VPN разрешения в манифесты
2. ✅ Добавлен MethodChannel для связи с нативным кодом
3. ⏳ Создать нативный VpnService (Android)
4. ⏳ Создать Network Extension (iOS)
5. ⏳ Интегрировать v2ray/xray core
6. ⏳ Реализовать реальное подключение

## Примечания

- Для публикации в Google Play Store требуется специальная форма для VPN приложений
- Для iOS App Store VPN приложения проходят дополнительную проверку
- VLESS протокол требует специальной обработки, стандартные VPN API его не поддерживают напрямую

