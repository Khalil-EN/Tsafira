class Activity {
  final String id;
  final String name;
  final String location;
  final double rating;
  final int reviews;
  final String type;
  final String imageUrl;
  final String price;
  final List<String> highlights;
  final Map<String, String> schedule;
  final List<String> itemsToBring;

  const Activity({
    required this.id,
    required this.name,
    required this.location,
    required this.rating,
    required this.reviews,
    required this.type,
    required this.imageUrl,
    this.price = 'Free',
    this.highlights = const [],
    this.schedule = const {},
    this.itemsToBring = const [],
  });

  factory Activity.fromJson(Map<String, dynamic> json) {
    return Activity(
      id: json['id']?.toString() ??
          json['_id']?.toString() ??
          '',

      name: json['name']?.toString() ??
          json['title']?.toString() ??
          'Unnamed Activity',

      location: json['location']?.toString() ??
          'Location unknown',

      rating: _parseNum(json['rating']).toDouble(),

      reviews: _parseNum(json['reviews']).toInt(),

      type: json['type']?.toString() ?? '',

      imageUrl: json['image']?.toString() ??
          json['imageUrl']?.toString() ??
          json['imageurl']?.toString() ??
          '',

      price: json['price']?.toString() ?? 'Free',

      highlights: _parseStringList(
        json['highlights'],
      ),

      schedule: _parseSchedule(
        json['schedule'],
      ),

      itemsToBring: _parseStringList(
        json['itemsToBring'],
      ),
    );
  }

  static num _parseNum(dynamic value) {
    if (value is num) {
      return value;
    }

    return num.tryParse(
      value?.toString() ?? '',
    ) ??
        0;
  }

  static List<String> _parseStringList(dynamic value) {
    if (value is List) {
      return value
          .map((e) => e.toString())
          .where((e) => e.trim().isNotEmpty)
          .toList();
    }

    return [];
  }

  static Map<String, String> _parseSchedule(dynamic value) {
    if (value is Map) {
      return value.map(
            (key, value) => MapEntry(
          key.toString(),
          value.toString(),
        ),
      );
    }

    return {};
  }
}