class Product {
  final int id;
  final int businessId;
  final String name;
  final double price;
  final int stock;
  final String? description;
  final String? imageUrl;
  final bool active;
  final DateTime createdAt;
  final DateTime updatedAt;

  Product({
    required this.id,
    required this.businessId,
    required this.name,
    required this.price,
    required this.stock,
    this.description,
    this.imageUrl,
    required this.active,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      businessId: json['business_id'],
      name: json['name'],
      price: (json['price'] is int) ? (json['price'] as int).toDouble() : json['price'],
      stock: json['stock'],
      description: json['description'],
      imageUrl: json['image_url'],
      active: json['active'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'business_id': businessId,
      'name': name,
      'price': price,
      'stock': stock,
      'description': description,
      'image_url': imageUrl,
      'active': active,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  Product copyWith({
    int? id,
    int? businessId,
    String? name,
    double? price,
    int? stock,
    String? description,
    String? imageUrl,
    bool? active,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Product(
      id: id ?? this.id,
      businessId: businessId ?? this.businessId,
      name: name ?? this.name,
      price: price ?? this.price,
      stock: stock ?? this.stock,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      active: active ?? this.active,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Método para formatear precio
  String get formattedPrice => '\$${price.toStringAsFixed(2)}';

  // Método para verificar si hay stock
  bool get hasStock => stock > 0;

  // Método para obtener estado de stock
  String get stockStatus {
    if (stock == 0) return 'Sin stock';
    if (stock < 5) return 'Stock bajo';
    return 'Disponible';
  }

  @override
  String toString() {
    return 'Product(id: $id, name: $name, price: $price, stock: $stock)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Product && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
} 