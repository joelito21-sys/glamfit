import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

/// Single source of truth for translating domain data (category names,
/// color names) into visual representations.
///
/// Extracted from the widget layer so it can be reused by other screens
/// and unit-tested independently (SRP: presentation mapping ≠ layout).
abstract final class GownVisuals {
  static const Map<String, IconData> _categoryIcons = {
    'Wedding': Icons.favorite_rounded,
    'Evening': Icons.nightlight_round,
    'Debut': Icons.auto_awesome,
    'Prom': Icons.school_rounded,
    'Cocktail': Icons.wine_bar_rounded,
    'Filipiniana': Icons.local_florist_rounded,
  };

  static const Map<String, Color> _colorChipColors = {
    'ivory': AppColors.ivory,
    'white': AppColors.ivory,
    'ecru': AppColors.ivory,
    'off-white': AppColors.ivory,
    'champagne': AppColors.accent,
    'blush': AppColors.accent,
    'light pink': AppColors.accent,
    'emerald': Colors.green,
    'navy': Color(0xFF000080),
    'burgundy': Colors.purple,
    'black': Colors.black,
    'red': Colors.red,
    'lavender': AppColors.primaryLight,
    'powder blue': AppColors.primaryLight,
    'sage': AppColors.primaryLight,
    'pink': AppColors.error,
  };

  static IconData iconForCategory(String category) =>
      _categoryIcons[category] ?? Icons.checkroom_rounded;

  static Color chipColorFor(String colorName) =>
      _colorChipColors[colorName.toLowerCase()] ?? AppColors.primary;
}
