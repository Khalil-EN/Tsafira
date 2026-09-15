import 'package:flutter/material.dart';

/// A single bookable thing shown on a suggested-plan day: a residency,
/// a restaurant/breakfast slot, an activity, or a night activity.
/// Replaces the loosely-typed Map<String, dynamic> that used to be
/// passed around and re-parsed at every call site.
class TripPlanItem {
  final String type;
  final String? section;
  final String? id;
  final String name;
  final String location;
  final String image;
  final String price;
  final double rating;
  final int reviews;
  final List<String> tags;
  final List<String> facilities;
  final List<String> images;
  final String description;
  final String openingHours;
  final String activityType;

  const TripPlanItem({
    required this.type,
    this.section,
    this.id,
    required this.name,
    required this.location,
    required this.image,
    required this.price,
    required this.rating,
    required this.reviews,
    required this.tags,
    required this.facilities,
    required this.images,
    required this.description,
    required this.openingHours,
    required this.activityType,
  });

  factory TripPlanItem.fromJson(
      Map<String, dynamic> item, {
        required String type,
        String? section,
      }) {
    final rawPrice =
        item['price'] ?? item['pricerange'] ?? item['priceRange'] ?? item['priceLevel'];
    final rawRating = item['rating'];
    final rawReviews = item['reviews'] ?? item['numberofreviews'] ?? item['numberOfReviews'];
    final rawImages = item['images'] ?? item['secondaryImages'] ?? item['secondary_images'];
    final image = item['image'] ?? item['imageurl'] ?? '';

    return TripPlanItem(
      type: type,
      section: section,
      id: (item['id'] ?? item['_id'])?.toString(),
      name: item['name']?.toString() ?? '',
      location: (item['location'] ?? item['address'] ?? '').toString(),
      image: image.toString(),
      price: rawPrice?.toString() ?? '',
      rating: rawRating is num
          ? rawRating.toDouble()
          : double.tryParse(rawRating?.toString() ?? '') ?? 0.0,
      reviews: rawReviews is num
          ? rawReviews.toInt()
          : int.tryParse(rawReviews?.toString() ?? '') ?? 0,
      tags: _normalizeStringList(item['tags']),
      facilities: _normalizeStringList(item['facilities'] ?? item['amenities']),
      images: _normalizeStringList(rawImages),
      description: item['description']?.toString() ?? '',
      openingHours: (item['openingHours'] ?? item['openinghours'] ?? '').toString(),
      activityType: (item['activityType'] ?? item['activitytype'] ?? item['type'] ?? '').toString(),
    );
  }

  factory TripPlanItem.breakfastUnavailable() {
    return const TripPlanItem(
      type: 'breakfastUnavailable',
      name: 'Breakfast unavailable',
      location: '',
      image: '',
      price: '',
      rating: 0,
      reviews: 0,
      tags: [],
      facilities: [],
      images: [],
      description:
      'Breakfast was requested, but no suitable breakfast restaurant was selected for this day.',
      openingHours: '',
      activityType: '',
    );
  }

  static List<String> _normalizeStringList(dynamic value) {
    if (value is List) {
      return value.map((e) => e.toString()).where((e) => e.trim().isNotEmpty).toList();
    }
    return [];
  }

  /// Main image plus any secondary images, de-duplicated — used by
  /// detail screens that expect a full carousel list.
  List<String> get imageUrls {
    final result = <String>[];
    final main = image.trim();
    if (main.isNotEmpty) result.add(main);
    for (final url in images) {
      final trimmed = url.trim();
      if (trimmed.isNotEmpty && !result.contains(trimmed)) result.add(trimmed);
    }
    return result;
  }

  String get typeLabel {
    switch (type) {
      case 'residency':
        return 'Accommodation';
      case 'breakfast':
        return 'Breakfast';
      case 'breakfastUnavailable':
        return 'Breakfast unavailable';
      case 'restaurant':
        return 'Restaurant';
      case 'nightActivity':
        return 'Night activity';
      case 'activity':
        if (section == 'morning') return 'Morning activity';
        if (section == 'afternoon') return 'Afternoon activity';
        return 'Activity';
      default:
        return 'Activity';
    }
  }

  IconData get icon {
    switch (type) {
      case 'residency':
        return Icons.hotel_outlined;
      case 'breakfast':
      case 'breakfastUnavailable':
        return Icons.free_breakfast_outlined;
      case 'restaurant':
        return Icons.restaurant_outlined;
      case 'nightActivity':
        return Icons.nightlife_outlined;
      case 'activity':
      default:
        return Icons.local_activity_outlined;
    }
  }

  String get priceLabel {
    final trimmed = price.trim();
    if (trimmed.isEmpty) return '';

    switch (type) {
      case 'residency':
        return '$trimmed DH / room / night';
      default:
        return '$trimmed DH / person';
    }
  }
}