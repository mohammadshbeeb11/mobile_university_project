import 'package:flutter/material.dart';
import 'package:khat_husseini/models/artwork_model.dart';
import 'package:khat_husseini/screens/add_item_screen.dart';
import 'package:khat_husseini/utils/my_appbar.dart';
import 'package:khat_husseini/widgets/artwork_collection.dart';
import 'package:khat_husseini/widgets/artwork_featured_carousel.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String selectedCategory = 'All';

  final List<String> categories = [
    'All',
    'Banner',
    'Flag',
    'historical',
    'Paintings',
    'portraits',
    'shrines',
  ];

  // All artworks with featured flag
  final List<Artwork> allArtworks = [
    Artwork(
      id: '1',
      imageUrl: 'https://example.com/artwork1.jpg',
      title: 'يا أبتاه',
      description:
          'فما يتضع "لبعض" يا أبتاه! أظل "معطلكات" جولة يتهي صقب نتى علقت، تر ةو فوض عمر من إسلامي.',
      category: 'portraits',
      price: 100,
      isFeatured: true,
    ),
    Artwork(
      id: '2',
      imageUrl: 'https://example.com/artwork2.jpg',
      title: 'الوليد الأعظم',
      description: 'عمل فني معقد يجبو عاله مطاليت بتكم ملحيس لوافرار.',
      category: 'historical',
      price: 100,
      isFeatured: true,
    ),
    Artwork(
      id: '3',
      imageUrl: 'https://example.com/artwork3.jpg',
      title: 'Islamic Banner',
      description:
          'Traditional Islamic banner with beautiful calligraphy and ornate designs.',
      category: 'Banner',
      price: 150,
      isFeatured: false,
    ),
    Artwork(
      id: '4',
      imageUrl: 'https://example.com/artwork4.jpg',
      title: 'Sacred Flag',
      description:
          'Historical flag with religious significance and intricate patterns.',
      category: 'Flag',
      price: 120,
      isFeatured: true,
    ),
    Artwork(
      id: '5',
      imageUrl: 'https://example.com/artwork5.jpg',
      title: 'Modern Painting',
      description:
          'Contemporary artwork blending traditional and modern artistic techniques.',
      category: 'Paintings',
      price: 200,
      isFeatured: false,
    ),
    Artwork(
      id: '6',
      imageUrl: 'https://example.com/artwork6.jpg',
      title: 'Holy Shrine',
      description:
          'Artistic representation of a sacred shrine with golden details.',
      category: 'shrines',
      price: 300,
      isFeatured: true,
    ),
    Artwork(
      id: '7',
      imageUrl: 'https://example.com/artwork7.jpg',
      title: 'Islamic Art',
      description:
          'Beautiful traditional Islamic artwork with intricate patterns and designs.',
      category: 'traditional',
      price: 150,
      isFeatured: false,
    ),
    Artwork(
      id: '8',
      imageUrl: 'https://example.com/artwork8.jpg',
      title: 'Modern Portrait',
      description:
          'Contemporary portrait artwork with modern artistic techniques.',
      category: 'portraits',
      price: 200,
      isFeatured: false,
    ),
  ];

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

  // Method to add new artwork - NEW METHOD
  void _addNewArtwork(Artwork artwork) {
    setState(() {
      allArtworks.add(artwork);
    });
  }

  // Method to navigate to Add Item Screen - NEW METHOD
  void _navigateToAddItemScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddItemScreen(onAddArtwork: _addNewArtwork),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      appBar: PreferredSize(
        preferredSize: Size(double.infinity, 50),
        child: MyAppbar(title: "Dashboard", icon: Icons.dashboard),
      ),

      body: ListView(
        children: [
          const SizedBox(height: 16),
          const Text(
            'Featured Artworks',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 16),

          ArtworkCarousel(
            artworks: featuredArtworks,
            onAddToCart: (artwork) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${artwork.title} added to cart!'),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
          ),

          const SizedBox(height: 32),

          // Results count
          Text(
            'Our Artworks',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 16),

          SizedBox(
            height: 50,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
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
                      color: isSelected ? Colors.teal : Colors.black87,
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 16),

          ArtworkGridView(
            artworks: filteredArtworks,
            onAddToCart: (artwork) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${artwork.title} added to cart!'),
                  duration: const Duration(seconds: 2),
                  backgroundColor: Colors.teal,
                ),
              );
            },
          ),
        ],
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
