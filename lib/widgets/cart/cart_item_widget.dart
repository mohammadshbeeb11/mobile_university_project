import 'package:flutter/material.dart';
import '../../models/cart_item_model.dart';
import 'cart_item_image.dart';
import 'quantity_controls.dart';

class CartItemWidget extends StatelessWidget {
  final CartItem item;
  final Function(int) onQuantityChanged;
  final VoidCallback onRemove;

  const CartItemWidget({
    super.key,
    required this.item,
    required this.onQuantityChanged,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CartItemImage(imageUrl: item.imageUrl),
            const SizedBox(width: 16),
            _buildItemDetails(),
            _buildControlsColumn(),
          ],
        ),
      ),
    );
  }

  Widget _buildItemDetails() {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            item.title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            item.formattedPrice,
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          Text(
            'Total: ${item.formattedTotalPrice}',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.teal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControlsColumn() {
    return Column(
      children: [
        QuantityControls(
          quantity: item.quantity,
          onQuantityChanged: onQuantityChanged,
        ),
        const SizedBox(height: 8),
        IconButton(
          onPressed: onRemove,
          icon: const Icon(Icons.delete_outline),
          color: Colors.red,
          tooltip: 'Remove item',
        ),
      ],
    );
  }
}
