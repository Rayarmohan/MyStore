class CartItemModel {
  final int? id;
  final int productId;
  final String title;
  final double price;
  final String image;
  final int quantity;
  final String? category;

  CartItemModel({
    this.id,
    required this.productId,
    required this.title,
    required this.price,
    required this.image,
    this.quantity = 1,
    this.category,
  });

  double get totalPrice => price * quantity;

  factory CartItemModel.fromMap(Map<String, dynamic> map) {
    return CartItemModel(
      id: map['id'] as int?,
      productId: map['productId'] as int,
      title: map['title'] as String,
      price: (map['price'] as num).toDouble(),
      image: map['image'] as String,
      quantity: map['quantity'] as int? ?? 1,
      category: map['category'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'productId': productId,
      'title': title,
      'price': price,
      'image': image,
      'quantity': quantity,
      'category': category,
    };
  }

  CartItemModel copyWith({
    int? id,
    int? productId,
    String? title,
    double? price,
    String? image,
    int? quantity,
    String? category,
  }) {
    return CartItemModel(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      title: title ?? this.title,
      price: price ?? this.price,
      image: image ?? this.image,
      quantity: quantity ?? this.quantity,
      category: category ?? this.category,
    );
  }
}
