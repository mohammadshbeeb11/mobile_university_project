import 'package:flutter/material.dart';
import 'package:khat_husseini/models/artwork_model.dart';
import 'package:khat_husseini/utils/database_helper.dart';
import 'package:khat_husseini/utils/shared_prefs_helper.dart';
import 'dart:io';

class ArtworkDetailsScreen extends StatefulWidget {
  final Artwork artwork;

  const ArtworkDetailsScreen({super.key, required this.artwork});

  @override
  State<ArtworkDetailsScreen> createState() => _ArtworkDetailsScreenState();
}

class _ArtworkDetailsScreenState extends State<ArtworkDetailsScreen> {
  final DatabaseHelper _databaseHelper = DatabaseHelper();
  final SharedPrefsHelper _prefsHelper = SharedPrefsHelper();
  bool _isFavorite = false;
  bool _isAddingToCart = false;

  @override
  void initState() {
    super.initState();
    _checkIfFavorite();
  }

  Future<void> _checkIfFavorite() async {
    // First check in shared preferences
    var isFav = await _prefsHelper.isFavorite(widget.artwork.id);

    // If not found in shared prefs, check database
    if (!isFav) {
      isFav = await _databaseHelper.isFavorite(widget.artwork.id);
    }

    if (mounted) {
      setState(() {
        _isFavorite = isFav;
      });
    }
  }

  Future<void> _toggleFavorite() async {
    try {
      if (_isFavorite) {
        // Remove from database
        await _databaseHelper.removeFromFavorites(widget.artwork.id);

        // Update favorites in shared preferences
        final favorites = await _databaseHelper.getFavorites();
        await _prefsHelper.saveFavorites(favorites);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${widget.artwork.title} removed from favorites'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      } else {
        // Add to database
        await _databaseHelper.addToFavorites(widget.artwork.id);

        // Update favorites in shared preferences
        final favorites = await _databaseHelper.getFavorites();
        await _prefsHelper.saveFavorites(favorites);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${widget.artwork.title} added to favorites'),
              backgroundColor: Colors.teal,
            ),
          );
        }
      }

      setState(() {
        _isFavorite = !_isFavorite;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _addToCart() async {
    setState(() {
      _isAddingToCart = true;
    });

    try {
      // Add to database
      await _databaseHelper.addToCart(widget.artwork.id, 1);

      // Update cart items in shared preferences
      final cartItems = await _databaseHelper.getCartItems();
      await _prefsHelper.saveCartItems(cartItems);

      if (mounted) {
        setState(() {
          _isAddingToCart = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${widget.artwork.title} added to cart'),
            backgroundColor: Colors.teal,
            duration: const Duration(seconds: 2),
            action: SnackBarAction(
              label: 'View Cart',
              textColor: Colors.white,
              onPressed: () {
                // Navigate to the cart tab in the main navigation
                Navigator.popUntil(context, (route) => route.isFirst);
                Navigator.pushReplacementNamed(
                  context,
                  '/main',
                  arguments: {'tabIndex': 1}, // 1 is the index of the cart tab
                );
              },
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isAddingToCart = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error adding to cart: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // App Bar with Image
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            backgroundColor: Colors.teal,
            foregroundColor: Colors.white,
            flexibleSpace: FlexibleSpaceBar(
              background: Hero(
                tag: 'artwork-${widget.artwork.id}',
                child:
                    widget.artwork.imageUrl.startsWith('http')
                        ? Image.network(
                          widget.artwork.imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: Colors.grey[300],
                              child: const Icon(
                                Icons.image_not_supported,
                                size: 100,
                                color: Colors.grey,
                              ),
                            );
                          },
                        )
                        : Image.file(
                          File(widget.artwork.imageUrl),
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: Colors.grey[300],
                              child: const Icon(
                                Icons.image_not_supported,
                                size: 100,
                                color: Colors.grey,
                              ),
                            );
                          },
                        ),
              ),
            ),
          ),

          // Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title and Category
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.artwork.title,
                              style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.teal.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Text(
                                widget.artwork.category,
                                style: const TextStyle(
                                  color: Colors.teal,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Price
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.teal.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          widget.artwork.formattedPrice,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.teal,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Description Section
                  const Text(
                    'Description',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    widget.artwork.description,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[700],
                      height: 1.6,
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Additional Details Section (if available)
                  const Text(
                    'Details',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Details Cards
                  _buildDetailCard('Category', widget.artwork.category),
                  _buildDetailCard('Price', widget.artwork.formattedPrice),

                  // Add more detail cards based on your Artwork model
                  // _buildDetailCard('Artist', artwork.artist ?? 'Unknown'),
                  // _buildDetailCard('Year', artwork.year?.toString() ?? 'Unknown'),
                  // _buildDetailCard('Dimensions', artwork.dimensions ?? 'Not specified'),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),

      // Bottom Bar with Action Button
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: Row(
            children: [
              // Favorite Button
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.teal),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  onPressed: _toggleFavorite,
                  icon: Icon(
                    _isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: _isFavorite ? Colors.red : Colors.teal,
                  ),
                ),
              ),

              const SizedBox(width: 16),

              // Add to Cart Button
              Expanded(
                child:
                    _isAddingToCart
                        ? const Center(
                          child: SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        )
                        : ElevatedButton(
                          onPressed: _addToCart,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.teal,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.shopping_cart),
                              SizedBox(width: 8),
                              Text(
                                'Add to Cart',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailCard(String label, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}
