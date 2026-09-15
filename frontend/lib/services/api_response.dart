import 'dart:convert';

class ApiResponse {
  static dynamic decode(String body) {
    final decoded = jsonDecode(body);

    if (decoded is Map<String, dynamic> &&
        decoded.containsKey('success') &&
        decoded.containsKey('data')) {
      return decoded['data'];
    }

    return decoded;
  }

  static Map<String, dynamic> decodeMap(String body) {
    final data = decode(body);

    if (data is! Map<String, dynamic>) {
      throw Exception(
        'Expected an object but got: ${data.runtimeType}',
      );
    }

    return data;
  }

  static List<dynamic> decodeList(String body) {
    final data = decode(body);

    if (data is! List) {
      throw Exception(
        'Expected a list but got: ${data.runtimeType}',
      );
    }

    return data;
  }
}