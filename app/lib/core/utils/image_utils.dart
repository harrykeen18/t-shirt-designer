import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;

/// Utility class for canvas image operations
class ImageUtils {
  ImageUtils._();

  /// Grid size for pixel art
  static const int gridSize = 20;

  /// Output size for high-quality print (100x upscale)
  static const int outputSize = 2000;

  /// Pixel size in output image
  static const int outputPixelSize = outputSize ~/ gridSize; // 100px per pixel

  /// Convert canvas state to high-resolution PNG bytes
  static Future<Uint8List> canvasToPng(List<List<Color>> pixels) async {
    // Create a high-res image using the image package
    final image = img.Image(width: outputSize, height: outputSize);

    // Fill with each pixel color, scaled up
    for (int y = 0; y < gridSize; y++) {
      for (int x = 0; x < gridSize; x++) {
        final color = pixels[y][x];
        final imgColor = img.ColorRgba8(
          color.red,
          color.green,
          color.blue,
          color.alpha,
        );

        // Fill the scaled pixel area
        for (int py = 0; py < outputPixelSize; py++) {
          for (int px = 0; px < outputPixelSize; px++) {
            final outX = x * outputPixelSize + px;
            final outY = y * outputPixelSize + py;
            image.setPixel(outX, outY, imgColor);
          }
        }
      }
    }

    // Encode as PNG
    return Uint8List.fromList(img.encodePng(image));
  }

  /// Convert canvas state to preview image (lower resolution for display)
  static Future<ui.Image> canvasToPreviewImage(
    List<List<Color>> pixels, {
    int previewSize = 400,
  }) async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final pixelSize = previewSize / gridSize;

    for (int y = 0; y < gridSize; y++) {
      for (int x = 0; x < gridSize; x++) {
        final color = pixels[y][x];
        if (color.alpha > 0) {
          canvas.drawRect(
            Rect.fromLTWH(
              x * pixelSize,
              y * pixelSize,
              pixelSize,
              pixelSize,
            ),
            Paint()..color = color,
          );
        }
      }
    }

    final picture = recorder.endRecording();
    return picture.toImage(previewSize, previewSize);
  }

  /// Create an empty canvas (transparent white)
  static List<List<Color>> createEmptyCanvas() {
    return List.generate(
      gridSize,
      (_) => List.generate(gridSize, (_) => Colors.transparent),
    );
  }
}
