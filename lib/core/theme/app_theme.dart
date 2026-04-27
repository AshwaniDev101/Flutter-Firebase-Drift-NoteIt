import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class Themes {
  static ThemeData get lightThemeData => ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme(
      brightness: Brightness.light,
      primary: Color(0xFF4A90E2),
      onPrimary: Colors.white,
      secondary: Color(0xFF50E3C2),
      onSecondary: Colors.black,
      error: Colors.redAccent,
      onError: Colors.white,
      surface: Color(0xFFF7F9FC),
      onSurface: Colors.black87,
      outlineVariant: Colors.grey.shade300,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: Color(0xFF4A90E2),
      foregroundColor: Colors.white,
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: Color(0xFF4A90E2),
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
    ),
  );

  static ThemeData get darkThemeData => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: ColorScheme(
      brightness: Brightness.dark,
      primary: Color(0xFF1F6FEB),
      onPrimary: Colors.white,
      secondary: Color(0xFF00C896),
      onSecondary: Colors.black,
      error: Colors.redAccent,
      onError: Colors.black,
      surface: Color(0xFF0D1117),
      onSurface: Colors.white70,
      outlineVariant: Colors.grey,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: Color(0xFF161B22),
      foregroundColor: Colors.white,
      elevation: 0,
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: Color(0xFF0D1117),
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
    ),
  );
}