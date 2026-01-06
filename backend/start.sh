#!/bin/bash

# Скрипт для запуска бэкенда

echo "🚀 Starting VPN Backend..."
echo ""

# Проверка Node.js
if ! command -v node &> /dev/null; then
    echo "❌ Node.js is not installed. Please install Node.js first."
    exit 1
fi

# Проверка npm
if ! command -v npm &> /dev/null; then
    echo "❌ npm is not installed. Please install npm first."
    exit 1
fi

# Проверка зависимостей
if [ ! -d "node_modules" ]; then
    echo "📦 Installing dependencies..."
    npm install
fi

# Запуск сервера
echo "✅ Starting server on port 3000..."
echo "   Access from Android emulator: http://10.0.2.2:3000"
echo "   Access from localhost: http://localhost:3000"
echo ""

npm run dev

