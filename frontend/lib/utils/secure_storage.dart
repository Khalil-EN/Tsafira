import 'package:flutter_secure_storage/flutter_secure_storage.dart';

final storage = FlutterSecureStorage();

Future<void> saveTokens(String accessToken, String refreshToken) async {
  await storage.write(key: 'accessToken', value: accessToken);
  await storage.write(key: 'refreshToken', value: refreshToken);
}

Future<String?> readAccessToken() async {
  return await storage.read(key: 'accessToken');
}

Future<String?> readRefreshToken() async {
  return await storage.read(key: 'refreshToken');
}

Future<void> deleteTokens() async {
  await storage.delete(key: 'accessToken');
  await storage.delete(key: 'refreshToken');
}
