import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color primaryGreen = Color(0xFF1B5E20);
  static const Color primaryGreenLight = Color(0xFF2E7D32);
  static const Color gold = Color(0xFFD4AF37);
  static const Color goldLight = Color(0xFFF0D060);
  static const Color cream = Color(0xFFFFF8F0);
  static const Color darkBg = Color(0xFF121212);
  static const Color darkCard = Color(0xFF1E1E1E);
  static const Color darkGreen = Color(0xFF0D3B0E);

  static TextStyle _arabicStyle({double? size, Color? color, FontWeight? weight}) {
    return GoogleFonts.notoNaskhArabic(
      textStyle: TextStyle(
        fontSize: size ?? 16,
        color: color ?? Colors.black87,
        fontWeight: weight ?? FontWeight.w400,
        height: 1.4,
      ),
    );
  }

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: primaryGreen,
      scaffoldBackgroundColor: cream,
      colorScheme: const ColorScheme.light(
        primary: primaryGreen,
        secondary: gold,
        surface: cream,
        onPrimary: Colors.white,
        onSecondary: Colors.black87,
        onSurface: Colors.black87,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: primaryGreen,
        foregroundColor: Colors.white,
        elevation: 2,
        centerTitle: true,
        titleTextStyle: _arabicStyle(
          size: 22,
          color: Colors.white,
          weight: FontWeight.bold,
        ),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
      ),
      cardTheme: CardTheme(
        elevation: 6,
        shadowColor: primaryGreen.withValues(alpha: 0.3),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: gold.withValues(alpha: 0.3), width: 1),
        ),
        color: Colors.white,
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      ),
      textTheme: TextTheme(
        headlineLarge: _arabicStyle(size: 28, weight: FontWeight.bold, color: primaryGreen),
        headlineMedium: _arabicStyle(size: 22, weight: FontWeight.bold, color: primaryGreen),
        titleLarge: _arabicStyle(size: 20, weight: FontWeight.bold),
        titleMedium: _arabicStyle(size: 18, weight: FontWeight.w600),
        bodyLarge: _arabicStyle(size: 16),
        bodyMedium: _arabicStyle(size: 14),
        labelLarge: _arabicStyle(size: 14, weight: FontWeight.w600),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: primaryGreen,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: primaryGreen,
        inactiveTrackColor: primaryGreen.withValues(alpha: 0.2),
        thumbColor: gold,
        overlayColor: gold.withValues(alpha: 0.2),
        trackHeight: 4,
        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
      ),
      dividerTheme: DividerThemeData(
        color: gold.withValues(alpha: 0.3),
        thickness: 1,
        space: 1,
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: gold,
        foregroundColor: Colors.white,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: primaryGreen.withValues(alpha: 0.3)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: primaryGreen.withValues(alpha: 0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: gold, width: 2),
        ),
        hintStyle: _arabicStyle(size: 14, color: Colors.grey),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      ),
      iconTheme: const IconThemeData(
        color: gold,
        size: 24,
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: darkGreen,
      scaffoldBackgroundColor: darkBg,
      colorScheme: const ColorScheme.dark(
        primary: Color(0xFF4CAF50),
        secondary: gold,
        surface: darkBg,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: Colors.white,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: darkGreen,
        foregroundColor: Colors.white,
        elevation: 2,
        centerTitle: true,
        titleTextStyle: _arabicStyle(
          size: 22,
          color: Colors.white,
          weight: FontWeight.bold,
        ),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
      ),
      cardTheme: CardTheme(
        elevation: 6,
        shadowColor: Colors.black54,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: gold.withValues(alpha: 0.2), width: 1),
        ),
        color: darkCard,
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      ),
      textTheme: TextTheme(
        headlineLarge: _arabicStyle(size: 28, weight: FontWeight.bold, color: goldLight),
        headlineMedium: _arabicStyle(size: 22, weight: FontWeight.bold, color: goldLight),
        titleLarge: _arabicStyle(size: 20, weight: FontWeight.bold, color: Colors.white),
        titleMedium: _arabicStyle(size: 18, weight: FontWeight.w600, color: Colors.white70),
        bodyLarge: _arabicStyle(size: 16, color: Colors.white70),
        bodyMedium: _arabicStyle(size: 14, color: Colors.white60),
        labelLarge: _arabicStyle(size: 14, weight: FontWeight.w600, color: goldLight),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: darkCard,
        selectedItemColor: Color(0xFF4CAF50),
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: const Color(0xFF4CAF50),
        inactiveTrackColor: const Color(0xFF4CAF50).withValues(alpha: 0.2),
        thumbColor: gold,
        overlayColor: gold.withValues(alpha: 0.2),
        trackHeight: 4,
        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
      ),
      dividerTheme: DividerThemeData(
        color: gold.withValues(alpha: 0.2),
        thickness: 1,
        space: 1,
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: gold,
        foregroundColor: Colors.black,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: darkCard,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: const Color(0xFF4CAF50).withValues(alpha: 0.3)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: const Color(0xFF4CAF50).withValues(alpha: 0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: gold, width: 2),
        ),
        hintStyle: _arabicStyle(size: 14, color: Colors.grey),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      ),
      iconTheme: const IconThemeData(
        color: gold,
        size: 24,
      ),
    );
  }
}
