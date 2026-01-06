# 🎨 Настройка иконки приложения

## Иконка SVG

Иконка приложения сохранена в `assets/icon.svg` с оранжевым градиентом (#FCA336 → #FC7625).

## Генерация иконок для платформ

### Android

Для Android нужно создать PNG иконки разных размеров. Используйте один из способов:

#### Способ 1: Flutter Launcher Icons (рекомендуется)

1. Установите пакет:
```bash
flutter pub add --dev flutter_launcher_icons
```

2. Добавьте в `pubspec.yaml`:
```yaml
flutter_launcher_icons:
  android: true
  ios: true
  image_path: "assets/icon.png"  # Сначала конвертируйте SVG в PNG
  adaptive_icon_background: "#FCA336"
  adaptive_icon_foreground: "assets/icon.png"
```

3. Сгенерируйте иконки:
```bash
flutter pub run flutter_launcher_icons
```

#### Способ 2: Ручная генерация

Конвертируйте SVG в PNG разных размеров и поместите в:
- `android/app/src/main/res/mipmap-mdpi/ic_launcher.png` (48x48)
- `android/app/src/main/res/mipmap-hdpi/ic_launcher.png` (72x72)
- `android/app/src/main/res/mipmap-xhdpi/ic_launcher.png` (96x96)
- `android/app/src/main/res/mipmap-xxhdpi/ic_launcher.png` (144x144)
- `android/app/src/main/res/mipmap-xxxhdpi/ic_launcher.png` (192x192)

### iOS

Для iOS создайте иконки через Xcode или используйте flutter_launcher_icons.

### Онлайн инструменты для конвертации SVG → PNG

- https://cloudconvert.com/svg-to-png
- https://convertio.co/svg-png/
- https://www.freeconvert.com/svg-to-png

### Рекомендуемые размеры

- **Android**: 192x192px (для xxxhdpi)
- **iOS**: 1024x1024px (для App Store)

## Временное решение

Пока иконки не сгенерированы, приложение будет использовать стандартные иконки Flutter.

