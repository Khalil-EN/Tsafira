import 'package:flutter/material.dart';

import '../services/auth/auth_service.dart';

class UserProvider extends ChangeNotifier {
  Map<String, dynamic>? _user;

  Map<String, dynamic>? get user => _user;

  bool get isAdmin => _user?['role'] == 'admin';
  bool get isLoggedIn => _user != null;

  String? get userId =>
      (_user?['id'] ?? _user?['_id'])?.toString();

  String get firstName => _user?['firstName'] ?? '';
  String get lastName => _user?['lastName'] ?? '';
  String get email => _user?['email'] ?? '';
  String get fullName => '$firstName $lastName'.trim();

  String? get avatar => _user?['profilePicture'];

  void setUser(Map<String, dynamic> user) {
    _user = user;
    notifyListeners();
  }

  void clearUser() {
    _user = null;
    notifyListeners();
  }

  Future<void> refreshUser() async {
    final user = await AuthService.getCurrentUser();

    _user = user;
    notifyListeners();
  }
}