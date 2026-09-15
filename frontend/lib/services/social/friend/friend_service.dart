import '../../api_response.dart';
import '../../http_client.dart';

class FriendService {
  /// Send a friend request to another user.
  static Future<void> sendFriendRequest(
      String targetUserId,
      ) async {
    await HttpClient.request(
      method: HttpMethod.post,
      endpoint: 'friends/request',
      body: {
        'targetUserId': targetUserId,
      },
    );
  }

  /// Get the current user's accepted friends.
  static Future<List<Map<String, dynamic>>> getAll() async {
    final response = await HttpClient.request(
      method: HttpMethod.get,
      endpoint: 'friends',
    );

    return ApiResponse.decodeList(response.body)
        .map(
          (item) => Map<String, dynamic>.from(item),
    )
        .toList();
  }
}