import 'package:flutter/material.dart';

abstract final class SpaceColors {
  static const canvas = Color(0xFF171715);
  static const surface = Color(0xFF252520);
  static const field = Color(0xFF2D2C26);
  static const sand = Color(0xFFD6BD94);
  static const onSand = Color(0xFF211D17);
  static const text = Color(0xFFF2EEE6);
  static const muted = Color(0xFFC2BCB1);
  static const outline = Color(0xFF49463C);
  static const success = Color(0xFFA8C7A0);
  static const error = Color(0xFFEFA99A);
}

abstract final class SpaceTheme {
  static ThemeData get dark {
    final scheme =
        ColorScheme.fromSeed(
          seedColor: SpaceColors.sand,
          brightness: Brightness.dark,
        ).copyWith(
          primary: SpaceColors.sand,
          onPrimary: SpaceColors.onSand,
          surface: SpaceColors.surface,
          onSurface: SpaceColors.text,
          error: SpaceColors.error,
        );
    return ThemeData(
      brightness: Brightness.dark,
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: SpaceColors.canvas,
      fontFamily: 'Inter',
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.w500,
          letterSpacing: -1.1,
          height: 1.12,
        ),
        headlineMedium: TextStyle(
          fontSize: 25,
          fontWeight: FontWeight.w500,
          letterSpacing: -0.8,
        ),
        titleLarge: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w500,
          letterSpacing: -0.4,
        ),
        titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        bodyLarge: TextStyle(fontSize: 16, height: 1.5),
        bodyMedium: TextStyle(
          fontSize: 14,
          height: 1.5,
          color: SpaceColors.muted,
        ),
        labelLarge: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: SpaceColors.field,
        labelStyle: const TextStyle(color: SpaceColors.muted),
        hintStyle: const TextStyle(color: SpaceColors.muted),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: SpaceColors.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: SpaceColors.sand, width: 1.5),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(54),
          backgroundColor: SpaceColors.sand,
          foregroundColor: SpaceColors.onSand,
          shape: const StadiumBorder(),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      cardTheme: CardThemeData(
        color: SpaceColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
          side: const BorderSide(color: SpaceColors.outline),
        ),
      ),
    );
  }
}
