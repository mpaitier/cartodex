import 'package:flutter/material.dart';

/// Palette de couleurs de l'application, séparée du thème pour
/// pouvoir être réutilisée directement dans des widgets custom.
abstract class AppColors {
  static const Color primary = Color(0xFFE3350D);
  static const Color secondary = Color(0xFF3B4CCA);
  static const Color background = Color(0xFFF5F5F5);
  static const Color backgroundDark = Color(0xFF121212);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceDark = Color(0xFF1E1E1E);
  static const Color error = Color(0xFFB3261E);
}
