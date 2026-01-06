import 'package:flutter/material.dart';

class AppTextStyles {
  // Базовый стиль с шрифтом Sansation
  static TextStyle base({
    double? fontSize,
    FontWeight? fontWeight,
    Color? color,
    TextAlign? textAlign,
  }) {
    return TextStyle(
      fontFamily: 'Sansation',
      fontSize: fontSize ?? 14,
      fontWeight: fontWeight ?? FontWeight.normal,
      color: color,
    );
  }

  // Заголовки
  static TextStyle heading1({Color? color}) => base(
        fontSize: 36,
        fontWeight: FontWeight.bold,
        color: color,
      );

  static TextStyle heading2({Color? color}) => base(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: color,
      );

  static TextStyle heading3({Color? color}) => base(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: color,
      );

  // Обычный текст
  static TextStyle body({Color? color}) => base(
        fontSize: 16,
        color: color,
      );

  static TextStyle bodySmall({Color? color}) => base(
        fontSize: 14,
        color: color,
      );

  static TextStyle bodyLarge({Color? color}) => base(
        fontSize: 18,
        color: color,
      );

  // Кнопки
  static TextStyle button({Color? color}) => base(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: color,
      );
}

