import '../../../../api_response.dart';
import '../../../../http_client.dart';

class CommentService {
  static Future<List<Map<String, dynamic>>> getByPost(
      String postId,
      ) async {
    final response = await HttpClient.request(
      method: HttpMethod.get,
      endpoint: 'posts/$postId/comments',
    );

    return ApiResponse.decodeList(response.body)
        .map(
          (item) => Map<String, dynamic>.from(item),
    )
        .toList();
  }

  static Future<Map<String, dynamic>> create({
    required String postId,
    required String text,
    String? parentCommentId,
  }) async {
    final body = <String, dynamic>{
      'postId': postId,
      'text': text,
    };

    if (parentCommentId != null &&
        parentCommentId.isNotEmpty) {
      body['parentCommentId'] = parentCommentId;
    }

    final response = await HttpClient.request(
      method: HttpMethod.post,
      endpoint: 'comments',
      body: body,
    );

    return ApiResponse.decodeMap(response.body);
  }

  static Future<Map<String, dynamic>> like(
      String commentId,
      ) async {
    final response = await HttpClient.request(
      method: HttpMethod.post,
      endpoint: 'comments/$commentId/like',
    );

    return ApiResponse.decodeMap(response.body);
  }

  static Future<void> delete(
      String commentId,
      ) async {
    await HttpClient.request(
      method: HttpMethod.delete,
      endpoint: 'comments/$commentId',
    );
  }

  static Future<Map<String, dynamic>> update(
      String commentId,
      String text,
      ) async {
    final response = await HttpClient.request(
      method: HttpMethod.put,
      endpoint: 'comments/$commentId',
      body: {'text': text},
    );

    return ApiResponse.decodeMap(response.body);
  }
}