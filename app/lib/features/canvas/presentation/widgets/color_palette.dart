import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/colors.dart';
import '../providers/canvas_provider.dart';

/// Color palette widget for selecting drawing colors
class ColorPalette extends ConsumerWidget {
  const ColorPalette({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final canvasState = ref.watch(canvasProvider);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
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
