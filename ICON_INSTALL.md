# 📱 Установка иконки приложения

## Шаг 1: Сохраните PNG файл

Поместите ваш PNG файл иконки в папку `assets/` с именем `icon.png`:

```
assets/
  - icon.png  (ваш файл)
  - icon.svg
```

## Шаг 2: Генерация иконок для платформ

### Автоматический способ (рекомендуется)

1. Установите пакет:
```bash
flutter pub add --dev flutter_launcher_icons
```

2. Добавьте в конец `pubspec.yaml`:
```yaml
flutter_launcher_icons:
  android: true
  ios: true
  image_path: "assets/icon.png"
  adaptive_icon_background: "#000000"  # Черный фон для Android
  adaptive_icon_foreground: "assets/icon.png"
  remove_alpha_ios: true
```

3. Сгенерируйте иконки:
```bash
flutter pub run flutter_launcher_icons
```

### Ручной способ

#### Android

Создайте иконки разных размеров и поместите в:
- `android/app/src/main/res/mipmap-mdpi/ic_launcher.png` (48x48)
- `android/app/src/main/res/mipmap-hdpi/ic_launcher.png` (72x72)
- `android/app/src/main/res/mipmap-xhdpi/ic_launcher.png` (96x96)
- `android/app/src/main/res/mipmap-xxhdpi/ic_launcher.png` (144x144)
- `android/app/src/main/res/mipmap-xxxhdpi/ic_launcher.png` (192x192)

#### iOS

Поместите иконку 1024x1024px в `ios/Runner/Assets.xcassets/AppIcon.appiconset/`

## Проверка

После генерации иконок:
1. Перезапустите приложение
2. Проверьте, что иконка отображается на главном экране устройства
3. Splash screen уже настроен для использования иконки

