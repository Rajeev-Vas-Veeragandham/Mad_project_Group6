import 'package:flutter/material.dart';

class AppTheme {
  static const Color primaryColor = Color(0xFF2E8B57);
  static const Color secondaryColor = Color(0xFFFF6B6B);
  static const Color accentColor = Color(0xFFFFD166);
  static const Color backgroundColor = Color(0xFFF8F9FA);
  static const Color textColor = Color(0xFF2D3748);
  static const Color subtitleColor = Color(0xFF718096);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      primarySwatch: Colors.green,
      scaffoldBackgroundColor: backgroundColor,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: textColor,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: textColor,
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: secondaryColor,
        foregroundColor: Colors.white,
      ),
    );
  }

  static BoxDecoration get gradientDecoration {
    return BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [primaryColor.withOpacity(0.1), backgroundColor],
      ),
    );
  }

  static BoxShadow get cardShadow {
    return BoxShadow(
      color: Colors.black.withOpacity(0.1),
      blurRadius: 20,
      offset: const Offset(0, 4),
    );
  }
}