import 'package:flutter/material.dart';

class CartItemImage extends StatelessWidget {
  final String imageUrl;
  final double size;

  const CartItemImage({super.key, required this.imageUrl, this.size = 80});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: size,
        height: size,
        color: Colors.grey[200],
        child: _buildImageContent(),
      ),
    );
  }

  Widget _buildImageContent() {
    if (imageUrl.isEmpty) {
      return _buildPlaceholder();
    }

    return Image.network(
      imageUrl,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) => _buildErrorPlaceholder(),
    );
  }

  Widget _buildPlaceholder() {
    return Icon(Icons.image, color: Colors.grey[400], size: size * 0.5);
  }

  Widget _buildErrorPlaceholder() {
    return Icon(
      Icons.image_not_supported,
      color: Colors.grey[400],
      size: size * 0.5,
    );
  }
}