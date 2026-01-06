import 'package:flutter/material.dart';

class AppColors {
  // Оранжевая цветовая палитра (Belchonok VPN)
  static const Color primaryOrange = Color(0xFFFCA336); // Яркий оранжевый
  static const Color lightOrange = Color(0xFFFFB366); // Светло-оранжевый
  static const Color paleOrange = Color(0xFFFFE5CC); // Бледно-оранжевый
  static const Color softOrange = Color(0xFFFFD9B3); // Мягкий оранжевый
  static const Color warmOrange = Color(0xFFFFCC99); // Теплый оранжевый
  static const Color darkOrange = Color(0xFFFC7625); // Темный оранжевый
  static const Color white = Color(0xFFFFFFFF);
  static const Color lightGray = Color(0xFFF5F5F5);
  static const Color accentOrange = Color(0xFFFF9933);
  
  // Градиенты (из иконки приложения)
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryOrange, darkOrange],
  );
  
  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [white, paleOrange, softOrange],
  );
  
  static const LinearGradient cardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [white, warmOrange],
  );
  
  // Для обратной совместимости (старые названия)
  static const Color primaryGreen = primaryOrange;
  static const Color lightGreen = lightOrange;
  static const Color paleGreen = paleOrange;
  static const Color mintGreen = softOrange;
  static const Color cucumberGreen = warmOrange;
  static const Color darkGreen = darkOrange;
  static const Color accentGreen = accentOrange;
}

