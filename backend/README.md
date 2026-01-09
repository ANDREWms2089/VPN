# VPN Backend API

Backend API для Belchonok VPN приложения с поддержкой VLESS протокола.

## 🚀 Быстрый старт

### Установка зависимостей

```bash
npm install
```

### Настройка переменных окружения

Создайте файл `.env` на основе `.env.example`:

```bash
cp .env.example .env
```

### Запуск

```bash
# Режим разработки (с автоперезагрузкой)
npm run dev

# Production режим
npm start
```

Сервер будет доступен на `http://localhost:3000`

## 📡 API Endpoints

### Health Check

```
GET /health
```

Проверка работоспособности сервера.

**Response:**
```json
{
  "status": "ok",
  "timestamp": "2024-01-01T12:00:00.000Z",
  "uptime": 123.45,
  "serversCount": 5,
  "version": "1.0.0"
}
```

### Получить все серверы

```
GET /api/servers?includeTest=true
```

**Query параметры:**
- `includeTest` (optional, default: false) - включить тестовые серверы

**Response:**
```json
{
  "success": true,
  "count": 5,
  "servers": [
    {
      "id": "nl-reality-1",
      "name": "Нидерланды 10Гбит/с",
      "address": "10.nl.vpnpplvpn.top",
      "port": 443,
      "uuid": "58a6ce24-fe00-4a0e-8c69-a3381f5a5da1",
      ...
    }
  ]
}
```

### Получить сервер по ID

```
GET /api/servers/:id
```

**Response:**
```json
{
  "success": true,
  "server": {
    "id": "nl-reality-1",
    ...
  }
}
```

### Проверить ping сервера

```
GET /api/servers/:id/ping
```

Выполняет реальную проверку ping через TCP подключение.

**Response:**
```json
{
  "success": true,
  "ping": 35,
  "serverId": "nl-reality-1",
  "timestamp": "2024-01-01T12:00:00.000Z"
}
```

### Добавить сервер

```
POST /api/servers
Content-Type: application/json

{
  "id": "new-server-1",
  "name": "New Server",
  "address": "example.com",
  "port": 443,
  "uuid": "12345678-1234-1234-1234-123456789abc",
  "country": "Netherlands",
  "flag": "🇳🇱",
  ...
}
```

**Response:**
```json
{
  "success": true,
  "message": "Server added successfully",
  "server": { ... }
}
```

### Обновить сервер

```
PUT /api/servers/:id
Content-Type: application/json

{
  "name": "Updated Server Name",
  "ping": 50,
  ...
}
```

**Response:**
```json
{
  "success": true,
  "message": "Server updated successfully",
  "server": { ... }
}
```

### Удалить сервер

```
DELETE /api/servers/:id
```

**Response:**
```json
{
  "success": true,
  "message": "Server deleted successfully"
}
```

### Управление подключением

```
POST /api/connection
Content-Type: application/json

{
  "serverId": "nl-reality-1",
  "action": "connect" // или "disconnect"
}
```

**Response (connect):**
```json
{
  "success": true,
  "message": "Connection initiated",
  "server": { ... },
  "vlessUrl": "vless://...",
  "timestamp": "2024-01-01T12:00:00.000Z"
}
```

## 💾 Хранение данных

Серверы сохраняются в файл `data/servers.json`. При первом запуске создаются дефолтные серверы, если файл не существует.

### Структура данных сервера

```typescript
{
  id: string;                    // Уникальный ID
  name: string;                  // Название сервера
  address: string;               // IP или домен
  port: number;                  // Порт (1-65535)
  uuid: string;                  // UUID пользователя (формат UUID v4)
  flow?: string;                 // Flow (например, xtls-rprx-vision)
  encryption?: string;           // Шифрование
  network?: string;              // Сеть (tcp, ws, grpc, http)
  security?: string;             // Безопасность (none, tls, reality)
  sni?: string;                  // SNI
  path?: string;                 // Путь (для ws, grpc, http)
  host?: string;                 // Host header
  mode?: string;                 // Режим
  realityServerName?: string;    // Reality server name
  realityShortId?: string;       // Reality short ID
  realityPublicKey?: string;     // Reality public key
  realityFingerprint?: string;   // Reality fingerprint
  realitySpiderX?: string;       // Reality spiderX
  country: string;               // Страна
  flag: string;                  // Флаг (эмодзи)
  ping: number;                  // Ping в миллисекундах
  isActive: boolean;             // Активен ли сервер
  isTest: boolean;               // Тестовый ли сервер
}
```

## 🔧 Настройка

### Переменные окружения

Создайте файл `.env`:

```env
PORT=3000
NODE_ENV=development
```

### CORS

По умолчанию CORS настроен для всех доменов (`*`). В production укажите конкретные домены:

```javascript
app.use(cors({
  origin: ['https://your-frontend-domain.com'],
  ...
}));
```

## 🧪 Тестирование

Проверка работы API:

```bash
# Health check
curl http://localhost:3000/health

# Получить серверы
curl http://localhost:3000/api/servers

# Проверить ping
curl http://localhost:3000/api/servers/nl-reality-1/ping
```

## 📦 Зависимости

- `express` - Web framework
- `cors` - CORS middleware
- `dotenv` - Переменные окружения

### Dev зависимости

- `nodemon` - Автоперезагрузка в режиме разработки

## 🚀 Production

Для production:

1. Установите `NODE_ENV=production`
2. Настройте CORS для конкретных доменов
3. Используйте процесс-менеджер (PM2, systemd)
4. Настройте HTTPS через reverse proxy (nginx)
5. Рассмотрите использование базы данных (MongoDB, PostgreSQL)

## 📝 Логирование

Все запросы логируются в консоль с временной меткой:
```
2024-01-01T12:00:00.000Z - GET /api/servers
```

## 🔒 Безопасность

Для production рекомендуется:

1. Добавить аутентификацию (JWT, OAuth)
2. Настроить rate limiting
3. Валидировать все входные данные
4. Использовать HTTPS
5. Настроить firewall

## 📄 Лицензия

ISC
