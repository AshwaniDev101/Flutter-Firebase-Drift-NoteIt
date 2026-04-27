import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:noteit/core/theme/note_theme.dart';

class Themes {
  static ThemeData get lightThemeData => ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme(
      brightness: Brightness.light,
      primary: Color(0xFF5B7CFA),
      onPrimary: Colors.white,
      secondary: Color(0xFFFFC857),
      onSecondary: Colors.black,
      error: Colors.redAccent,
      onError: Colors.white,
      surface: Color(0xFFF8F9FD),
      onSurface: Colors.black87,
      outlineVariant: Colors.grey.shade300,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: Color(0xFF5B7CFA),
      foregroundColor: Colors.white,
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: Color(0xFF5B7CFA),
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
    ),
    extensions: const [
      NoteTheme(
        appBar: Color(0xFF5B7CFA),
        selectedAppBar: Color(0xFF3F5AE0),
        cardBackground: Colors.white,
        cardTitle: Color(0xFF1C1C1E),
        cardContent: Color(0xFF6B7280),
        titleText: Color(0xFF111827),
        contentText: Color(0xFF374151),
        actionButton: Color(0xFFFFC857),
      )
    ],
  );

  static ThemeData get darkThemeData => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: ColorScheme(
      brightness: Brightness.dark,
      primary: Color(0xFF7AA2FF),
      onPrimary: Colors.black,
      secondary: Color(0xFFFFC857),
      onSecondary: Colors.black,
      error: Colors.redAccent,
      onError: Colors.black,
      surface: Color(0xFF0F172A),
      onSurface: Colors.white70,
      outlineVariant: Colors.grey,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: Color(0xFF111827),
      foregroundColor: Colors.white,
      elevation: 0,
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: Color(0xFF0F172A),
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
    ),
    extensions: const [
      NoteTheme(
        appBar: Color(0xFF111827),
        selectedAppBar: Color(0xFF1F2937),
        cardBackground: Color(0xFF57709C),
        cardTitle: Colors.white,
        cardContent: Color(0xFF9CA3AF),
        titleText: Colors.white,
        contentText: Color(0xFFD1D5DB),
        actionButton: Color(0xFFFFC857),
      )
    ],
  );
}