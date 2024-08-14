
class Product {
  final String id;
  final String name;
  final double price;
  final String imageUrl;
  final String descripcion;
  final String category;
  late final int quantity;

  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.imageUrl,
    required this.descripcion,
    required this.category,
    required this.quantity,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      name: json['name'],
      price: json['price'].toDouble(),
      imageUrl: json['imageUrl'],
      descripcion: json['descripcion'],
      category: json['category'],
      quantity: json['quantity'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'imageUrl': imageUrl,
      'descripcion': descripcion,
      'category': category,
      'quantity': quantity,
    };
  }
}
