# ⚡ Быстрый деплой на Render (5 минут)

## Шаги:

1. **Откройте [render.com](https://render.com)** и войдите через GitHub

2. **Нажмите "New +" → "Web Service"**

3. **Подключите репозиторий:**
   - Выберите ваш репозиторий `VPN_front`
   - Или вставьте URL репозитория

4. **Заполните настройки:**
   ```
   Name: vpn-backend
   Root Directory: backend  ⚠️ ВАЖНО!
   Environment: Node
   Build Command: npm install
   Start Command: npm start
   Plan: Free
   ```

5. **Нажмите "Create Web Service"**

6. **Дождитесь деплоя** (2-5 минут)

7. **Скопируйте URL** (например: `https://vpn-backend.onrender.com`)

8. **Проверьте:** откройте `https://your-url.onrender.com/health`

## ✅ Готово!

Теперь используйте этот URL в вашем Flutter приложении.

**Примечание:** На бесплатном тарифе сервис "засыпает" после 15 минут бездействия. Первый запрос после пробуждения может занять 30-60 секунд.

