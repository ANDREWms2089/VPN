# ⚡ Быстрая установка иконки

## Что нужно сделать:

1. **Сохраните ваш PNG файл** в папку `assets/` с именем `icon.png`

2. **Установите пакет для генерации иконок:**
   ```bash
   flutter pub add --dev flutter_launcher_icons
   ```

3. **Раскомментируйте конфигурацию** в конце `pubspec.yaml`:
   ```yaml
   flutter_launcher_icons:
     android: true
     ios: true
     image_path: "assets/icon.png"
     adaptive_icon_background: "#000000"
     adaptive_icon_foreground: "assets/icon.png"
     remove_alpha_ios: true
   ```

4. **Сгенерируйте иконки:**
   ```bash
   flutter pub get
   flutter pub run flutter_launcher_icons
   ```

5. **Перезапустите приложение** - иконка будет обновлена!

## Готово! ✅

После этого:
- ✅ Иконка появится на главном экране устройства
- ✅ Splash screen будет использовать эту иконку
- ✅ Все платформы (Android/iOS) будут использовать новую иконку

