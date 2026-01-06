# 🎨 Генерация иконок приложения

## Быстрый способ (рекомендуется)

### 1. Установите flutter_launcher_icons

```bash
flutter pub add --dev flutter_launcher_icons
```

### 2. Конвертируйте SVG в PNG

Сначала конвертируйте `assets/icon.svg` в PNG (1024x1024px):
- Используйте онлайн конвертер: https://cloudconvert.com/svg-to-png
- Или используйте ImageMagick: `convert -background none -size 1024x1024 assets/icon.svg assets/icon.png`

### 3. Добавьте конфигурацию в pubspec.yaml

Добавьте в конец `pubspec.yaml`:

```yaml
flutter_launcher_icons:
  android: true
  ios: true
  image_path: "assets/icon.png"
  adaptive_icon_background: "#FCA336"
  adaptive_icon_foreground: "assets/icon.png"
  remove_alpha_ios: true
```

### 4. Сгенерируйте иконки

```bash
flutter pub run flutter_launcher_icons
```

## Ручной способ

### Android

Создайте PNG иконки разных размеров и поместите в:
- `android/app/src/main/res/mipmap-mdpi/ic_launcher.png` (48x48)
- `android/app/src/main/res/mipmap-hdpi/ic_launcher.png` (72x72)
- `android/app/src/main/res/mipmap-xhdpi/ic_launcher.png` (96x96)
- `android/app/src/main/res/mipmap-xxhdpi/ic_launcher.png` (144x144)
- `android/app/src/main/res/mipmap-xxxhdpi/ic_launcher.png` (192x192)

### iOS

Поместите иконку 1024x1024px в `ios/Runner/Assets.xcassets/AppIcon.appiconset/`

## Онлайн инструменты

- **SVG to PNG**: https://cloudconvert.com/svg-to-png
- **Resize images**: https://www.iloveimg.com/resize-image
- **Icon generator**: https://www.appicon.co/

