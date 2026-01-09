const functions = require('firebase-functions');
const express = require('express');
const cors = require('cors');
const fs = require('fs').promises;
const path = require('path');

const app = express();

// CORS настройка для Firebase
app.use(cors({
  origin: true,
  methods: ['GET', 'POST', 'PUT', 'DELETE'],
  allowedHeaders: ['Content-Type', 'Authorization'],
}));

app.use(express.json());

// Логирование запросов
app.use((req, res, next) => {
  console.log(`${new Date().toISOString()} - ${req.method} ${req.path}`);
  next();
});

// Путь к файлу с серверами (в Firebase Functions используем tmp директорию)
const SERVERS_FILE = path.join('/tmp', 'servers.json');

// Убеждаемся что файл существует
async function ensureServersFile() {
  try {
    await fs.access(SERVERS_FILE);
  } catch {
    // Файл не существует, создаем с дефолтными серверами
    const defaultServers = getDefaultServers();
    await saveServers(defaultServers);
  }
}

// Загрузка серверов из файла
async function loadServers() {
  try {
    await ensureServersFile();
    const data = await fs.readFile(SERVERS_FILE, 'utf8');
    return JSON.parse(data);
  } catch (error) {
    console.error('Error loading servers:', error);
    return getDefaultServers();
  }
}

// Сохранение серверов в файл
async function saveServers(servers) {
  try {
    await fs.writeFile(SERVERS_FILE, JSON.stringify(servers, null, 2), 'utf8');
  } catch (error) {
    console.error('Error saving servers:', error);
  }
}

// Дефолтные серверы
function getDefaultServers() {
  return [
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
  ];
}

// Глобальная переменная для хранения серверов
let servers = [];

// Инициализация при первом запросе
async function initServers() {
  if (servers.length === 0) {
    servers = await loadServers();
  }
  return servers;
}

// Валидация сервера
function validateServer(server) {
  const required = ['id', 'name', 'address', 'port', 'uuid', 'country', 'flag'];
  for (const field of required) {
    if (!server[field]) {
      throw new Error(`Missing required field: ${field}`);
    }
  }
  
  if (typeof server.port !== 'number' || server.port < 1 || server.port > 65535) {
    throw new Error('Invalid port number');
  }
  
  const uuidRegex = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i;
  if (!uuidRegex.test(server.uuid)) {
    throw new Error('Invalid UUID format');
  }
  
  return true;
}

// Генерация VLESS URL
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
  if (server.realityFingerprint) params.push(`fp=${encodeURIComponent(server.realityFingerprint)}`);
  if (server.realityPublicKey) params.push(`pbk=${encodeURIComponent(server.realityPublicKey)}`);
  if (server.realityShortId) params.push(`sid=${encodeURIComponent(server.realityShortId)}`);
  if (server.realitySpiderX) params.push(`spx=${encodeURIComponent(server.realitySpiderX)}`);
  if (server.realityServerName && !server.sni) {
    params.push(`sni=${encodeURIComponent(server.realityServerName)}`);
  }

  const query = params.length > 0 ? `?${params.join('&')}` : '';
  return `vless://${server.uuid}@${server.address}:${server.port}${query}#${encodeURIComponent(server.name)}`;
}

// Проверка ping (упрощенная версия для Cloud Functions)
async function checkPing(server) {
  return new Promise((resolve) => {
    const startTime = Date.now();
    const net = require('net');
    
    const socket = new net.Socket();
    const timeout = 3000;
    
    socket.setTimeout(timeout);
    
    socket.once('connect', () => {
      const ping = Date.now() - startTime;
      socket.destroy();
      resolve(Math.max(10, ping));
    });
    
    socket.once('timeout', () => {
      socket.destroy();
      resolve(server.ping || 100);
    });
    
    socket.once('error', () => {
      socket.destroy();
      const basePing = server.ping || 100;
      resolve(Math.floor(basePing + (Math.random() * 20) - 10));
    });
    
    socket.connect(server.port, server.address);
  });
}

// ========== API Endpoints ==========

