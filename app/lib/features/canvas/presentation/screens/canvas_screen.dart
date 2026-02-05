import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/colors.dart';
import '../providers/canvas_provider.dart';
import '../widgets/pixel_grid.dart';
import '../widgets/color_palette.dart';

/// Main canvas screen where users create their pixel art designs
class CanvasScreen extends ConsumerWidget {
  const CanvasScreen({super.key});

  static const double _wideBreakpoint = 900;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final canvasState = ref.watch(canvasProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Your Design'),
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.undo),
            onPressed: canvasState.canUndo
                ? () => ref.read(canvasProvider.notifier).undo()
                : null,
            tooltip: 'Undo',
          ),
          IconButton(
            icon: const Icon(Icons.redo),
            onPressed: canvasState.canRedo
                ? () => ref.read(canvasProvider.notifier).redo()
                : null,
            tooltip: 'Redo',
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: canvasState.hasContent
                ? () => _showClearConfirmation(context, ref)
                : null,
            tooltip: 'Clear canvas',
          ),
        ],
      ),
      body: SafeArea(
        child: kIsWeb
            ? LayoutBuilder(
                builder: (context, constraints) {
                  // Web: use pixel width breakpoint
                  final isWide = constraints.maxWidth >= _wideBreakpoint;
                  if (isWide) {
                    return _buildWideLayout(context, ref, canvasState);
                  } else {
                    return _buildNarrowLayout(context, ref, canvasState);
                  }
                },
              )
            : OrientationBuilder(
                builder: (context, orientation) {
                  // Mobile: use device orientation
                  if (orientation == Orientation.landscape) {
                    return _buildWideLayout(context, ref, canvasState);
                  } else {
                    return _buildNarrowLayout(context, ref, canvasState);
                  }
                },
              ),
      ),
    );
  }

  /// Wide layout: Canvas on left, controls on right
  Widget _buildWideLayout(
    BuildContext context,
    WidgetRef ref,
    CanvasState canvasState,
  ) {
    return Row(
      children: [
        // Canvas area - takes up left side
        Expanded(
          flex: 3,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: const PixelGrid(),
          ),
        ),
        // Controls panel on the right
        SizedBox(
          width: 280,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Background color selector
                  Text(
                    'Background',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade700,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildBackgroundColorGrid(context, ref, canvasState),
                  const SizedBox(height: 24),
                  // Drawing colors
                  Text(
                    'Drawing Colors',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade700,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const ColorPalette(),
                  const Spacer(),
                  // Checkout button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: canvasState.hasContent
                          ? () => context.push('/checkout')
                          : null,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Order T-Shirt',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ),
      ],
    );
  }

  /// Narrow layout: Vertical stack (mobile)
  Widget _buildNarrowLayout(
    BuildContext context,
    WidgetRef ref,
    CanvasState canvasState,
  ) {
    return Column(
      children: [
        // Background color selector
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Center(
            child: Column(
              children: [
                Text(
                  'Background',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade700,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 8,
                  runSpacing: 8,
                  children: List.generate(AppColors.backgroundColors.length, (index) {
                    final color = AppColors.backgroundColors[index];
                    final isSelected = canvasState.selectedBackgroundColorIndex == index;
                    return GestureDetector(
                      onTap: () => ref
                          .read(canvasProvider.notifier)
                          .selectBackgroundColor(index),
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
              ],
            ),
          ),
        ),
        // Canvas area
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: const PixelGrid(),
          ),
        ),
        // Color palette
        Padding(
          padding: const EdgeInsets.all(16),
          child: const Center(child: ColorPalette(centered: true)),
        ),
        // Checkout button
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: canvasState.hasContent
                  ? () => context.push('/checkout')
                  : null,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Order T-Shirt',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Background color grid for wide layout
  Widget _buildBackgroundColorGrid(
    BuildContext context,
    WidgetRef ref,
    CanvasState canvasState,
  ) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: List.generate(AppColors.backgroundColors.length, (index) {
        final color = AppColors.backgroundColors[index];
        final isSelected = canvasState.selectedBackgroundColorIndex == index;
        return GestureDetector(
          onTap: () =>
              ref.read(canvasProvider.notifier).selectBackgroundColor(index),
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
    );
  }

  void _showClearConfirmation(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Canvas?'),
        content: const Text(
          'This will erase your entire design. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              ref.read(canvasProvider.notifier).clear();
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }
}
