import 'package:flutter/foundation.dart';

import '../models/post_draft.dart';

class PostComposerProvider extends ChangeNotifier {
  PostDraft _draft = const PostDraft();

  bool _isSubmitting = false;
  String? _error;

  PostDraft get draft => _draft;

  bool get isSubmitting => _isSubmitting;

  String? get error => _error;

  bool get canSubmit =>
      _draft.canSubmit && !_isSubmitting;

  void setText(String text) {
    _draft = _draft.copyWith(text: text);
    _clearError();
    notifyListeners();
  }

  void setVisibility(String visibility) {
    _draft = _draft.copyWith(
      visibility: visibility,
    );

    _clearError();
    notifyListeners();
  }

  void setCommunity(String? communityId) {
    _draft = _draft.copyWith(
      communityId: communityId,
      clearCommunity: communityId == null,
    );

    _clearError();
    notifyListeners();
  }

  void setLocation(String? location) {
    _draft = _draft.copyWith(
      location: location,
      clearLocation: location == null,
    );

    _clearError();
    notifyListeners();
  }

  void addImage(String path) {
    if (path.isEmpty) return;

    if (_draft.imagePaths.contains(path)) {
      return;
    }

    _draft = _draft.copyWith(
      imagePaths: [
        ..._draft.imagePaths,
        path,
      ],
    );

    _clearError();
    notifyListeners();
  }

  void addImages(List<String> paths) {
    final newPaths = paths
        .where(
          (path) =>
      path.isNotEmpty &&
          !_draft.imagePaths.contains(path),
    )
        .toList();

    if (newPaths.isEmpty) return;

    _draft = _draft.copyWith(
      imagePaths: [
        ..._draft.imagePaths,
        ...newPaths,
      ],
    );

    _clearError();
    notifyListeners();
  }

  void removeImage(String path) {
    _draft = _draft.copyWith(
      imagePaths: _draft.imagePaths
          .where((image) => image != path)
          .toList(),
    );

    notifyListeners();
  }

  void removeImageAt(int index) {
    if (index < 0 ||
        index >= _draft.imagePaths.length) {
      return;
    }

    final images = [..._draft.imagePaths];
    images.removeAt(index);

    _draft = _draft.copyWith(
      imagePaths: images,
    );

    notifyListeners();
  }

  void reorderImages(
      int oldIndex,
      int newIndex,
      ) {
    final images = [..._draft.imagePaths];

    if (oldIndex < 0 ||
        oldIndex >= images.length) {
      return;
    }

    if (newIndex < 0 ||
        newIndex > images.length) {
      return;
    }

    if (oldIndex < newIndex) {
      newIndex -= 1;
    }

    final image = images.removeAt(oldIndex);
    images.insert(newIndex, image);

    _draft = _draft.copyWith(
      imagePaths: images,
    );

    notifyListeners();
  }

  void clear() {
    _draft = const PostDraft();
    _error = null;
    _isSubmitting = false;
    notifyListeners();
  }

  void setSubmitting(bool value) {
    _isSubmitting = value;
    notifyListeners();
  }

  void setError(String? error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    if (_error != null) {
      _error = null;
    }
  }
}