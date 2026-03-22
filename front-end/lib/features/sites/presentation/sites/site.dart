class Site {
  final String id;
  final String name;
  final String description;
  final int? categoryId;
  final int? subcategoryId;
  final String category;
  final String? subcategory;
  final String imageUrl;
  final String address;
  final String city;
  final String region;
  final double latitude;
  final double longitude;
  final int freshnessScore;
  final double rating;

  const Site({
    required this.id,
    required this.name,
    required this.description,
    this.categoryId,
    this.subcategoryId,
    required this.category,
    this.subcategory,
    required this.imageUrl,
    required this.address,
    required this.city,
    required this.region,
    required this.latitude,
    required this.longitude,
    required this.freshnessScore,
    required this.rating,
  });

  factory Site.fromJson(Map<String, dynamic> json) {
    int? parseNullableInt(dynamic value) {
      if (value == null) return null;
      if (value is int) return value;
      if (value is num) return value.toInt();
      return int.tryParse('$value');
    }

    final dynamic rawLatitude = json['latitude'];
    final dynamic rawLongitude = json['longitude'];
    final dynamic rawFreshnessScore =
        json['freshness_score'] ?? json['freshnessScore'];
    final dynamic rawRating = json['average_rating'] ?? json['rating'];

    return Site(
      id: '${json['id']}',
      name: json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      categoryId:
          parseNullableInt(json['top_level_category_id']) ??
          parseNullableInt(json['category_id']),
      subcategoryId: parseNullableInt(json['category_parent_id']) != null
          ? parseNullableInt(json['category_id'])
          : null,
      category:
          json['category_name'] as String? ?? json['category'] as String? ?? '',
      subcategory:
          json['subcategory_name'] as String? ?? json['subcategory'] as String?,
      imageUrl:
          json['cover_photo'] as String? ?? json['imageUrl'] as String? ?? '',
      address: json['address'] as String? ?? '',
      city: json['city'] as String? ?? '',
      region: json['region'] as String? ?? '',
      latitude: rawLatitude is num
          ? rawLatitude.toDouble()
          : double.tryParse('$rawLatitude') ?? 0,
      longitude: rawLongitude is num
          ? rawLongitude.toDouble()
          : double.tryParse('$rawLongitude') ?? 0,
      freshnessScore: rawFreshnessScore is int
          ? rawFreshnessScore
          : int.tryParse('$rawFreshnessScore') ?? 0,
      rating: rawRating is num
          ? rawRating.toDouble()
          : double.tryParse('$rawRating') ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      if (categoryId != null) 'category_id': categoryId,
      if (subcategoryId != null) 'subcategory_id': subcategoryId,
      'category': category,
      if (subcategory != null) 'subcategory': subcategory,
      'imageUrl': imageUrl,
      'address': address,
      'city': city,
      'region': region,
      'latitude': latitude,
      'longitude': longitude,
      'freshnessScore': freshnessScore,
      'rating': rating,
    };
  }

  /// Create a copy of this Site with updated values
  Site copyWith({
    String? id,
    String? name,
    String? description,
    int? categoryId,
    int? subcategoryId,
    String? category,
    String? subcategory,
    String? imageUrl,
    String? address,
    String? city,
    String? region,
    double? latitude,
    double? longitude,
    int? freshnessScore,
    double? rating,
  }) {
    return Site(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      categoryId: categoryId ?? this.categoryId,
      subcategoryId: subcategoryId ?? this.subcategoryId,
      category: category ?? this.category,
      subcategory: subcategory ?? this.subcategory,
      imageUrl: imageUrl ?? this.imageUrl,
      address: address ?? this.address,
      city: city ?? this.city,
      region: region ?? this.region,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      freshnessScore: freshnessScore ?? this.freshnessScore,
      rating: rating ?? this.rating,
    );
  }

  @override
  String toString() {
    return 'Site(id: $id, name: $name, category: $category, rating: $rating, freshnessScore: $freshnessScore)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Site && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
