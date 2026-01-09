#!/bin/bash

# Скрипт для деплоя на Firebase

echo "🚀 Деплой Belchonok VPN на Firebase"
echo ""

# Проверка авторизации
if ! firebase projects:list &> /dev/null; then
    echo "❌ Вы не авторизованы в Firebase"
    echo "Выполните: firebase login"
    exit 1
fi

echo "✅ Авторизация проверена"
echo ""

# Установка зависимостей для functions
echo "📦 Установка зависимостей..."
cd backend
npm install
cd ..

# Деплой
echo ""
echo "🚀 Начинаем деплой..."
firebase deploy

echo ""
echo "✅ Деплой завершен!"
echo ""
echo "📝 Проверьте URL вашего API в Firebase Console"
echo "   https://console.firebase.google.com/"

