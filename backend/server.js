const express = require('express');
const cors = require('cors');
require('dotenv').config();

const app = express();
const PORT = process.env.PORT || 3000;

// Middleware
app.use(cors({
  origin: '*', // В production укажите конкретные домены
  methods: ['GET', 'POST', 'PUT', 'DELETE'],
  allowedHeaders: ['Content-Type', 'Authorization'],
}));
app.use(express.json());

// Логирование запросов
app.use((req, res, next) => {
  console.log(`${new Date().toISOString()} - ${req.method} ${req.path}`);
  next();
});

// VLESS servers data
const servers = [
  // Реальный сервер из Нидерландов (Reality)
  {
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
    isActive: false,
    isTest: false,
  },
  // Реальный сервер из России (Reality)
  {
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
    isActive: false,
    isTest: false,
  },
  // Реальный сервер из Санкт-Петербурга
  {
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
    isActive: false,
    isTest: false,
  },
  // Тестовые серверы (для демонстрации)
  {
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
    isActive: false,
    isTest: true,
  },
  {
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
    isActive: false,
    isTest: true,
  },
  {
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
    isActive: false,
    isTest: true,
  },
  {
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
    isActive: false,
    isTest: true,
  },
];

// GET /api/servers - Get all VLESS servers
app.get('/api/servers', (req, res) => {
  try {
    // Фильтрация по isTest, если нужно
    const includeTest = req.query.includeTest === 'true';
    let filteredServers = servers;
    
    if (!includeTest) {
      filteredServers = servers.filter(s => !s.isTest);
    }
    
    // Сортировка: сначала реальные серверы, потом тестовые
    filteredServers.sort((a, b) => {
      if (a.isTest !== b.isTest) {
        return a.isTest ? 1 : -1;
      }
      return a.ping - b.ping; // Сортировка по ping
    });
    
    res.json({
      success: true,
      count: filteredServers.length,
      servers: filteredServers,
    });
  } catch (error) {
    console.error('Error getting servers:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to get servers',
      message: error.message,
    });
  }
});

// GET /api/servers/:id/ping - Ping a specific server
app.get('/api/servers/:id/ping', async (req, res) => {
  try {
    const serverId = req.params.id;
    const server = servers.find(s => s.id === serverId);
    
    if (!server) {
      return res.status(404).json({
        success: false,
        error: 'Server not found',
      });
    }

    // В реальном приложении здесь будет реальный ping
    // Для демонстрации используем симуляцию с небольшим случайным отклонением
    const basePing = server.ping || 50;
    const ping = Math.floor(basePing + (Math.random() * 20) - 10); // ±10ms от базового ping
    
    // Симуляция задержки сети
    await new Promise(resolve => setTimeout(resolve, 200));
    
    res.json({
      success: true,
      ping: Math.max(10, ping), // Минимум 10ms
      serverId: serverId,
      timestamp: new Date().toISOString(),
    });
  } catch (error) {
    console.error('Error pinging server:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to ping server',
      message: error.message,
    });
  }
});

// POST /api/connection - Handle connection requests
app.post('/api/connection', async (req, res) => {
  try {
    const { serverId, action } = req.body;
    
    if (!serverId || !action) {
      return res.status(400).json({
        success: false,
        error: 'Missing serverId or action',
      });
    }

    const server = servers.find(s => s.id === serverId);
    if (!server) {
      return res.status(404).json({
        success: false,
        error: 'Server not found',
      });
    }

    if (action === 'connect') {
      // В реальном приложении здесь будет:
      // 1. Валидация конфигурации сервера
      // 2. Генерация VLESS параметров подключения
      // 3. Сохранение состояния подключения
      // 4. Возврат деталей подключения
      
      const vlessUrl = generateVlessUrl(server);
      
      // Симуляция задержки подключения
      await new Promise(resolve => setTimeout(resolve, 800));
      
      res.json({
        success: true,
        message: 'Connection initiated',
        server: server,
        vlessUrl: vlessUrl,
        timestamp: new Date().toISOString(),
      });
    } else if (action === 'disconnect') {
      // В реальном приложении здесь будет:
      // 1. Закрытие VPN соединения
      // 2. Очистка состояния
      
      await new Promise(resolve => setTimeout(resolve, 300));
      
      res.json({
        success: true,
        message: 'Disconnected',
        timestamp: new Date().toISOString(),
      });
    } else {
      res.status(400).json({
        success: false,
        error: 'Invalid action. Use "connect" or "disconnect"',
      });
    }
  } catch (error) {
    console.error('Error handling connection:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to handle connection',
      message: error.message,
    });
  }
});

