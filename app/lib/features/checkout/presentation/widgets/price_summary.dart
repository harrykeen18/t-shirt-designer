import 'package:flutter/material.dart';
import '../../../../core/constants/pricing.dart';

/// Widget displaying the price summary
class PriceSummary extends StatelessWidget {
  const PriceSummary({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          _PriceRow(
            label: 'Custom T-Shirt',
            value: Pricing.formatPrice(Pricing.tshirtPrice),
          ),
          const SizedBox(height: 8),
          _PriceRow(
            label: 'Shipping',
            value: 'FREE',
            valueColor: Colors.green,
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(),
          ),
          _PriceRow(
            label: 'Total',
            value: Pricing.formatPrice(Pricing.tshirtPrice),
            isBold: true,
            labelStyle: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _PriceRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isBold;
  final Color? valueColor;
  final TextStyle? labelStyle;

  const _PriceRow({
    required this.label,
    required this.value,
    this.isBold = false,
    this.valueColor,
    this.labelStyle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: labelStyle ??
              TextStyle(
                fontSize: 16,
                color: Colors.grey.shade700,
              ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isBold ? 20 : 16,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
            color: valueColor ?? (isBold ? Theme.of(context).colorScheme.primary : null),
          ),
        ),
      ],
    );
  }
}
