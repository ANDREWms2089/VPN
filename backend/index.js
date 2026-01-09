const functions = require('firebase-functions');
const express = require('express');
const cors = require('cors');
const fs = require('fs').promises;
const path = require('path');

const app = express();

// CORS configuration
app.use(cors({
  origin: true,
  credentials: true,
}));
app.use(express.json());

// Импортируем все роуты из server.js
// Создаем мини-версию server.js для Cloud Functions
const SERVERS_FILE = path.join(__dirname, 'data', 'servers.json');

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
  ];
}

// In-memory storage для Cloud Functions (в продакшене используйте Firestore)
let servers = getDefaultServers();

// Health check
app.get('/health', (req, res) => {
  res.json({
    status: 'ok',
    timestamp: new Date().toISOString(),
    serversCount: servers.length,
    version: '1.0.0',
  });
});

// GET /api/servers
app.get('/api/servers', (req, res) => {
  try {
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
    res.status(500).json({
      success: false,
      error: 'Failed to get servers',
      message: error.message,
    });
  }
});

// GET /api/servers/:id/ping
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

    // Симуляция ping для Cloud Functions
    const basePing = server.ping || 50;
    const ping = Math.floor(basePing + (Math.random() * 20) - 10);
    
    res.json({
      success: true,
      ping: Math.max(10, ping),
      serverId: serverId,
      timestamp: new Date().toISOString(),
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      error: 'Failed to ping server',
      message: error.message,
    });
  }
});

// Экспортируем Express app как Cloud Function
exports.api = functions.https.onRequest(app);

