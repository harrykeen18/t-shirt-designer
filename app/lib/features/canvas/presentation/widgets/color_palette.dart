import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/colors.dart';
import '../providers/canvas_provider.dart';

/// Color palette widget for selecting drawing colors
class ColorPalette extends ConsumerWidget {
  final bool centered;
  final bool compact;

  const ColorPalette({super.key, this.centered = false, this.compact = false});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final canvasState = ref.watch(canvasProvider);

    if (compact) {
      return _buildCompactLayout(context, ref, canvasState);
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment:
          centered ? CrossAxisAlignment.center : CrossAxisAlignment.start,
      children: [
        // Tool toggle (Brush/Eraser)
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _ToolButton(
              icon: Icons.brush,
              label: 'Brush',
              isSelected: canvasState.tool == DrawingTool.brush,
              onTap: () =>
                  ref.read(canvasProvider.notifier).setTool(DrawingTool.brush),
            ),
            const SizedBox(width: 8),
            _ToolButton(
              icon: Icons.auto_fix_high,
              label: 'Eraser',
              isSelected: canvasState.tool == DrawingTool.eraser,
              onTap: () =>
                  ref.read(canvasProvider.notifier).setTool(DrawingTool.eraser),
            ),
          ],
        ),
        const SizedBox(height: 16),
        // Color palette - grid of squares like background selector
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: List.generate(AppColors.paletteColors.length, (index) {
            final color = AppColors.paletteColors[index];
            final isSelected = canvasState.selectedColor == color &&
                canvasState.tool == DrawingTool.brush;
            return GestureDetector(
              onTap: () =>
                  ref.read(canvasProvider.notifier).selectColor(color),
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: color,
                  border: Border.all(
                    color: isSelected
                        ? Theme.of(context).colorScheme.primary
                        : Colors.grey.shade300,
                    width: isSelected ? 2.5 : 1,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }

  /// Compact layout: tools stacked vertically on the left, colors in grid on the right
  Widget _buildCompactLayout(BuildContext context, WidgetRef ref, CanvasState canvasState) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Tool buttons stacked vertically
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _CompactToolButton(
              icon: Icons.brush,
              isSelected: canvasState.tool == DrawingTool.brush,
              onTap: () =>
                  ref.read(canvasProvider.notifier).setTool(DrawingTool.brush),
            ),
            const SizedBox(height: 8),
            _CompactToolButton(
              icon: Icons.auto_fix_high,
              isSelected: canvasState.tool == DrawingTool.eraser,
              onTap: () =>
                  ref.read(canvasProvider.notifier).setTool(DrawingTool.eraser),
            ),
          ],
        ),
        const SizedBox(width: 12),
        // Color palette in a constrained width to force 2 rows
        SizedBox(
          width: 280,
          child: Wrap(
            spacing: 6,
            runSpacing: 6,
            children: List.generate(AppColors.paletteColors.length, (index) {
              final color = AppColors.paletteColors[index];
              final isSelected = canvasState.selectedColor == color &&
                  canvasState.tool == DrawingTool.brush;
              return GestureDetector(
                onTap: () =>
                    ref.read(canvasProvider.notifier).selectColor(color),
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: color,
                    border: Border.all(
                      color: isSelected
                          ? Theme.of(context).colorScheme.primary
                          : Colors.grey.shade300,
                      width: isSelected ? 2.5 : 1,
                    ),
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              );
            }),
          ),
        ),
      ],
    );
  }
}

class _CompactToolButton extends StatelessWidget {
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _CompactToolButton({
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).colorScheme.primary
              : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          color: isSelected ? Colors.white : Colors.grey.shade700,
          size: 22,
        ),
      ),
    );
  }
}

class _ToolButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _ToolButton({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).colorScheme.primary
              : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : Colors.grey.shade700,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.grey.shade700,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
