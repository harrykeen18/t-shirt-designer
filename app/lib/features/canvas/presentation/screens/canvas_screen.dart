import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/services/providers.dart';
import '../../../../core/widgets/footer.dart';
import '../providers/canvas_provider.dart';
import '../widgets/pixel_grid.dart';
import '../widgets/color_palette.dart';
import '../widgets/order_button.dart';
import '../../../checkout/presentation/providers/checkout_provider.dart';

/// Main canvas screen where users create their pixel art designs
class CanvasScreen extends ConsumerStatefulWidget {
  const CanvasScreen({super.key});

  @override
  ConsumerState<CanvasScreen> createState() => _CanvasScreenState();
}

class _CanvasScreenState extends ConsumerState<CanvasScreen> {
  static const double _wideBreakpoint = 900;

  @override
  void initState() {
    super.initState();
    // Reset checkout state when returning to canvas (e.g., from browser back button)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(checkoutProvider.notifier).reset();

      // Track screen view
      ref.read(analyticsServiceProvider).logAppOpened();
      ref.read(analyticsServiceProvider).logScreenView('canvas_screen');

      // Web pixel page view
      if (kIsWeb) {
        ref.read(webPixelManagerProvider).trackPageView();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final canvasState = ref.watch(canvasProvider);
    final checkoutState = ref.watch(checkoutProvider);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            _PixelLogo(),
            const SizedBox(width: 8),
            const Text(
              'PixelPrint',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ],
        ),
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: SafeArea(
              child: kIsWeb
                  ? LayoutBuilder(
                      builder: (context, constraints) {
                        // Web: use pixel width breakpoint
                        final isWide = constraints.maxWidth >= _wideBreakpoint;
                        if (isWide) {
                          return _buildWideLayout(context, ref, canvasState, checkoutState);
                        } else {
                          return _buildNarrowLayout(context, ref, canvasState, checkoutState);
                        }
                      },
                    )
                  : OrientationBuilder(
                      builder: (context, orientation) {
                        // Mobile: use device orientation
                        if (orientation == Orientation.landscape) {
                          return _buildWideLayout(context, ref, canvasState, checkoutState);
                        } else {
                          return _buildNarrowLayout(context, ref, canvasState, checkoutState);
                        }
                      },
                    ),
            ),
          ),
          // Footer (web only)
          if (kIsWeb) const AppFooter(),
        ],
      ),
    );
  }

  /// Wide layout: Canvas on left, controls on right
  Widget _buildWideLayout(
    BuildContext context,
    WidgetRef ref,
    CanvasState canvasState,
    CheckoutState checkoutState,
  ) {
    return Row(
      children: [
        // Canvas area - takes up left side
        Expanded(
          flex: 3,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Stack(
              children: [
                const PixelGrid(),
                // Loading overlay - only covers canvas
                if (checkoutState.isLoading)
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const CircularProgressIndicator(),
                              const SizedBox(height: 16),
                              Text(
                                checkoutState.statusMessage,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
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
                  // Undo/Redo/Delete toolbar
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
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
                  const SizedBox(height: 16),
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
                  OrderButton(
                    enabled: canvasState.hasContent,
                    forceReset: !checkoutState.isLoading,
                    onPressed: () {
                      // Track button click
                      ref.read(analyticsServiceProvider).logOrderButtonClicked();
                      if (kIsWeb) {
                        ref.read(webPixelManagerProvider).trackInitiateCheckout();
                      }

                      // Start checkout
                      ref.read(checkoutProvider.notifier).processCheckout();
                    },
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
    CheckoutState checkoutState,
  ) {
    return Column(
      children: [
        // Toolbar row with background selector and undo/redo/delete
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Background',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade700,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: 12),
              ...List.generate(AppColors.backgroundColors.length, (index) {
                final color = AppColors.backgroundColors[index];
                final isSelected = canvasState.selectedBackgroundColorIndex == index;
                return Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: GestureDetector(
                    onTap: () => ref
                        .read(canvasProvider.notifier)
                        .selectBackgroundColor(index),
                    child: Container(
                      width: 28,
                      height: 28,
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
                  ),
                );
              }),
              const Spacer(),
              // Undo/Redo/Delete buttons
              IconButton(
                icon: const Icon(Icons.undo, size: 20),
                onPressed: canvasState.canUndo
                    ? () => ref.read(canvasProvider.notifier).undo()
                    : null,
                tooltip: 'Undo',
                constraints: const BoxConstraints(),
                padding: const EdgeInsets.all(8),
              ),
              IconButton(
                icon: const Icon(Icons.redo, size: 20),
                onPressed: canvasState.canRedo
                    ? () => ref.read(canvasProvider.notifier).redo()
                    : null,
                tooltip: 'Redo',
                constraints: const BoxConstraints(),
                padding: const EdgeInsets.all(8),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline, size: 20),
                onPressed: canvasState.hasContent
                    ? () => _showClearConfirmation(context, ref)
                    : null,
                tooltip: 'Clear canvas',
                constraints: const BoxConstraints(),
                padding: const EdgeInsets.all(8),
              ),
            ],
          ),
        ),
        // Canvas area with loading overlay
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Stack(
              children: [
                const PixelGrid(),
                // Loading overlay - only covers canvas
                if (checkoutState.isLoading)
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const CircularProgressIndicator(),
                              const SizedBox(height: 16),
                              Text(
                                checkoutState.statusMessage,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
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
          child: OrderButton(
            enabled: canvasState.hasContent,
            forceReset: !checkoutState.isLoading,
            onPressed: () {
              // Track button click
              ref.read(analyticsServiceProvider).logOrderButtonClicked();
              if (kIsWeb) {
                ref.read(webPixelManagerProvider).trackInitiateCheckout();
              }

              // Start checkout
              ref.read(checkoutProvider.notifier).processCheckout();
            },
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

/// 4x4 pixel grid logo
class _PixelLogo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Define the 4x4 pixel pattern (P shape)
    final pixels = [
      [Colors.purple[400]!, Colors.purple[400]!, Colors.purple[400]!, Colors.transparent],
      [Colors.purple[400]!, Colors.transparent, Colors.transparent, Colors.purple[400]!],
      [Colors.purple[400]!, Colors.purple[400]!, Colors.purple[400]!, Colors.transparent],
      [Colors.purple[400]!, Colors.transparent, Colors.transparent, Colors.transparent],
    ];

    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        children: List.generate(4, (row) {
          return Expanded(
            child: Row(
              children: List.generate(4, (col) {
                return Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: pixels[row][col],
                      border: pixels[row][col] != Colors.transparent
                          ? Border.all(color: Colors.purple[300]!, width: 0.5)
                          : null,
                    ),
                  ),
                );
              }),
            ),
          );
        }),
      ),
    );
  }
}
