// Run with: dart run generate_icons.dart
// Generates app icons for iOS and Android

import 'dart:io';
import 'package:image/image.dart' as img;

void main() async {
  print('Generating app icons...');

  // Create a 1024x1024 base icon
  final icon = img.Image(width: 1024, height: 1024);

  // Background - purple gradient effect (solid for simplicity)
  final bgColor = img.ColorRgba8(103, 80, 164, 255); // #6750A4
  img.fill(icon, color: bgColor);

  // Draw a white t-shirt silhouette
  final white = img.ColorRgba8(255, 255, 255, 255);

  // T-shirt body (centered, simplified)
  final centerX = 512;
  final centerY = 540;
  final shirtWidth = 500;
  final shirtHeight = 450;

  // Draw t-shirt shape using filled rectangles and triangles
  // Main body
  for (int y = centerY - 100; y < centerY + shirtHeight ~/ 2; y++) {
    for (int x = centerX - shirtWidth ~/ 2 + 50; x < centerX + shirtWidth ~/ 2 - 50; x++) {
      icon.setPixel(x, y, white);
    }
  }

  // Left sleeve
  for (int y = centerY - 100; y < centerY + 80; y++) {
    int sleeveWidth = 120 - ((y - (centerY - 100)) ~/ 3);
    for (int x = centerX - shirtWidth ~/ 2 - sleeveWidth + 50; x < centerX - shirtWidth ~/ 2 + 50; x++) {
      if (x >= 0 && x < 1024) icon.setPixel(x, y, white);
    }
  }

  // Right sleeve
  for (int y = centerY - 100; y < centerY + 80; y++) {
    int sleeveWidth = 120 - ((y - (centerY - 100)) ~/ 3);
    for (int x = centerX + shirtWidth ~/ 2 - 50; x < centerX + shirtWidth ~/ 2 + sleeveWidth - 50; x++) {
      if (x >= 0 && x < 1024) icon.setPixel(x, y, white);
    }
  }

  // Neck cutout (purple circle)
  img.fillCircle(icon, x: centerX, y: centerY - 100, radius: 60, color: bgColor);

  // Draw a 4x4 pixel grid on the shirt (representing pixel art)
  final gridColors = [
    img.ColorRgba8(229, 57, 53, 255),   // Red
    img.ColorRgba8(255, 152, 0, 255),   // Orange
    img.ColorRgba8(76, 175, 80, 255),   // Green
    img.ColorRgba8(33, 150, 243, 255),  // Blue
  ];

  final pixelSize = 45;
  final gridStartX = centerX - (pixelSize * 2);
  final gridStartY = centerY + 20;

  for (int row = 0; row < 4; row++) {
    for (int col = 0; col < 4; col++) {
      final colorIndex = (row + col) % 4;
      final px = gridStartX + col * pixelSize;
      final py = gridStartY + row * pixelSize;

      for (int y = py; y < py + pixelSize - 2; y++) {
        for (int x = px; x < px + pixelSize - 2; x++) {
          icon.setPixel(x, y, gridColors[colorIndex]);
        }
      }
    }
  }

  // Save the base icon
  final baseIconPath = 'assets/app_icon.png';
  await File(baseIconPath).writeAsBytes(img.encodePng(icon));
  print('Created: $baseIconPath');

  // iOS icon sizes
  final iosSizes = {
    'Icon-App-20x20@1x.png': 20,
    'Icon-App-20x20@2x.png': 40,
    'Icon-App-20x20@3x.png': 60,
    'Icon-App-29x29@1x.png': 29,
    'Icon-App-29x29@2x.png': 58,
    'Icon-App-29x29@3x.png': 87,
    'Icon-App-40x40@1x.png': 40,
    'Icon-App-40x40@2x.png': 80,
    'Icon-App-40x40@3x.png': 120,
    'Icon-App-60x60@2x.png': 120,
    'Icon-App-60x60@3x.png': 180,
    'Icon-App-76x76@1x.png': 76,
    'Icon-App-76x76@2x.png': 152,
    'Icon-App-83.5x83.5@2x.png': 167,
    'Icon-App-1024x1024@1x.png': 1024,
  };

  final iosIconDir = 'ios/Runner/Assets.xcassets/AppIcon.appiconset';

  for (final entry in iosSizes.entries) {
    final resized = img.copyResize(icon, width: entry.value, height: entry.value, interpolation: img.Interpolation.average);
    final path = '$iosIconDir/${entry.key}';
    await File(path).writeAsBytes(img.encodePng(resized));
    print('Created: $path');
  }

  // Android icon sizes
  final androidSizes = {
    'mipmap-mdpi': 48,
    'mipmap-hdpi': 72,
    'mipmap-xhdpi': 96,
    'mipmap-xxhdpi': 144,
    'mipmap-xxxhdpi': 192,
  };

  for (final entry in androidSizes.entries) {
    final resized = img.copyResize(icon, width: entry.value, height: entry.value, interpolation: img.Interpolation.average);
    final path = 'android/app/src/main/res/${entry.key}/ic_launcher.png';
    await File(path).writeAsBytes(img.encodePng(resized));
    print('Created: $path');
  }

  print('\nDone! App icons generated successfully.');
}
