# VPN Backend API

Backend сервер для VPN приложения с поддержкой VLESS протокола.

## 🚀 Быстрый старт

### Установка зависимостей

```bash
npm install
```

### Запуск сервера

**Режим разработки (с автоперезагрузкой):**
```bash
npm run dev
```

**Production режим:**
```bash
npm start
```

Сервер будет доступен на `http://localhost:3000`

## 📡 API Endpoints

### GET /api/servers
Получить список всех VLESS серверов.

**Параметры запроса:**
- `includeTest` (опционально) - включить тестовые серверы (по умолчанию `false`)

**Пример запроса:**
```bash
GET /api/servers
GET /api/servers?includeTest=true
```

**Ответ:**
```json
{
  "success": true,
  "count": 3,
  "servers": [...]
}
```

### GET /api/servers/:id
Получить детальную информацию о конкретном сервере.

**Пример запроса:**
```bash
GET /api/servers/nl-reality-1
```

### GET /api/servers/:id/ping
Проверить ping до сервера.

**Пример запроса:**
```bash
GET /api/servers/nl-reality-1/ping
```

**Ответ:**
```json
{
  "success": true,
  "ping": 35,
  "serverId": "nl-reality-1",
  "timestamp": "2024-01-01T12:00:00.000Z"
}
```

### POST /api/connection
Управление VPN подключением.

**Тело запроса:**
```json
{
  "serverId": "nl-reality-1",
  "action": "connect" // или "disconnect"
}
```

**Ответ (connect):**
```json
{
  "success": true,
  "message": "Connection initiated",
  "server": {...},
  "vlessUrl": "vless://...",
  "timestamp": "2024-01-01T12:00:00.000Z"
}
```

### GET /health
Проверка здоровья сервера.

**Ответ:**
```json
{
  "status": "ok",
  "timestamp": "2024-01-01T12:00:00.000Z",
  "uptime": 3600,
  "serversCount": 7
}
```

## 🔧 Настройка

### Переменные окружения

Создайте файл `.env` в корне папки `backend/`:

```env
PORT=3000
NODE_ENV=development
```

### CORS

По умолчанию CORS настроен для всех доменов (`origin: '*'`). В production укажите конкретные домены:

```javascript
app.use(cors({
  origin: ['https://your-frontend-domain.com'],
  // ...
}));
```

## 📝 Структура данных сервера

```javascript
{
  id: 'unique-id',
  name: 'Server Name',
  address: 'server.example.com',
  port: 443,
  uuid: 'uuid-string',
  flow: 'xtls-rprx-vision',
  encryption: 'none',
  network: 'tcp',
  security: 'reality',
  path: '/',
  host: '',
  mode: 'auto',
  realityServerName: 'vpnforppl.top',
  realityShortId: 'short-id',
  realityPublicKey: 'public-key',
  realityFingerprint: 'chrome',
  realitySpiderX: '',
  country: 'Country Name',
  flag: '🇳🇱',
  ping: 35,
  isActive: false,
  isTest: false
}
```

## 🔐 Безопасность

В production рекомендуется:

1. Добавить аутентификацию (JWT токены)
2. Ограничить CORS конкретными доменами
3. Добавить rate limiting
4. Использовать HTTPS
5. Валидировать все входящие данные

## 📦 Зависимости

- `express` - веб-фреймворк
- `cors` - обработка CORS
- `dotenv` - переменные окружения

## 🛠️ Разработка

### Добавление нового сервера

Отредактируйте массив `servers` в `server.js`:

```javascript
{
  id: 'new-server-id',
  name: 'New Server',
  // ... остальные параметры
}
```

### Интеграция с базой данных

Для production рекомендуется использовать базу данных (MongoDB, PostgreSQL и т.д.) вместо хранения серверов в памяти.

## 📄 Лицензия

ISC

