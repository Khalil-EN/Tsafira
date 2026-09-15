class PostDraft {
  final String text;
  final List<String> imagePaths;
  final String visibility;
  final String? communityId;
  final String? location;

  const PostDraft({
    this.text = '',
    this.imagePaths = const [],
    this.visibility = 'community',
    this.communityId,
    this.location,
  });

  PostDraft copyWith({
    String? text,
    List<String>? imagePaths,
    String? visibility,
    String? communityId,
    String? location,
    bool clearCommunity = false,
    bool clearLocation = false,
  }) {
    return PostDraft(
      text: text ?? this.text,
      imagePaths: imagePaths ?? this.imagePaths,
      visibility: visibility ?? this.visibility,
      communityId:
      clearCommunity ? null : communityId ?? this.communityId,
      location:
      clearLocation ? null : location ?? this.location,
    );
  }

  bool get hasText => text.trim().isNotEmpty;

  bool get hasImages => imagePaths.isNotEmpty;

  bool get canSubmit => hasText;

  Map<String, dynamic> toRequestBody() {
    return {
      'text': text.trim(),
      'images': imagePaths,
      'visibility': visibility,
      if (communityId != null) 'community': communityId,
    };
  }
}