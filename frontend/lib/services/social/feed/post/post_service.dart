import '../../../api_response.dart';
import '../../../http_client.dart';

class PostService {
  // ============================================================
  // CREATE
  // ============================================================

  static Future<Map<String, dynamic>> create(
      Map<String, dynamic> postData,
      ) async {
    final response = await HttpClient.request(
      method: HttpMethod.post,
      endpoint: 'posts',
      body: postData,
    );

    return ApiResponse.decodeMap(response.body);
  }

  static Future<List<Map<String, dynamic>>> getCommunityFeed(
      String communityId, {
        int page = 1,
        int limit = 20,
      }) async {
    final response = await HttpClient.request(
      method: HttpMethod.get,
      endpoint: 'communities/$communityId/posts',
      queryParams: {
        'page': page.toString(),
        'limit': limit.toString(),
      },
    );

    return ApiResponse.decodeList(response.body)
        .map((item) => Map<String, dynamic>.from(item))
        .toList();
  }

  // ============================================================
  // GET POST
  // ============================================================

  static Future<Map<String, dynamic>> getById(
      String postId,
      ) async {
    final response = await HttpClient.request(
      method: HttpMethod.get,
      endpoint: 'posts/$postId',
    );

    return ApiResponse.decodeMap(response.body);
  }

  // ============================================================
  // LIKE
  // ============================================================

  static Future<Map<String, dynamic>> like(
      String postId,
      ) async {
    final response = await HttpClient.request(
      method: HttpMethod.post,
      endpoint: 'posts/$postId/like',
    );

    return ApiResponse.decodeMap(response.body);
  }

  // ============================================================
  // DELETE
  // ============================================================

  static Future<Map<String, dynamic>> update(
      String postId,
      String text,
      ) async {
    final response = await HttpClient.request(
      method: HttpMethod.put,
      endpoint: 'posts/$postId',
      body: {'text': text},
    );

    return ApiResponse.decodeMap(response.body);
  }

  static Future<void> delete(String postId) async {
    await HttpClient.request(
      method: HttpMethod.delete,
      endpoint: 'posts/$postId',
    );
  }
}