class Item {
  final int id;
  final String title;
  final String description;
  final String category;
  final double price;
  final double discountPercentage;
  final double rating;
  final String brand;
  final String image;

  const Item({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.price,
    required this.discountPercentage,
    required this.rating,
    required this.brand,
    required this.image,
  });

  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
      id: json['id'] as int,
      title: (json['title'] as String?) ?? '-',
      description: (json['description'] as String?) ?? '-',
      category: (json['category'] as String?) ?? '-',
      price: (json['price'] as num?)?.toDouble() ?? 0,
      discountPercentage: (json['discount'] as num?)?.toDouble() ?? 0,
      rating: (json['rating'] as num?)?.toDouble() ?? 0,
      brand: (json['brand'] as String?) ?? '-', // tidak semua produk punya brand
      image: (json['thumbnail'] as String?) ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'category': category,
        'price': price,
        'rating': rating,
        'brand': brand,
        'thumbnail': image,
      };
}
