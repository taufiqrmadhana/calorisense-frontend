import 'package:calorisense/core/theme/pallete.dart';
import 'package:flutter/material.dart';

class AppTheme {
  static _border([Color color = AppPalette.borderColor]) => OutlineInputBorder(
    borderSide: BorderSide(color: color, width: 1),
    borderRadius: BorderRadius.circular(10),
  );

  static final lightThemeMode = ThemeData.light().copyWith(
    scaffoldBackgroundColor: AppPalette.backgroundColor,
    inputDecorationTheme: InputDecorationTheme(
      contentPadding: const EdgeInsets.all(15),
      filled: true,
      fillColor: AppPalette.white,
      enabledBorder: _border(),
      focusedBorder: _border(AppPalette.borderColorPressed),
      hintStyle: TextStyle(color: AppPalette.subTextColor),
    ),
    textTheme: const TextTheme(
      titleSmall: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.normal,
        color: AppPalette.textColor,
      ),
    ),
  );
}
