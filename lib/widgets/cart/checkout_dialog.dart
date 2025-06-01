import 'package:flutter/material.dart';

class CheckoutDialog extends StatelessWidget {
  final double totalAmount;

  const CheckoutDialog({super.key, required this.totalAmount});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Checkout'),
      content: _buildContent(),
      actions: _buildActions(context),
    );
  }

  Widget _buildContent() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Total: \$${totalAmount.toStringAsFixed(2)}'),
        const SizedBox(height: 16),
        const Text(
          'This is a demo app. In a real app, this would proceed to payment.',
        ),
      ],
    );
  }

  List<Widget> _buildActions(BuildContext context) {
    return [
      TextButton(
        onPressed: () => Navigator.of(context).pop(false),
        child: const Text('Cancel'),
      ),
      ElevatedButton(
        onPressed: () => Navigator.of(context).pop(true),
        style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
        child: const Text('Place Order', style: TextStyle(color: Colors.white)),
      ),
    ];
  }
}
