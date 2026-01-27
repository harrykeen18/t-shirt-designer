import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/canvas_provider.dart';
import '../widgets/pixel_grid.dart';
import '../widgets/color_palette.dart';

/// Main canvas screen where users create their pixel art designs
class CanvasScreen extends ConsumerWidget {
  const CanvasScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final canvasState = ref.watch(canvasProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Your Design'),
        centerTitle: true,
        elevation: 0,
        actions: [
          // Undo button
          IconButton(
            icon: const Icon(Icons.undo),
            onPressed: canvasState.canUndo
                ? () => ref.read(canvasProvider.notifier).undo()
                : null,
            tooltip: 'Undo',
          ),
          // Redo button
          IconButton(
            icon: const Icon(Icons.redo),
            onPressed: canvasState.canRedo
                ? () => ref.read(canvasProvider.notifier).redo()
                : null,
            tooltip: 'Redo',
          ),
          // Clear button
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
        child: Column(
          children: [
            // Canvas area
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: const PixelGrid(),
              ),
            ),
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
            // Preview button
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: canvasState.hasContent
                      ? () => context.push('/preview')
                      : null,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Preview on T-Shirt',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
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
