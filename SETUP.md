# Инструкция по настройке VPN приложения

## Быстрый старт

### 1. Frontend (Flutter)

```bash
# Установите зависимости
flutter pub get

# Запустите приложение
flutter run
```

### 2. Backend (Node.js)

```bash
# Перейдите в директорию backend
cd backend

# Установите зависимости
npm install

# Запустите сервер
npm start
```

Сервер будет доступен на `http://localhost:3000`

## Настройка подключения к бэкенду

По умолчанию приложение использует моковые данные. Для подключения к реальному бэкенду:

1. Откройте `lib/services/api_service.dart`
2. Измените `useMockData` на `false`:
   ```dart
   static const bool useMockData = false;
   ```
3. Убедитесь, что `baseUrl` указывает на правильный адрес:
   - Локально: `http://localhost:3000/api`
   - Android эмулятор: `http://10.0.2.2:3000/api`
   - iOS симулятор: `http://localhost:3000/api`
   - Удаленный сервер: `https://your-backend-api.com/api`

## Добавление реальных VLESS серверов

Отредактируйте массив `servers` в `backend/server.js` или подключите базу данных.

## Интеграция с реальным VPN

Текущая реализация использует симуляцию VPN подключения. Для реальной работы:

1. Добавьте нативные плагины для VPN (например, `flutter_vpn` или создайте свой)
2. Обновите `lib/services/vpn_service.dart` для использования реальных VPN API
3. Настройте разрешения в `AndroidManifest.xml` и `Info.plist`

## Цветовая схема

Все цвета определены в `lib/theme/app_colors.dart`. Вы можете легко изменить палитру, отредактировав значения цветов.

## Структура VLESS конфигурации

Каждый сервер содержит:
- `address` - адрес сервера
- `port` - порт
- `uuid` - уникальный идентификатор
- `flow` - тип потока (например, `xtls-rprx-vision`)
- `encryption` - метод шифрования
- `network` - тип сети (tcp, ws, grpc и т.д.)
- `security` - тип безопасности (tls, reality и т.д.)
- `sni` - Server Name Indication

