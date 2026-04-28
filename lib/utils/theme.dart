import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Brand Colors
  static const Color primaryRed = Color(0xFFFF6B6B);
  static const Color teal = Color(0xFF4ECDC4);
  static const Color blue = Color(0xFF45B7D1);
  static const Color yellow = Color(0xFFF9CA24);
  
  // Neutral Colors
  static const Color darkNavy = Color(0xFF1A1A2E);
  static const Color lightGray = Color(0xFFF8F9FA);
  static const Color mediumGray = Color(0xFF6C757D);
  static const Color borderGray = Color(0xFFE9ECEF);
  static const Color white = Color(0xFFFFFFFF);

  // Existing Dark Mode Colors (Kept as requested)
  static const Color darkPrimary = Color(0xFFD4AF37); 
  static const Color darkSurface = Color(0xFF1E1E1E);
  static const Color darkBackground = Color(0xFF121212);
  static const Color darkSecondary = Color(0xFFE5C76B);

  // Light Theme
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: primaryRed,
      scaffoldBackgroundColor: lightGray,
      colorScheme: const ColorScheme.light(
        primary: primaryRed,
        secondary: teal,
        surface: white,
        onSurface: darkNavy,
      ),
      textTheme: GoogleFonts.poppinsTextTheme().copyWith(
        displayLarge: const TextStyle(color: darkNavy, fontWeight: FontWeight.bold, fontSize: 28),
        displayMedium: const TextStyle(color: darkNavy, fontWeight: FontWeight.bold, fontSize: 20),
        bodyLarge: const TextStyle(color: darkNavy, fontWeight: FontWeight.w500, fontSize: 16),
        bodyMedium: const TextStyle(color: darkNavy, fontWeight: FontWeight.normal, fontSize: 14),
        bodySmall: const TextStyle(color: mediumGray, fontWeight: FontWeight.normal, fontSize: 12),
        labelSmall: const TextStyle(color: mediumGray, fontWeight: FontWeight.normal, fontSize: 10),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: lightGray,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.poppins(
          color: darkNavy,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        iconTheme: const IconThemeData(color: darkNavy),
      ),
      navigationBarTheme: NavigationBarThemeData(
        height: 60,
        backgroundColor: white,
        indicatorColor: Colors.transparent,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600, color: primaryRed);
          }
          return GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w500, color: mediumGray);
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: primaryRed, size: 24);
          }
          return const IconThemeData(color: mediumGray, size: 24);
        }),
      ),
    );
  }

  // Dark Theme
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: darkPrimary,
      scaffoldBackgroundColor: darkBackground,
      colorScheme: const ColorScheme.dark(
        primary: darkPrimary,
        secondary: darkSecondary,
        surface: darkSurface,
        onSurface: Colors.white,
      ),
      textTheme: GoogleFonts.poppinsTextTheme().copyWith(
        displayLarge: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 28),
        displayMedium: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
        bodyLarge: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500, fontSize: 16),
        bodyMedium: const TextStyle(color: Colors.white, fontWeight: FontWeight.normal, fontSize: 14),
        bodySmall: const TextStyle(color: Colors.white70, fontWeight: FontWeight.normal, fontSize: 12),
        labelSmall: const TextStyle(color: Colors.white60, fontWeight: FontWeight.normal, fontSize: 10),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: darkBackground,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.poppins(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      navigationBarTheme: NavigationBarThemeData(
        height: 60,
        backgroundColor: darkSurface,
        indicatorColor: Colors.transparent,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600, color: darkPrimary);
          }
          return GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.white70);
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: darkPrimary, size: 24);
          }
          return const IconThemeData(color: Colors.white70, size: 24);
        }),
      ),
    );
  }
}
