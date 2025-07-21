import 'package:uuid/uuid.dart';

class Item {
  final String id;
  final String name;
  final String category;
  final double price;
  final String? description;
  final String? imageUrl;
  final bool isAvailable;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<String> modifiers;
  final List<String> tags;

  const Item({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    this.description,
    this.imageUrl,
    this.isAvailable = true,
    required this.createdAt,
    required this.updatedAt,
    this.modifiers = const [],
    this.tags = const [],
  });

  // Create a new item
  factory Item.create({
    required String name,
    required String category,
    required double price,
    String? description,
    String? imageUrl,
    List<String> modifiers = const [],
    List<String> tags = const [],
  }) {
    final now = DateTime.now();
    return Item(
      id: const Uuid().v4(),
      name: name,
      category: category,
      price: price,
      description: description,
      imageUrl: imageUrl,
      isAvailable: true,
      createdAt: now,
      updatedAt: now,
      modifiers: modifiers,
      tags: tags,
    );
  }

  // Create from JSON
  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
      id: json['id'] as String,
      name: json['name'] as String,
      category: json['category'] as String,
      price: (json['price'] as num).toDouble(),
      description: json['description'] as String?,
      imageUrl: json['imageUrl'] as String?,
      isAvailable: json['isAvailable'] as bool? ?? true,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      modifiers: List<String>.from(json['modifiers'] ?? []),
      tags: List<String>.from(json['tags'] ?? []),
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'price': price,
      'description': description,
      'imageUrl': imageUrl,
      'isAvailable': isAvailable,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'modifiers': modifiers,
      'tags': tags,
    };
  }

  // Convert to database map
  Map<String, dynamic> toDatabaseMap() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'price': price,
      'description': description,
      'image_url': imageUrl,
      'is_available': isAvailable ? 1 : 0,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  // Create from database map
  factory Item.fromDatabaseMap(Map<String, dynamic> map) {
    return Item(
      id: map['id'] as String,
      name: map['name'] as String,
      category: map['category'] as String,
      price: (map['price'] as num).toDouble(),
      description: map['description'] as String?,
      imageUrl: map['image_url'] as String?,
      isAvailable: (map['is_available'] as int) == 1,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }

  // Copy with modifications
  Item copyWith({
    String? id,
    String? name,
    String? category,
    double? price,
    String? description,
    String? imageUrl,
    bool? isAvailable,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<String>? modifiers,
    List<String>? tags,
  }) {
    return Item(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      price: price ?? this.price,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      isAvailable: isAvailable ?? this.isAvailable,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
      modifiers: modifiers ?? this.modifiers,
      tags: tags ?? this.tags,
    );
  }

  // Update item
  Item update({
    String? name,
    String? category,
    double? price,
    String? description,
    String? imageUrl,
    bool? isAvailable,
    List<String>? modifiers,
    List<String>? tags,
  }) {
    return copyWith(
      name: name,
      category: category,
      price: price,
      description: description,
      imageUrl: imageUrl,
      isAvailable: isAvailable,
      modifiers: modifiers,
      tags: tags,
    );
  }

  // Check if item matches search query
  bool matchesSearch(String query) {
    final lowercaseQuery = query.toLowerCase();
    return name.toLowerCase().contains(lowercaseQuery) ||
           category.toLowerCase().contains(lowercaseQuery) ||
           (description?.toLowerCase().contains(lowercaseQuery) ?? false) ||
           tags.any((tag) => tag.toLowerCase().contains(lowercaseQuery));
  }

  // Get formatted price
  String get formattedPrice => '\$${price.toStringAsFixed(2)}';

  // Get display name with category
  String get displayName => '$name ($category)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Item && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Item(id: $id, name: $name, category: $category, price: $price)';
  }
} 