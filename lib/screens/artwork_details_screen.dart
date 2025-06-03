import 'package:flutter/material.dart';
import 'package:khat_husseini/models/artwork_model.dart';
import 'package:khat_husseini/services/database_helper.dart';
import 'package:khat_husseini/services/shared_prefs_helper.dart';
import 'package:khat_husseini/widgets/artwork/artwork_image.dart';
import 'package:khat_husseini/widgets/artwork/artwork_header.dart';
import 'package:khat_husseini/widgets/common/section_title.dart';
import 'package:khat_husseini/widgets/common/detail_card.dart';
import 'package:khat_husseini/widgets/artwork/artwork_bottom_bar.dart';

class ArtworkDetailsScreen extends StatefulWidget {
  final Artwork artwork;

  const ArtworkDetailsScreen({super.key, required this.artwork});

  @override
  State<ArtworkDetailsScreen> createState() => _ArtworkDetailsScreenState();
}

class _ArtworkDetailsScreenState extends State<ArtworkDetailsScreen> {
  final DatabaseHelper _databaseHelper = DatabaseHelper();
  final SharedPrefsHelper _prefsHelper = SharedPrefsHelper.instance;
  bool _isAddingToCart = false;

  @override
  void initState() {
    super.initState();
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
        _showSnackBar('Error adding to cart: $e', Colors.red);
      }
    }
  }

  void _showSnackBar(String message, Color backgroundColor) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: backgroundColor),
    );
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
              background: ArtworkImage(
                imageUrl: widget.artwork.imageUrl,
                heroTag: 'artwork-${widget.artwork.id}',
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
                  // Title and Category with Price
                  ArtworkHeader(
                    title: widget.artwork.title,
                    category: widget.artwork.category,
                    formattedPrice: widget.artwork.formattedPrice,
                  ),

                  const SizedBox(height: 24),

                  // Description Section
                  const SectionTitle(title: 'Description'),
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

                  // Additional Details Section
                  const SectionTitle(title: 'Details'),
                  const SizedBox(height: 12),

                  // Details Cards
                  DetailCard(label: 'Category', value: widget.artwork.category),
                  DetailCard(
                    label: 'Price',
                    value: widget.artwork.formattedPrice,
                  ),

                  // Add more detail cards based on your Artwork model
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),

      // Bottom Bar with Action Buttons
      bottomNavigationBar: ArtworkBottomBar(
        isAddingToCart: _isAddingToCart,
        onAddToCart: _addToCart,
      ),
    );
  }
}