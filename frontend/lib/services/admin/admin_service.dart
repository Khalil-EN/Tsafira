import '../api_response.dart';
import '../http_client.dart';

class AdminService {
  // ============================================================
  // USERS
  // ============================================================

  static Future<Map<String, dynamic>> getUsers({
    int page = 1,
    int limit = 20,
  }) async {
    final response = await HttpClient.request(
      method: HttpMethod.get,
      endpoint: 'admin/users',
      queryParams: {
        'page': page.toString(),
        'limit': limit.toString(),
      },
    );

    return ApiResponse.decodeMap(response.body);
  }

  static Future<void> banUser(
      String userId,
      ) async {
    await HttpClient.request(
      method: HttpMethod.patch,
      endpoint: 'admin/users/$userId/ban',
    );
  }

  static Future<void> unbanUser(
      String userId,
      ) async {
    await HttpClient.request(
      method: HttpMethod.patch,
      endpoint: 'admin/users/$userId/unban',
    );
  }

  // ============================================================
  // CONTENT
  // ============================================================

  static Future<void> deletePost(
      String postId,
      ) async {
    await HttpClient.request(
      method: HttpMethod.delete,
      endpoint: 'admin/posts/$postId',
    );
  }

  // ============================================================
  // ANALYTICS
  // ============================================================

  static Future<List<dynamic>> getEventCounts({
    String? from,
    String? to,
    String groupBy = 'event',
  }) async {
    final queryParams = <String, String>{
      'groupBy': groupBy,
    };

    if (from != null) {
      queryParams['from'] = from;
    }

    if (to != null) {
      queryParams['to'] = to;
    }

    final response = await HttpClient.request(
      method: HttpMethod.get,
      endpoint: 'admin/analytics/events',
      queryParams: queryParams,
    );

    return ApiResponse.decodeList(response.body);
  }

  static Future<List<dynamic>> getDailyActiveUsers({
    String? from,
    String? to,
  }) async {
    final queryParams = <String, String>{};

    if (from != null) {
      queryParams['from'] = from;
    }

    if (to != null) {
      queryParams['to'] = to;
    }

    final response = await HttpClient.request(
      method: HttpMethod.get,
      endpoint: 'admin/analytics/dau',
      queryParams: queryParams,
    );

    return ApiResponse.decodeList(response.body);
  }

  static Future<List<dynamic>> getRecentEvents({
    int? limit,
    String? event,
    String? userId,
  }) async {
    final queryParams = <String, String>{};

    if (limit != null) {
      queryParams['limit'] = limit.toString();
    }

    if (event != null) {
      queryParams['event'] = event;
    }

    if (userId != null) {
      queryParams['userId'] = userId;
    }

    final response = await HttpClient.request(
      method: HttpMethod.get,
      endpoint: 'admin/analytics/recent',
      queryParams: queryParams,
    );

    return ApiResponse.decodeList(response.body);
  }

  // ============================================================
  // BROADCAST NOTIFICATION
  // ============================================================

  static Future<int> broadcastNotification({
    required dynamic recipientIds,
    required String title,
    required String body,
  }) async {
    final response = await HttpClient.request(
      method: HttpMethod.post,
      endpoint: 'admin/notifications/broadcast',
      body: {
        'recipientIds': recipientIds,
        'title': title,
        'body': body,
      },
    );

    final data = ApiResponse.decodeMap(response.body);

    return (data['sent'] as num?)?.toInt() ?? 0;
  }
}