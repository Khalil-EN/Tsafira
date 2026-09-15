import '../../api_response.dart';
import '../../http_client.dart';

class FeedService {
  // ============================================================
  // GET FEED
  // ============================================================

  static Future<List<Map<String, dynamic>>> getFeed({
    int page = 1,
    int limit = 20,
  }) async {
    final response = await HttpClient.request(
      method: HttpMethod.get,
      endpoint: 'feed',
      queryParams: {
        'page': page.toString(),
        'limit': limit.toString(),
      },
    );

    return ApiResponse.decodeList(response.body)
        .map((item) => Map<String, dynamic>.from(item))
        .toList();
  }
}