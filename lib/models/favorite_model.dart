class Favorite {
  final int id;
  final String artworkId;
  final String addedAt;
  final String title;
  final double price;
  final String imageUrl;
  final String description;
  final String category;
  final String currency;

  const Favorite({
    required this.id,
    required this.artworkId,
    required this.addedAt,
    required this.title,
    required this.price,
    required this.imageUrl,
    required this.description,
    required this.category,
    this.currency = '\$',
  });

  String get formattedPrice => '$currency${price.toStringAsFixed(0)}';

  factory Favorite.fromJson(Map<String, dynamic> json) => Favorite(
    id: json['id'] ?? 0,
    artworkId: json['artworkId'] ?? '',
    addedAt: json['addedAt'] ?? '',
    title: json['title'] ?? '',
    price: (json['price'] ?? 0).toDouble(),
    imageUrl: json['imageUrl'] ?? '',
    description: json['description'] ?? '',
    category: json['category'] ?? '',
    currency: json['currency'] ?? '\$',
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'artworkId': artworkId,
    'addedAt': addedAt,
    'title': title,
    'price': price,
    'imageUrl': imageUrl,
    'description': description,
    'category': category,
    'currency': currency,
  };
}
