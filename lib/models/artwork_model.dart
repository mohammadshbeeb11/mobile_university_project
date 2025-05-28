class Artwork {
  final String id;
  final String imageUrl;
  final String title;
  final String description;
  final String category;
  final double price;
  final String currency;
  final bool isFeatured;

  const Artwork({
    required this.id,
    required this.imageUrl,
    required this.title,
    required this.description,
    required this.category,
    required this.price,
    this.currency = '\$',
    this.isFeatured = false,
  });

  String get formattedPrice => '$currency${price.toStringAsFixed(0)}';

  // Factory constructor for creating from JSON
  factory Artwork.fromJson(Map<String, dynamic> json) {
    return Artwork(
      id: json['id'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      category: json['category'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      currency: json['currency'] ?? '\$',
      isFeatured: json['isFeatured'] ?? false,
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'imageUrl': imageUrl,
      'title': title,
      'description': description,
      'category': category,
      'price': price,
      'currency': currency,
      'isFeatured': isFeatured,
    };
  }
}