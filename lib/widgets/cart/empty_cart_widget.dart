import 'package:flutter/material.dart';

class EmptyCartWidget extends StatelessWidget {
  final VoidCallback onBrowsePressed;

  const EmptyCartWidget({super.key, required this.onBrowsePressed});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildEmptyIcon(),
            const SizedBox(height: 24),
            _buildEmptyTitle(),
            const SizedBox(height: 16),
            _buildEmptySubtitle(),
            const SizedBox(height: 32),
            _buildBrowseButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyIcon() {
    return Icon(
      Icons.shopping_cart_outlined,
      size: 100,
      color: Colors.grey[400],
    );
  }

  Widget _buildEmptyTitle() {
    return Text(
      'Your cart is empty',
      style: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: Colors.grey[600],
      ),
    );
  }

  Widget _buildEmptySubtitle() {
    return Text(
      'Add some artworks to your cart to see them here',
      textAlign: TextAlign.center,
      style: TextStyle(fontSize: 16, color: Colors.grey[500]),
    );
  }

  Widget _buildBrowseButton() {
    return ElevatedButton(
      onPressed: onBrowsePressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.teal,
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: const Text(
        'Browse Artworks',
        style: TextStyle(color: Colors.white),
      ),
    );
  }
}