class PostAuthor {
  final String id;
  final String firstName;
  final String lastName;
  final String fullName;
  final String? profilePicture;

  const PostAuthor({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.fullName,
    this.profilePicture,
  });

  factory PostAuthor.fromJson(Map<String, dynamic> json) {
    final firstName = (json['firstName'] ?? '').toString();
    final lastName = (json['lastName'] ?? '').toString();

    return PostAuthor(
      id: (json['id'] ?? json['_id'] ?? '').toString(),
      firstName: firstName,
      lastName: lastName,
      fullName: (json['fullName'] ??
          '$firstName $lastName'.trim())
          .toString(),
      profilePicture: json['profilePicture']?.toString(),
    );
  }
}

class PostCommunity {
  final String id;
  final String? name;

  const PostCommunity({
    required this.id,
    this.name,
  });

  factory PostCommunity.fromJson(Map<String, dynamic> json) {
    return PostCommunity(
      id: (json['id'] ?? json['_id'] ?? '').toString(),
      name: json['name']?.toString(),
    );
  }
}

class Post {
  final String id;
  final String text;
  final List<String> images;
  final String visibility;
  final PostAuthor? author;
  final PostCommunity? community;
  final int likesCount;
  final int commentsCount;
  final bool isEdited;
  final DateTime? createdAt;
  final bool liked;

  const Post({
    required this.id,
    required this.text,
    this.images = const [],
    this.visibility = 'community',
    this.author,
    this.community,
    this.likesCount = 0,
    this.commentsCount = 0,
    this.isEdited = false,
    this.createdAt,
    this.liked = false,
  });

  factory Post.fromJson(
      Map<String, dynamic> json, {
        String? currentUserId,
      }) {
    final rawImages = json['images'];

    final images = rawImages is List
        ? rawImages
        .map((image) => image.toString())
        .where((image) => image.isNotEmpty)
        .toList()
        : <String>[];

    return Post(
      id: (json['id'] ?? json['_id'] ?? '').toString(),
      text: (json['text'] ?? '').toString(),
      images: images,
      visibility: (json['visibility'] ?? 'community').toString(),
      author: json['author'] is Map<String, dynamic>
          ? PostAuthor.fromJson(
        Map<String, dynamic>.from(json['author']),
      )
          : null,
      community: json['community'] is Map<String, dynamic>
          ? PostCommunity.fromJson(
        Map<String, dynamic>.from(json['community']),
      )
          : null,
      likesCount: _parseInt(json['likesCount']),
      commentsCount: _parseInt(json['commentsCount']),
      isEdited: json['isEdited'] == true,
      createdAt: _parseDate(json['createdAt']),
      liked: json['liked'] == true || _parseLiked(json, currentUserId),
    );
  }

  Post copyWith({
    String? text,
    List<String>? images,
    String? visibility,
    PostAuthor? author,
    PostCommunity? community,
    int? likesCount,
    int? commentsCount,
    bool? isEdited,
    DateTime? createdAt,
    bool? liked,
  }) {
    return Post(
      id: id,
      text: text ?? this.text,
      images: images ?? this.images,
      visibility: visibility ?? this.visibility,
      author: author ?? this.author,
      community: community ?? this.community,
      likesCount: likesCount ?? this.likesCount,
      commentsCount: commentsCount ?? this.commentsCount,
      isEdited: isEdited ?? this.isEdited,
      createdAt: createdAt ?? this.createdAt,
      liked: liked ?? this.liked,
    );
  }

  static int _parseInt(dynamic value) {
    if (value is int) return value;
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    return DateTime.tryParse(value.toString());
  }

  static bool _parseLiked(
      Map<String, dynamic> json,
      String? currentUserId,
      ) {
    if (json['liked'] is bool) {
      return json['liked'] == true;
    }

    final likes = json['likes'];

    if (likes is! List || currentUserId == null) {
      return false;
    }

    return likes.any(
          (id) => id.toString() == currentUserId,
    );
  }
}