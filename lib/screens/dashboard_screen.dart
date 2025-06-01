import 'package:flutter/material.dart';
import 'package:khat_husseini/models/artwork_model.dart';
import 'package:khat_husseini/screens/add_item_screen.dart';
import 'package:khat_husseini/widgets/common/my_appbar.dart';
import 'package:khat_husseini/services/database_helper.dart';
import 'package:khat_husseini/widgets/artwork/artwork_collection.dart';
import 'package:khat_husseini/widgets/artwork/artwork_featured_carousel.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final DatabaseHelper _databaseHelper = DatabaseHelper();
  String selectedCategory = 'All';
  List<Artwork> allArtworks = [];
  bool _isLoading = true;

  final List<String> categories = [
    'All',
    'Banner',
    'Flag',
    'historical',
    'Paintings',
    'portraits',
    'shrines',
  ];

  @override
  void initState() {
    super.initState();
    _loadArtworks();
  }

  Future<void> _loadArtworks() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final artworks = await _databaseHelper.getAllArtworks();
      setState(() {
        allArtworks = artworks;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading artworks: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Get featured artworks for carousel
  List<Artwork> get featuredArtworks {
    return allArtworks.where((artwork) => artwork.isFeatured).toList();
  }

  // Get filtered artworks for grid
  List<Artwork> get filteredArtworks {
    if (selectedCategory == 'All') {
      return allArtworks;
    }
    return allArtworks
        .where(
          (artwork) =>
              artwork.category.toLowerCase() == selectedCategory.toLowerCase(),
        )
        .toList();
  }

  // Method to add new artwork
  void _addNewArtwork(Artwork artwork) async {
    try {
      await _databaseHelper.insertArtwork(artwork);
      await _loadArtworks(); // Reload from database
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${artwork.title} added successfully!'),
            backgroundColor: Colors.teal,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error adding artwork: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Method to navigate to Add Item Screen
  void _navigateToAddItemScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddItemScreen(onAddArtwork: _addNewArtwork),
      ),
    );
  }

  // Method to add artwork to cart
  Future<void> _addToCart(Artwork artwork) async {
    try {
      await _databaseHelper.addToCart(artwork.id, 1);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${artwork.title} added to cart!'),
            duration: const Duration(seconds: 2),
            backgroundColor: Colors.teal,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
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
      appBar: PreferredSize(
        preferredSize: const Size(double.infinity, 50),
        child: MyAppbar(title: "Dashboard", icon: Icons.dashboard),
      ),
      body:
          _isLoading
              ? const Center(
                child: CircularProgressIndicator(color: Colors.teal),
              )
              : RefreshIndicator(
                onRefresh: _loadArtworks,
                color: Colors.teal,
                child: ListView(
                  children: [
                    const SizedBox(height: 16),
                    const Text(
                      'Featured Artworks',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (featuredArtworks.isNotEmpty)
                      ArtworkCarousel(
                        artworks: featuredArtworks,
                        onAddToCart: _addToCart,
                      )
                    else
                      Container(
                        height: 200,
                        margin: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.image_not_supported,
                                size: 50,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'No featured artworks',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    const SizedBox(height: 32),
                    const Text(
                      'Our Artworks',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 50,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: categories.length,
                        itemBuilder: (context, index) {
                          final category = categories[index];
                          final isSelected = category == selectedCategory;

                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: FilterChip(
                              label: Text(category),
                              selected: isSelected,
                              onSelected: (selected) {
                                setState(() {
                                  selectedCategory = category;
                                });
                              },
                              backgroundColor: Colors.grey[200],
                              selectedColor: Colors.teal.withOpacity(0.2),
                              checkmarkColor: Colors.teal,
                              labelStyle: TextStyle(
                                color:
                                    isSelected ? Colors.teal : Colors.black87,
                                fontWeight:
                                    isSelected
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (filteredArtworks.isNotEmpty)
                      ArtworkGridView(
                        artworks: filteredArtworks,
                        onAddToCart: _addToCart,
                      )
                    else
                      Container(
                        height: 200,
                        margin: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.search_off,
                                size: 50,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                selectedCategory == 'All'
                                    ? 'No artworks available'
                                    : 'No artworks in $selectedCategory category',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 16,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ),
                    const SizedBox(height: 100), // Space for bottom navigation
                  ],
                ),
              ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToAddItemScreen,
        backgroundColor: Colors.teal,
        tooltip: 'Add New Artwork',
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
