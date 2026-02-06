import 'package:flutter/material.dart';

/// Isolated order button widget with its own loading state.
/// This ensures the spinner shows immediately on click, independent of
/// any parent widget rebuilds or provider state changes.
class OrderButton extends StatefulWidget {
  final bool enabled;
  final bool forceReset;
  final VoidCallback onPressed;

  const OrderButton({
    super.key,
    required this.enabled,
    this.forceReset = false,
    required this.onPressed,
  });

  @override
  State<OrderButton> createState() => _OrderButtonState();
}

class _OrderButtonState extends State<OrderButton> {
  bool _isLoading = false;

  @override
  void didUpdateWidget(OrderButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Reset loading state when forceReset is true and button is showing loading
    if (widget.forceReset && _isLoading) {
      setState(() => _isLoading = false);
    }
  }

  void _handlePress() {
    // Show spinner immediately
    setState(() => _isLoading = true);

    // Give browser actual time to paint the frame before running heavy work
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        widget.onPressed();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: (widget.enabled && !_isLoading) ? _handlePress : null,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          // Disable ripple/splash effect
          splashFactory: NoSplash.splashFactory,
        ),
        child: _isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : const Text(
                'Order T-Shirt',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }
}
