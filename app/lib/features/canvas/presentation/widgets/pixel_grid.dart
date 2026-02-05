import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/utils/image_utils.dart';
import '../providers/canvas_provider.dart';

/// Widget that displays and handles interaction with the pixel grid
class PixelGrid extends ConsumerStatefulWidget {
  const PixelGrid({super.key});

  @override
  ConsumerState<PixelGrid> createState() => _PixelGridState();
}

class _PixelGridState extends ConsumerState<PixelGrid> {
  bool _isDrawing = false;

  @override
  Widget build(BuildContext context) {
    final canvasState = ref.watch(canvasProvider);

    return LayoutBuilder(
      builder: (context, constraints) {
        // Make grid square and fit within constraints
        final size = constraints.maxWidth < constraints.maxHeight
            ? constraints.maxWidth
            : constraints.maxHeight;

        return Center(
          child: GestureDetector(
            onPanStart: (details) => _handlePanStart(details, size),
            onPanUpdate: (details) => _handlePanUpdate(details, size),
            onPanEnd: (_) => _handlePanEnd(),
            onTapDown: (details) => _handleTap(details, size),
            child: Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300, width: 2),
                color: canvasState.backgroundColor,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: CustomPaint(
                painter: PixelGridPainter(
                  pixels: canvasState.pixels,
                  gridSize: ImageUtils.gridSize,
                  backgroundColor: canvasState.backgroundColor,
                ),
                size: Size(size, size),
              ),
            ),
          ),
        );
      },
    );
  }

  (int, int)? _getGridPosition(Offset localPosition, double gridWidgetSize) {
    final pixelSize = gridWidgetSize / ImageUtils.gridSize;
    final x = (localPosition.dx / pixelSize).floor();
    final y = (localPosition.dy / pixelSize).floor();

    if (x >= 0 &&
        x < ImageUtils.gridSize &&
        y >= 0 &&
        y < ImageUtils.gridSize) {
      return (x, y);
    }
    return null;
  }

  void _handleTap(TapDownDetails details, double size) {
    final pos = _getGridPosition(details.localPosition, size);
    if (pos != null) {
      ref.read(canvasProvider.notifier).drawPixel(pos.$1, pos.$2);
    }
  }

  void _handlePanStart(DragStartDetails details, double size) {
    _isDrawing = true;
    ref.read(canvasProvider.notifier).startStroke();
    final pos = _getGridPosition(details.localPosition, size);
    if (pos != null) {
      ref
          .read(canvasProvider.notifier)
          .drawPixelDuringPan(pos.$1, pos.$2);
    }
  }

  void _handlePanUpdate(DragUpdateDetails details, double size) {
    if (!_isDrawing) return;
    final pos = _getGridPosition(details.localPosition, size);
    if (pos != null) {
      ref
          .read(canvasProvider.notifier)
          .drawPixelDuringPan(pos.$1, pos.$2);
    }
  }

  void _handlePanEnd() {
    _isDrawing = false;
  }
}

/// CustomPainter that renders the pixel grid
class PixelGridPainter extends CustomPainter {
  final List<List<Color>> pixels;
  final int gridSize;
  final Color backgroundColor;

  PixelGridPainter({
    required this.pixels,
    required this.gridSize,
    required this.backgroundColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final pixelSize = size.width / gridSize;
    final paint = Paint();

    // Choose grid line color based on background brightness
    final bgBrightness = backgroundColor.computeLuminance();
    final gridPaint = Paint()
      ..color = bgBrightness > 0.5 ? Colors.grey.shade300 : Colors.grey.shade600
      ..strokeWidth = 0.5
      ..style = PaintingStyle.stroke;

    // Draw pixels
    for (int y = 0; y < gridSize; y++) {
      for (int x = 0; x < gridSize; x++) {
        final color = pixels[y][x];
        if (color.alpha > 0) {
          paint.color = color;
          canvas.drawRect(
            Rect.fromLTWH(
              x * pixelSize,
              y * pixelSize,
              pixelSize,
              pixelSize,
            ),
            paint,
          );
        }
      }
    }

    // Draw grid lines
    for (int i = 0; i <= gridSize; i++) {
      // Vertical lines
      canvas.drawLine(
        Offset(i * pixelSize, 0),
        Offset(i * pixelSize, size.height),
        gridPaint,
      );
      // Horizontal lines
      canvas.drawLine(
        Offset(0, i * pixelSize),
        Offset(size.width, i * pixelSize),
        gridPaint,
      );
    }
  }

  @override
  bool shouldRepaint(PixelGridPainter oldDelegate) {
    return oldDelegate.pixels != pixels ||
        oldDelegate.backgroundColor != backgroundColor;
  }
}
