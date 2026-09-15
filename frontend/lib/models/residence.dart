import 'dart:convert';

class Residence {
  final String id;
  final String name;
  final String location;
  final int price;
  final double rating;
  final int reviews;
  final String description;
  final String imageUrl;
  final List<String> imageUrls;
  final List<String> amenities;

  const Residence({
    required this.id,
    required this.name,
    required this.location,
    required this.price,
    required this.rating,
    required this.reviews,
    required this.description,
    required this.imageUrl,
    required this.imageUrls,
    required this.amenities,
  });

  factory Residence.fromJson(Map<String, dynamic> json) {
    final detailImages = _parseStringList(
      json['detailImages'] ?? json['detailimages'],
    );

    final mainImage =
        json['imageUrl']?.toString() ??
            json['imageurl']?.toString() ??
            '';

    return Residence(
      id: json['id']?.toString() ??
          json['_id']?.toString() ??
          '',

      name: json['name']?.toString() ??
          'Unknown Residence',

      location: json['location']?.toString() ??
          'Unknown Location',

      price: _parseInt(json['price']),

      rating: _parseDouble(json['rating']),

      reviews: _parseInt(json['reviews']),

      description: json['description']?.toString() ?? '',

      imageUrl: mainImage,

      imageUrls: detailImages.isNotEmpty
          ? detailImages
          : (mainImage.isNotEmpty ? [mainImage] : []),

      amenities: _parseStringList(
        json['amenities'],
      ),
    );
  }

  static int _parseInt(dynamic value) {
    if (value is num) {
      return value.toInt();
    }

    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static double _parseDouble(dynamic value) {
    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(value?.toString() ?? '') ?? 0.0;
  }

  static List<String> _parseStringList(dynamic raw) {
    if (raw == null) {
      return [];
    }

    if (raw is List) {
      return raw
          .map((e) => e.toString())
          .where((e) => e.trim().isNotEmpty)
          .toList();
    }

    if (raw is String) {
      try {
        final decoded = jsonDecode(
          raw.replaceAll("'", '"'),
        );

        if (decoded is List) {
          return decoded
              .map((e) => e.toString())
              .where((e) => e.trim().isNotEmpty)
              .toList();
        }
      } catch (_) {
        return [];
      }
    }

    return [];
  }
}