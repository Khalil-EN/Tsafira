import '../api_response.dart';
import '../http_client.dart';

class SearchService {
  // ============================================================
  // USERS + COMMUNITIES
  // ============================================================

  static Future<List<Map<String, dynamic>>> searchUsersAndCommunities({
    required String query,
    List<String>? types,
  }) async {
    final response = await HttpClient.request(
      method: HttpMethod.post,
      endpoint: 'search/users-communities',
      body: {
        'query': query,
        'types': types ?? [
          'user',
          'community',
        ],
      },
    );

    print('SEARCH RESPONSE: ${response.body}');

    return ApiResponse.decodeList(response.body)
        .map((item) => Map<String, dynamic>.from(item))
        .toList();
  }

  // ============================================================
  // RESIDENCES
  // ============================================================

  static Future<List<Map<String, dynamic>>> searchResidences(
      Map<String, dynamic> filters,
      ) async {
    final response = await HttpClient.request(
      method: HttpMethod.post,
      endpoint: 'search/residences',
      body: filters,
    );

    return ApiResponse.decodeList(response.body)
        .map((item) => Map<String, dynamic>.from(item))
        .toList();
  }

  // ============================================================
  // RESTAURANTS
  // ============================================================

  static Future<List<Map<String, dynamic>>> searchRestaurants(
      Map<String, dynamic> filters,
      ) async {
    final response = await HttpClient.request(
      method: HttpMethod.post,
      endpoint: 'search/restaurants',
      body: filters,
    );

    return ApiResponse.decodeList(response.body)
        .map((item) => Map<String, dynamic>.from(item))
        .toList();
  }

  // ============================================================
  // ACTIVITIES
  // ============================================================

  static Future<List<Map<String, dynamic>>> searchActivities(
      Map<String, dynamic> filters,
      ) async {
    final response = await HttpClient.request(
      method: HttpMethod.post,
      endpoint: 'search/activities',
      body: filters,
    );

    return ApiResponse.decodeList(response.body)
        .map((item) => Map<String, dynamic>.from(item))
        .toList();
  }
}