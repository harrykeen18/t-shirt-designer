import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/utils/image_utils.dart';
import '../../../canvas/presentation/providers/canvas_provider.dart';

/// Widget that displays the pixel art design on a t-shirt mockup
class TshirtMockup extends ConsumerStatefulWidget {
  const TshirtMockup({super.key});

  @override
  ConsumerState<TshirtMockup> createState() => _TshirtMockupState();
}

class _TshirtMockupState extends ConsumerState<TshirtMockup> {
  ui.Image? _designImage;

  @override
  void initState() {
    super.initState();
    _generateDesignImage();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _generateDesignImage();
  }

  Future<void> _generateDesignImage() async {
    final canvasState = ref.read(canvasProvider);
    final image = await ImageUtils.canvasToPreviewImage(canvasState.pixels);
    if (mounted) {
      setState(() {
        _designImage = image;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final canvasState = ref.watch(canvasProvider);
    final tshirtColor =
        AppColors.tshirtColors[canvasState.selectedTshirtColorIndex];

    // Regenerate design image when canvas changes
    ref.listen<CanvasState>(canvasProvider, (previous, next) {
      if (previous?.pixels != next.pixels) {
        _generateDesignImage();
      }
    });

    return Column(
      children: [
        // T-shirt mockup
        Expanded(
          child: Center(
            child: AspectRatio(
              aspectRatio: 0.85,
              child: CustomPaint(
                painter: TshirtMockupPainter(
                  tshirtColor: tshirtColor,
                  designImage: _designImage,
                ),
                size: Size.infinite,
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        // T-shirt color selector
        _TshirtColorSelector(
          selectedIndex: canvasState.selectedTshirtColorIndex,
          onColorSelected: (index) {
            ref.read(canvasProvider.notifier).selectTshirtColor(index);
          },
        ),
      ],
    );
  }
}

class _TshirtColorSelector extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onColorSelected;

  const _TshirtColorSelector({
    required this.selectedIndex,
    required this.onColorSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          'T-Shirt Color: ${AppColors.tshirtColorNames[selectedIndex]}',
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            AppColors.tshirtColors.length,
            (index) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: GestureDetector(
                onTap: () => onColorSelected(index),
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.tshirtColors[index],
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: selectedIndex == index
                          ? Theme.of(context).colorScheme.primary
                          : Colors.grey.shade300,
                      width: selectedIndex == index ? 3 : 1,
                    ),
                    boxShadow: [
                      if (selectedIndex == index)
                        BoxShadow(
                          color: Theme.of(context)
                              .colorScheme
                              .primary
                              .withOpacity(0.3),
                          blurRadius: 8,
                          spreadRadius: 1,
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// CustomPainter that draws the t-shirt mockup with the design overlay
class TshirtMockupPainter extends CustomPainter {
  final Color tshirtColor;
  final ui.Image? designImage;

  TshirtMockupPainter({
    required this.tshirtColor,
    this.designImage,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();

    // T-shirt dimensions
    final shirtWidth = size.width * 0.9;
    final shirtHeight = size.height * 0.95;
    final shirtLeft = (size.width - shirtWidth) / 2;
    final shirtTop = (size.height - shirtHeight) / 2;

    // Draw t-shirt body
    paint.color = tshirtColor;
    final shirtPath = Path();

    // T-shirt shape (simplified)
    final neckWidth = shirtWidth * 0.25;
    final neckDepth = shirtHeight * 0.08;
    final shoulderWidth = shirtWidth * 0.15;
    final armLength = shirtHeight * 0.25;
    final armWidth = shirtWidth * 0.18;

    // Start at left shoulder
    shirtPath.moveTo(shirtLeft, shirtTop + neckDepth);

    // Left sleeve
    shirtPath.lineTo(shirtLeft - armWidth, shirtTop + neckDepth);
    shirtPath.lineTo(shirtLeft - armWidth, shirtTop + neckDepth + armLength);
    shirtPath.lineTo(shirtLeft, shirtTop + neckDepth + armLength * 0.8);

    // Left side down
    shirtPath.lineTo(shirtLeft, shirtTop + shirtHeight);

    // Bottom
    shirtPath.lineTo(shirtLeft + shirtWidth, shirtTop + shirtHeight);

    // Right side up
    shirtPath.lineTo(shirtLeft + shirtWidth, shirtTop + neckDepth + armLength * 0.8);

    // Right sleeve
    shirtPath.lineTo(shirtLeft + shirtWidth + armWidth, shirtTop + neckDepth + armLength);
    shirtPath.lineTo(shirtLeft + shirtWidth + armWidth, shirtTop + neckDepth);
    shirtPath.lineTo(shirtLeft + shirtWidth, shirtTop + neckDepth);

    // Neck curve (right side)
    final neckCenter = Offset(shirtLeft + shirtWidth / 2, shirtTop);
    shirtPath.quadraticBezierTo(
      shirtLeft + shirtWidth * 0.75,
      shirtTop,
      neckCenter.dx + neckWidth / 2,
      shirtTop + neckDepth * 0.3,
    );

    // Neck bottom
    shirtPath.quadraticBezierTo(
      neckCenter.dx,
      shirtTop + neckDepth,
      neckCenter.dx - neckWidth / 2,
      shirtTop + neckDepth * 0.3,
    );

    // Neck curve (left side)
    shirtPath.quadraticBezierTo(
      shirtLeft + shirtWidth * 0.25,
      shirtTop,
      shirtLeft,
      shirtTop + neckDepth,
    );

    shirtPath.close();

    // Draw shadow
    paint.color = Colors.black.withOpacity(0.1);
    canvas.save();
    canvas.translate(4, 4);
    canvas.drawPath(shirtPath, paint);
    canvas.restore();

    // Draw t-shirt
    paint.color = tshirtColor;
    canvas.drawPath(shirtPath, paint);

    // Draw border
    final borderPaint = Paint()
      ..color = Colors.grey.shade400
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawPath(shirtPath, borderPaint);

    // Draw design on chest area
    if (designImage != null) {
      final designSize = shirtWidth * 0.45;
      final designLeft = shirtLeft + (shirtWidth - designSize) / 2;
      final designTop = shirtTop + shirtHeight * 0.22;

      // Draw design with slight shadow
      canvas.drawImageRect(
        designImage!,
        Rect.fromLTWH(
            0, 0, designImage!.width.toDouble(), designImage!.height.toDouble()),
        Rect.fromLTWH(designLeft, designTop, designSize, designSize),
        Paint()..filterQuality = FilterQuality.none, // Pixel art crisp
      );
    }
  }

  @override
  bool shouldRepaint(TshirtMockupPainter oldDelegate) {
    return oldDelegate.tshirtColor != tshirtColor ||
        oldDelegate.designImage != designImage;
  }
}
