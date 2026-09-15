
class Restaurant {
  final String id;
  final String name;
  final String location;
  final String price;
  final double rating;
  final int reviews;
  final String openingHours;
  final String description;
  final List<String> images;
  final List<String> facilities;

  const Restaurant({
    this.id = '',
    required this.name,
    required this.location,
    required this.price,
    required this.rating,
    required this.reviews,
    required this.openingHours,
    required this.description,
    required this.images,
    required this.facilities,
  });

  factory Restaurant.fromJson(Map<String, dynamic> json) {
    List<String> parseStringList(dynamic value) {
      if (value is List) {
        return value
            .map((item) => item.toString())
            .where((item) => item.isNotEmpty)
            .toList();
      }
      return [];
    }

    double parseRating(dynamic value) {
      if (value is num) return value.toDouble();
      return double.tryParse(value?.toString() ?? '') ?? 0.0;
    }

    int parseReviews(dynamic value) {
      if (value is num) return value.toInt();
      return int.tryParse(value?.toString() ?? '') ?? 0;
    }

    final detailImages = parseStringList(json['detailimages']);
    final mainImage = json['image']?.toString() ?? '';
    final images = detailImages.isNotEmpty
        ? detailImages
        : (mainImage.isNotEmpty ? [mainImage] : <String>[]);

    return Restaurant(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      name: json['name']?.toString() ?? 'Unnamed Restaurant',
      location: json['location']?.toString() ?? '',
      price: json['price']?.toString() ?? r'$$',
      rating: parseRating(json['rating']),
      reviews: parseReviews(json['reviews']),
      openingHours: json['openingHours']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      images: images,
      facilities: parseStringList(json['facilities']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'location': location,
      'price': price,
      'rating': rating,
      'reviews': reviews,
      'openingHours': openingHours,
      'description': description,
      'images': images,
      'facilities': facilities,
    };
  }
}