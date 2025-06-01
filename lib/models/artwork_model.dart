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

  factory Artwork.fromJson(Map<String, dynamic> json) => Artwork(
    id: json['id'] ?? '',
    imageUrl: json['imageUrl'] ?? '',
    title: json['title'] ?? '',
    description: json['description'] ?? '',
    category: json['category'] ?? '',
    price: (json['price'] ?? 0).toDouble(),
    currency: json['currency'] ?? '\$',
    isFeatured: json['isFeatured'] == 1 || json['isFeatured'] == true,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'imageUrl': imageUrl,
    'title': title,
    'description': description,
    'category': category,
    'price': price,
    'currency': currency,
    'isFeatured': isFeatured ? 1 : 0,
  };
}
