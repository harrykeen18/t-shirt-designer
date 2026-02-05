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

  static const double _wideBreakpoint = 700;

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
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth >= _wideBreakpoint;

            if (isWide) {
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
          child: Container(
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              border: Border(
                left: BorderSide(color: Colors.grey.shade200),
              ),
            ),
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
                        'Continue to Checkout',
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
        // Canvas area
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: const PixelGrid(),
          ),
        ),
        // Background color selector
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Text(
                'Background:',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade700,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: SizedBox(
                  height: 32,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: AppColors.backgroundColors.length,
                    itemBuilder: (context, index) {
                      final color = AppColors.backgroundColors[index];
                      final selectedIndex =
                          canvasState.selectedBackgroundColorIndex;
                      final isSelected = selectedIndex == index;
                      return GestureDetector(
                        onTap: () => ref
                            .read(canvasProvider.notifier)
                            .selectBackgroundColor(index),
                        child: Container(
                          width: 32,
                          height: 32,
                          margin: const EdgeInsets.only(right: 8),
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
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        // Color palette
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: const ColorPalette(),
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
                'Continue to Checkout',
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
