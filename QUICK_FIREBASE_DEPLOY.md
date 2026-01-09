# ⚡ Быстрый деплой на Firebase

## Шаг 1: Авторизация

```bash
cd /Users/andrewvoevodin/StudioProjects/VPN_front
firebase login
```

Откроется браузер - войдите в ваш Google аккаунт.

## Шаг 2: Создание проекта (если еще не создан)

### Через консоль:
1. Откройте https://console.firebase.google.com/
2. Нажмите "Add project"
3. Введите название: `vpn-front` (или другое)
4. Следуйте инструкциям

### Или через CLI:
```bash
firebase projects:create vpn-front
firebase use vpn-front
```

## Шаг 3: Инициализация

```bash
firebase init
```

**Выберите:**
- ✅ Functions (для backend API)
- ✅ Hosting (опционально, для веб-версии)

**Настройки:**
- Использовать существующий проект? → **Да** → выберите ваш проект
- Язык для Functions? → **JavaScript**
- ESLint? → **Нет**
- Установить зависимости? → **Да**

## Шаг 4: Деплой

```bash
# Быстрый деплой
./deploy.sh

# Или вручную:
firebase deploy --only functions
```

## Шаг 5: Получение URL API

После деплоя вы увидите URL типа:
```
✔  functions[api(us-central1)]: Successful create operation.
https://us-central1-vpn-front.cloudfunctions.net/api
```

**Скопируйте этот URL!**

## Шаг 6: Обновление Flutter приложения

Обновите `lib/services/api_service.dart`:

```dart
static String get baseUrl {
  if (!kIsWeb && Platform.isAndroid) {
    // Используйте ваш Firebase Functions URL + /api
    return 'https://us-central1-YOUR-PROJECT-ID.cloudfunctions.net/api/api';
  }
  return 'https://us-central1-YOUR-PROJECT-ID.cloudfunctions.net/api/api';
}
```

Замените `YOUR-PROJECT-ID` на ID вашего Firebase проекта.

## ✅ Готово!

Ваш API теперь доступен по адресу:
```
https://us-central1-YOUR-PROJECT-ID.cloudfunctions.net/api/api/servers
```

## 🔍 Проверка

```bash
curl https://us-central1-YOUR-PROJECT-ID.cloudfunctions.net/api/api/health
```

Должен вернуть:
```json
{"status":"ok","timestamp":"...","serversCount":2,"version":"1.0.0"}
```

## 📝 Полезные команды

```bash
# Проверить текущий проект
firebase projects:list

# Переключиться на проект
firebase use PROJECT_ID

# Посмотреть логи
firebase functions:log

# Удалить deployment
firebase functions:delete api
```

---

**Готово! Ваш backend задеплоен на Firebase! 🎉**

