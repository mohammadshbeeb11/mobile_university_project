class CartItem {
  final int id;
  final String artworkId;
  final int quantity;
  final String addedAt;
  final String title;
  final double price;
  final String imageUrl;
  final String currency;

  const CartItem({
    required this.id,
    required this.artworkId,
    required this.quantity,
    required this.addedAt,
    required this.title,
    required this.price,
    required this.imageUrl,
    this.currency = '\$',
  });

  String get formattedPrice => '$currency${price.toStringAsFixed(0)}';
  double get totalPrice => price * quantity;
  String get formattedTotalPrice => '$currency${totalPrice.toStringAsFixed(0)}';

  factory CartItem.fromJson(Map<String, dynamic> json) => CartItem(
    id: json['id'] ?? 0,
    artworkId: json['artworkId'] ?? '',
    quantity: json['quantity'] ?? 1,
    addedAt: json['addedAt'] ?? '',
    title: json['title'] ?? '',
    price: (json['price'] ?? 0).toDouble(),
    imageUrl: json['imageUrl'] ?? '',
    currency: json['currency'] ?? '\$',
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'artworkId': artworkId,
    'quantity': quantity,
    'addedAt': addedAt,
    'title': title,
    'price': price,
    'imageUrl': imageUrl,
    'currency': currency,
  };

  CartItem copyWith({
    int? id,
    String? artworkId,
    int? quantity,
    String? addedAt,
    String? title,
    double? price,
    String? imageUrl,
    String? currency,
  }) => CartItem(
    id: id ?? this.id,
    artworkId: artworkId ?? this.artworkId,
    quantity: quantity ?? this.quantity,
    addedAt: addedAt ?? this.addedAt,
    title: title ?? this.title,
    price: price ?? this.price,
    imageUrl: imageUrl ?? this.imageUrl,
    currency: currency ?? this.currency,
  );
}
