import 'package:flutter/material.dart';

class AppColors {
  // Brand Core Colors
  static const Color primary = Color(0xFF6366F1); // Indigo
  static const Color primaryDark = Color(0xFF4F46E5);
  static const Color secondary = Color(0xFF14B8A6); // Teal
  
  // Light Mode Colors
  static const Color bgLight = Color(0xFFF8FAFC); // Slate 50
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color cardLight = Color(0xFFFFFFFF);
  static const Color textPrimaryLight = Color(0xFF0F172A); // Slate 900
  static const Color textSecondaryLight = Color(0xFF64748B); // Slate 500
  static const Color borderLight = Color(0xFFE2E8F0); // Slate 200

  // Dark Mode Colors
  static const Color bgDark = Color(0xFF090D16); // Ultra Dark Blue/Gray
  static const Color surfaceDark = Color(0xFF151D30); // Slate Blue/Dark
  static const Color cardDark = Color(0xFF151D30);
  static const Color textPrimaryDark = Color(0xFFF8FAFC); // Slate 50
  static const Color textSecondaryDark = Color(0xFF94A3B8); // Slate 400
  static const Color borderDark = Color(0xFF222F4D); // Slate 700ish

  // Task Priority Colors
  static const Color priorityHigh = Color(0xFFEF4444); // Red/Coral
  static const Color priorityMedium = Color(0xFFF59E0B); // Amber
  static const Color priorityLow = Color(0xFF10B981); // Emerald

  // Task Category Colors
  static const Map<String, Color> categories = {
    'Work': Color(0xFF6366F1),    // Indigo
    'Design': Color(0xFF8B5CF6),  // Purple
    'Meeting': Color(0xFFEC4899), // Pink
    'Personal': Color(0xFF14B8A6),// Teal
    'Urgent': Color(0xFFF97316),  // Orange
    'Other': Color(0xFF64748B),   // Slate
  };

  static Color getPriorityColor(String priority) {
    switch (priority) {
      case 'High':
        return priorityHigh;
      case 'Medium':
        return priorityMedium;
      case 'Low':
      default:
        return priorityLow;
    }
  }

  static Color getCategoryColor(String category) {
    return categories[category] ?? categories['Other']!;
  }
}

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        surface: AppColors.surfaceLight,
        error: Colors.redAccent,
      ),
      scaffoldBackgroundColor: AppColors.bgLight,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.bgLight,
        elevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: AppColors.textPrimaryLight),
        titleTextStyle: TextStyle(
          color: AppColors.textPrimaryLight,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.cardLight,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.borderLight, width: 1),
        ),
        margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 0),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.surfaceLight,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceLight,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.borderLight, width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.borderLight, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.redAccent, width: 2),
        ),
        labelStyle: const TextStyle(color: AppColors.textSecondaryLight, fontSize: 14),
        floatingLabelStyle: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButtonStyleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.textPrimaryLight,
          side: const BorderSide(color: AppColors.borderLight, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ),
      textTheme: const TextTheme(
        titleLarge: TextStyle(color: AppColors.textPrimaryLight, fontSize: 20, fontWeight: FontWeight.bold),
        titleMedium: TextStyle(color: AppColors.textPrimaryLight, fontSize: 16, fontWeight: FontWeight.w600),
        bodyLarge: TextStyle(color: AppColors.textPrimaryLight, fontSize: 15),
        bodyMedium: TextStyle(color: AppColors.textSecondaryLight, fontSize: 14),
        labelLarge: TextStyle(color: AppColors.textSecondaryLight, fontSize: 12, fontWeight: FontWeight.bold),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        surface: AppColors.surfaceDark,
        error: Colors.redAccent,
      ),
      scaffoldBackgroundColor: AppColors.bgDark,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.bgDark,
        elevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: AppColors.textPrimaryDark),
        titleTextStyle: TextStyle(
          color: AppColors.textPrimaryDark,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.cardDark,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.borderDark, width: 1),
        ),
        margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 0),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.surfaceDark,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Color(0xFF1E293B), // Darker slate
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.borderDark, width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.borderDark, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.redAccent, width: 2),
        ),
        labelStyle: const TextStyle(color: AppColors.textSecondaryDark, fontSize: 14),
        floatingLabelStyle: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButtonStyleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.textPrimaryDark,
          side: const BorderSide(color: AppColors.borderDark, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ),
      textTheme: const TextTheme(
        titleLarge: TextStyle(color: AppColors.textPrimaryDark, fontSize: 20, fontWeight: FontWeight.bold),
        titleMedium: TextStyle(color: AppColors.textPrimaryDark, fontSize: 16, fontWeight: FontWeight.w600),
        bodyLarge: TextStyle(color: AppColors.textPrimaryDark, fontSize: 15),
        bodyMedium: TextStyle(color: AppColors.textSecondaryDark, fontSize: 14),
        labelLarge: TextStyle(color: AppColors.textSecondaryDark, fontSize: 12, fontWeight: FontWeight.bold),
      ),
    );
  }

  // Convenient helper for standard button styles
  static ButtonStyle ElevatedButtonStyleFrom({
    required Color backgroundColor,
    required Color foregroundColor,
    required double elevation,
    required EdgeInsetsGeometry padding,
    required OutlinedBorder shape,
    required TextStyle textStyle,
  }) {
    return ElevatedButton.styleFrom(
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
      elevation: elevation,
      padding: padding,
      shape: shape,
      textStyle: textStyle,
    );
  }
}
