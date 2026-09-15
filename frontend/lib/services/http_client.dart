import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../exceptions/premium_required_exception.dart';
import '../exceptions/session_expired_exception.dart';

class HttpClient {
  static const String baseUrl = 'http://10.243.134.48:8000/api/'; // 192.168.1.84
  static final FlutterSecureStorage _storage = FlutterSecureStorage();

  static Future<http.Response> request({
    required HttpMethod method,
    required String endpoint,
    Map<String, dynamic>? body,
    Map<String, String>? queryParams,
    bool requiresAuth = true,
    bool handlePremiumException = false,
  }) async {
    String? accessToken;
    String? refreshToken;

    if (requiresAuth) {
      accessToken = await _storage.read(key: 'accessToken');
      refreshToken = await _storage.read(key: 'refreshToken');
    }

    Uri uri = Uri.parse('$baseUrl$endpoint');
    if (queryParams != null) {
      uri = uri.replace(queryParameters: queryParams);
    }

    http.Response response = await _execute(
      method: method,
      uri: uri,
      body: body,
      token: accessToken,
    );

    if (requiresAuth && response.statusCode == 401 &&
        refreshToken != null && refreshToken.isNotEmpty) {
      final refreshed = await _refreshAccessToken(refreshToken);
      if (!refreshed) {
        throw SessionExpiredException('Session expired. Please log in again.');
      }
      accessToken = await _storage.read(key: 'accessToken');
      response = await _execute(
        method: method,
        uri: uri,
        body: body,
        token: accessToken,
      );
    }

    if (handlePremiumException && response.statusCode == 405) {
      final decoded = jsonDecode(response.body);
      if (decoded['error'] == 'LIMIT_REACHED') {
        throw PremiumRequiredException();
      }
    }

    if (response.statusCode >= 400) {
      throw HttpException(
        statusCode: response.statusCode,
        message: response.body,
      );
    }

    return response;
  }

  static Future<http.Response> _execute({
    required HttpMethod method,
    required Uri uri,
    Map<String, dynamic>? body,
    String? token,
  }) async {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };

    switch (method) {
      case HttpMethod.get:
        return await http.get(uri, headers: headers);
      case HttpMethod.post:
        return await http.post(uri,
            headers: headers,
            body: body != null ? jsonEncode(body) : null);
      case HttpMethod.put:
        return await http.put(uri,
            headers: headers,
            body: body != null ? jsonEncode(body) : null);
      case HttpMethod.patch:
        return await http.patch(uri,
            headers: headers,
            body: body != null ? jsonEncode(body) : null);
      case HttpMethod.delete:
        return await http.delete(uri, headers: headers);
    }
  }

  static Future<bool> _refreshAccessToken(String refreshToken) async {
    try {
      final response = await http.post(
        Uri.parse('${baseUrl}refresh'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'refreshToken': refreshToken}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        await _storage.write(key: 'accessToken', value: data['accessToken']);
        return true;
      }

      await TokenManager.clearTokens();
      return false;
    } catch (e) {
      await TokenManager.clearTokens();
      return false;
    }
  }
}

class TokenManager {
  static final FlutterSecureStorage _storage = FlutterSecureStorage();

  static Future<void> saveTokens(
      String accessToken, String refreshToken) async {
    await _storage.write(key: 'accessToken', value: accessToken);
    await _storage.write(key: 'refreshToken', value: refreshToken);
  }

  static Future<void> clearTokens() async {
    await _storage.delete(key: 'accessToken');
    await _storage.delete(key: 'refreshToken');
  }

  static Future<String?> getAccessToken() async {
    return await _storage.read(key: 'accessToken');
  }

  static Future<String?> getRefreshToken() async {
    return await _storage.read(key: 'refreshToken');
  }
}

enum HttpMethod { get, post, put, patch, delete }

class HttpException implements Exception {
  final int statusCode;
  final String message;

  HttpException({required this.statusCode, required this.message});

  @override
  String toString() => 'HttpException: $statusCode - $message';
}