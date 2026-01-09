#!/bin/bash

echo "=== Мониторинг логов VPN приложения ==="
echo "Приложение запущено на эмуляторе emulator-5556"
echo ""
echo "Попробуйте подключиться к VPN в приложении, и здесь появятся логи"
echo "Нажмите Ctrl+C для выхода"
echo ""
echo "=== Логи Flutter (VPN подключение) ==="
echo ""

# Мониторим логи Flutter через adb
adb -s emulator-5556 logcat -s flutter:I *:E | grep -E "(flutter|VPN|VpnService|v2ray|V2Ray|Belchonok|Starting|permission|Permission|connect|Connect|error|Error|exception|Exception)" --line-buffered

