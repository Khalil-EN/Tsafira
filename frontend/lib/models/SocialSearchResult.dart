class SearchResult {
  final String id;
  final String type; // "user" | "community"
  final String name;

  /// For users: profilePicture
  /// For communities: coverImage
  final String? avatar;

  final bool isFriend;
  final bool isMember;
  final bool requestSent;

  SearchResult({
    required this.id,
    required this.type,
    required this.name,
    this.avatar,
    this.isFriend = false,
    this.isMember = false,
    this.requestSent = false,
  });

  factory SearchResult.fromJson(Map<String, dynamic> json) {
    return SearchResult(
      id: (json['id'] ?? json['_id'] ?? '').toString(),
      type: (json['type'] ?? 'user').toString(),
      name: (json['name'] ?? '').toString(),

      // Backend user result uses profilePicture.
      // Backend community result uses coverImage.
      avatar: (
          json['profilePicture'] ??
              json['coverImage'] ??
              json['avatar']
      )?.toString(),

      isFriend: json['isFriend'] == true,
      isMember: json['isMember'] == true,
      requestSent: json['requestSent'] == true,
    );
  }

  SearchResult copyWith({
    bool? isFriend,
    bool? isMember,
    bool? requestSent,
    String? avatar,
  }) {
    return SearchResult(
      id: id,
      type: type,
      name: name,
      avatar: avatar ?? this.avatar,
      isFriend: isFriend ?? this.isFriend,
      isMember: isMember ?? this.isMember,
      requestSent: requestSent ?? this.requestSent,
    );
  }
}