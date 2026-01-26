import 'package:flutter/material.dart';

/// 11 curated colors for pixel art drawing
class AppColors {
  AppColors._();

  static const List<Color> paletteColors = [
    Color(0xFF000000), // Black
    Color(0xFFFFFFFF), // White
    Color(0xFFE53935), // Red
    Color(0xFFFF9800), // Orange
    Color(0xFFFFEB3B), // Yellow
    Color(0xFF4CAF50), // Green
    Color(0xFF2196F3), // Blue
    Color(0xFF9C27B0), // Purple
    Color(0xFFE91E63), // Pink
    Color(0xFF795548), // Brown
    Color(0xFF9E9E9E), // Gray
  ];

  static const List<String> colorNames = [
    'Black',
    'White',
    'Red',
    'Orange',
    'Yellow',
    'Green',
    'Blue',
    'Purple',
    'Pink',
    'Brown',
    'Gray',
  ];

  /// Default canvas background (transparent/white)
  static const Color canvasBackground = Color(0xFFFFFFFF);

  /// T-shirt mockup colors
  static const List<Color> tshirtColors = [
    Color(0xFFFFFFFF), // White
    Color(0xFF000000), // Black
    Color(0xFF1A237E), // Navy
    Color(0xFF424242), // Charcoal
    Color(0xFFE53935), // Red
  ];

  static const List<String> tshirtColorNames = [
    'White',
    'Black',
    'Navy',
    'Charcoal',
    'Red',
  ];
}
