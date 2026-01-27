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
        // Color palette
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 8,
          runSpacing: 8,
          children: List.generate(
            AppColors.paletteColors.length,
            (index) => _ColorButton(
              color: AppColors.paletteColors[index],
              isSelected: canvasState.selectedColor ==
                      AppColors.paletteColors[index] &&
                  canvasState.tool == DrawingTool.brush,
              onTap: () => ref
                  .read(canvasProvider.notifier)
                  .selectColor(AppColors.paletteColors[index]),
            ),
          ),
        ),
      ],
    );
  }
}

class _ColorButton extends StatelessWidget {
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  const _ColorButton({
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isWhite = color == Colors.white || color.value == 0xFFFFFFFF;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: isSelected ? 44 : 40,
        height: isSelected ? 44 : 40,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(
            color: isSelected
                ? Theme.of(context).colorScheme.primary
                : (isWhite ? Colors.grey.shade300 : Colors.transparent),
            width: isSelected ? 3 : 1,
          ),
          boxShadow: [
            if (isSelected)
              BoxShadow(
                color: color.withOpacity(0.4),
                blurRadius: 8,
                spreadRadius: 2,
              ),
          ],
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
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
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
