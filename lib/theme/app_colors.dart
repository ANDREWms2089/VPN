import 'package:flutter/material.dart';

class AppColors {
  // Светло-зеленая цветовая палитра (зелено-бело-огуртные тона)
  static const Color primaryGreen = Color(0xFF7ED321); // Яркий зеленый
  static const Color lightGreen = Color(0xFFB8E986); // Светло-зеленый
  static const Color paleGreen = Color(0xFFE8F5E9); // Бледно-зеленый
  static const Color mintGreen = Color(0xFFC8E6C9); // Мятно-зеленый
  static const Color cucumberGreen = Color(0xFFA5D6A7); // Огурчный зеленый
  static const Color white = Color(0xFFFFFFFF);
  static const Color lightGray = Color(0xFFF5F5F5);
  static const Color darkGreen = Color(0xFF4CAF50);
  static const Color accentGreen = Color(0xFF66BB6A);
  
  // Градиенты
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [lightGreen, primaryGreen, darkGreen],
  );
  
  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [white, paleGreen, mintGreen],
  );
  
  static const LinearGradient cardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [white, cucumberGreen],
  );
}