// Helper function to generate VLESS URL
function generateVlessUrl(server) {
  const params = [];
  if (server.network) params.push(`type=${encodeURIComponent(server.network)}`);
  if (server.encryption) params.push(`encryption=${encodeURIComponent(server.encryption)}`);
  if (server.path) params.push(`path=${encodeURIComponent(server.path)}`);
  if (server.host) params.push(`host=${encodeURIComponent(server.host)}`);
  if (server.mode) params.push(`mode=${encodeURIComponent(server.mode)}`);
  if (server.security) params.push(`security=${encodeURIComponent(server.security)}`);
  if (server.flow) params.push(`flow=${encodeURIComponent(server.flow)}`);
  if (server.sni) params.push(`sni=${encodeURIComponent(server.sni)}`);
  // Reality параметры
  if (server.realityFingerprint) params.push(`fp=${encodeURIComponent(server.realityFingerprint)}`);
  if (server.realityPublicKey) params.push(`pbk=${encodeURIComponent(server.realityPublicKey)}`);
  if (server.realityShortId) params.push(`sid=${encodeURIComponent(server.realityShortId)}`);
  if (server.realitySpiderX) params.push(`spx=${encodeURIComponent(server.realitySpiderX)}`);
  // Для Reality serverName используется как sni
  if (server.realityServerName && !server.sni) {
    params.push(`sni=${encodeURIComponent(server.realityServerName)}`);
  }

  const query = params.length > 0 ? `?${params.join('&')}` : '';
  return `vless://${server.uuid}@${server.address}:${server.port}${query}#${encodeURIComponent(server.name)}`;
}

// GET /api/server/:id - Get specific server details
app.get('/api/servers/:id', (req, res) => {
  try {
    const serverId = req.params.id;
    const server = servers.find(s => s.id === serverId);
    
    if (!server) {
      return res.status(404).json({
        success: false,
        error: 'Server not found',
      });
    }
    
    res.json({
      success: true,
      server: server,
    });
  } catch (error) {
    console.error('Error getting server:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to get server',
      message: error.message,
    });
  }
});

// Обработка ошибок 404
app.use((req, res) => {
  res.status(404).json({
    success: false,
    error: 'Endpoint not found',
    path: req.path,
  });
});

// Обработка ошибок сервера
app.use((err, req, res, next) => {
  console.error('Server error:', err);
  res.status(500).json({
    success: false,
    error: 'Internal server error',
    message: err.message,
  });
});

// Health check endpoint
app.get('/health', (req, res) => {
  res.json({
    status: 'ok',
    timestamp: new Date().toISOString(),
    uptime: process.uptime(),
    serversCount: servers.length,
  });
});

// Запуск сервера на всех интерфейсах (0.0.0.0) для доступа из эмулятора
app.listen(PORT, '0.0.0.0', () => {
  console.log(`🚀 VPN Backend API running on http://0.0.0.0:${PORT}`);
  console.log(`📡 Available at:`);
  console.log(`   - http://localhost:${PORT} (local)`);
  console.log(`   - http://10.0.2.2:${PORT} (Android emulator)`);
  console.log(`📡 Available endpoints:`);
  console.log(`   GET  /api/servers`);
  console.log(`   GET  /api/servers/:id/ping`);
  console.log(`   POST /api/connection`);
  console.log(`   GET  /health`);
});

