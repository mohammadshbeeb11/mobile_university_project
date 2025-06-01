import 'package:flutter/material.dart';

class QuantityControls extends StatelessWidget {
  final int quantity;
  final Function(int) onQuantityChanged;
  final Color primaryColor;

  const QuantityControls({
    super.key,
    required this.quantity,
    required this.onQuantityChanged,
    this.primaryColor = Colors.teal,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildControlButton(
          icon: Icons.remove_circle_outline,
          onPressed: () => onQuantityChanged(quantity - 1),
        ),
        _buildQuantityDisplay(),
        _buildControlButton(
          icon: Icons.add_circle_outline,
          onPressed: () => onQuantityChanged(quantity + 1),
        ),
      ],
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return IconButton(
      onPressed: onPressed,
      icon: Icon(icon),
      color: primaryColor,
      constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
    );
  }

  Widget _buildQuantityDisplay() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        '$quantity',
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    );
  }
}
