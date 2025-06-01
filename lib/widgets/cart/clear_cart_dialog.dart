import 'package:flutter/material.dart';

class ClearCartDialog extends StatelessWidget {
  const ClearCartDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Clear Cart'),
      content: const Text(
        'Are you sure you want to remove all items from your cart?',
      ),
      actions: _buildActions(context),
    );
  }

  List<Widget> _buildActions(BuildContext context) {
    return [
      TextButton(
        onPressed: () => Navigator.of(context).pop(false),
        child: const Text('Cancel'),
      ),
      TextButton(
        onPressed: () => Navigator.of(context).pop(true),
        style: TextButton.styleFrom(foregroundColor: Colors.red),
        child: const Text('Clear'),
      ),
    ];
  }
}