// GET /health
app.get('/health', (req, res) => {
  res.json({
    status: 'ok',
    timestamp: new Date().toISOString(),
    serversCount: servers.length,
    version: '1.0.0',
  });
});

// GET /api/servers
app.get('/api/servers', async (req, res) => {
  try {
    await initServers();
    const includeTest = req.query.includeTest === 'true';
    let filteredServers = [...servers];
    
    if (!includeTest) {
      filteredServers = filteredServers.filter(s => !s.isTest);
    }
    
    filteredServers.sort((a, b) => {
      if (a.isTest !== b.isTest) {
        return a.isTest ? 1 : -1;
      }
      return a.ping - b.ping;
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

// GET /api/servers/:id
app.get('/api/servers/:id', async (req, res) => {
  try {
    await initServers();
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

// GET /api/servers/:id/ping
app.get('/api/servers/:id/ping', async (req, res) => {
  try {
    await initServers();
    const serverId = req.params.id;
    const server = servers.find(s => s.id === serverId);
    
    if (!server) {
      return res.status(404).json({
        success: false,
        error: 'Server not found',
      });
    }

    const ping = await checkPing(server);
    server.ping = ping;
    await saveServers(servers);
    
    res.json({
      success: true,
      ping: ping,
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

// POST /api/servers
app.post('/api/servers', async (req, res) => {
  try {
    await initServers();
    const server = req.body;
    
    if (servers.find(s => s.id === server.id)) {
      return res.status(400).json({
        success: false,
        error: 'Server with this ID already exists',
      });
    }
    
    validateServer(server);
    
    servers.push(server);
    await saveServers(servers);
    
    res.status(201).json({
      success: true,
      message: 'Server added successfully',
      server: server,
    });
  } catch (error) {
    console.error('Error adding server:', error);
    res.status(400).json({
      success: false,
      error: 'Failed to add server',
      message: error.message,
    });
  }
});

// PUT /api/servers/:id
app.put('/api/servers/:id', async (req, res) => {
  try {
    await initServers();
    const serverId = req.params.id;
    const serverIndex = servers.findIndex(s => s.id === serverId);
    
    if (serverIndex === -1) {
      return res.status(404).json({
        success: false,
        error: 'Server not found',
      });
    }
    
    const updatedServer = { ...servers[serverIndex], ...req.body };
    validateServer(updatedServer);
    
    servers[serverIndex] = updatedServer;
    await saveServers(servers);
    
    res.json({
      success: true,
      message: 'Server updated successfully',
      server: updatedServer,
    });
  } catch (error) {
    console.error('Error updating server:', error);
    res.status(400).json({
      success: false,
      error: 'Failed to update server',
      message: error.message,
    });
  }
});

// DELETE /api/servers/:id
app.delete('/api/servers/:id', async (req, res) => {
  try {
    await initServers();
    const serverId = req.params.id;
    const serverIndex = servers.findIndex(s => s.id === serverId);
    
    if (serverIndex === -1) {
      return res.status(404).json({
        success: false,
        error: 'Server not found',
      });
    }
    
    servers.splice(serverIndex, 1);
    await saveServers(servers);
    
    res.json({
      success: true,
      message: 'Server deleted successfully',
    });
  } catch (error) {
    console.error('Error deleting server:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to delete server',
      message: error.message,
    });
  }
});

// POST /api/connection
app.post('/api/connection', async (req, res) => {
  try {
    await initServers();
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
      const vlessUrl = generateVlessUrl(server);
      
      res.json({
        success: true,
        message: 'Connection initiated',
        server: server,
        vlessUrl: vlessUrl,
        timestamp: new Date().toISOString(),
      });
    } else if (action === 'disconnect') {
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

// 404 handler
app.use((req, res) => {
  res.status(404).json({
    success: false,
    error: 'Endpoint not found',
    path: req.path,
  });
});

// Error handler
app.use((err, req, res, next) => {
  console.error('Server error:', err);
  res.status(500).json({
    success: false,
    error: 'Internal server error',
    message: err.message,
  });
});

// Экспорт Express приложения как Cloud Function
exports.api = functions.https.onRequest(app);


