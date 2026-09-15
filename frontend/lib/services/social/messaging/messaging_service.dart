import '../../api_response.dart';
import '../../http_client.dart';

class MessagingService {

  // ============================================================
  // INBOX
  // ============================================================

  static Future<List<Map<String, dynamic>>> getChats({
    int page = 1,
    int limit = 20,
  }) async {
    final response = await HttpClient.request(
      method: HttpMethod.get,
      endpoint: 'chats',
      queryParams: {
        'page': page.toString(),
        'limit': limit.toString(),
      },
    );

    return ApiResponse.decodeList(response.body)
        .map(
          (item) => Map<String, dynamic>.from(item),
    )
        .toList();
  }

  // ============================================================
  // GET OR CREATE DIRECT CHAT
  // ============================================================

  static Future<Map<String, dynamic>>
  getOrCreateDirectChat(
      String participantId,
      ) async {
    final response = await HttpClient.request(
      method: HttpMethod.post,
      endpoint: 'chats',
      body: {
        'participantId': participantId,
      },
    );

    return ApiResponse.decodeMap(
      response.body,
    );
  }

  // ============================================================
  // MESSAGES
  // ============================================================

  static Future<List<Map<String, dynamic>>> getMessages({
    required String conversationId,
    int page = 1,
    int limit = 30,
  }) async {
    final response = await HttpClient.request(
      method: HttpMethod.get,
      endpoint:
      'chats/$conversationId/messages',
      queryParams: {
        'page': page.toString(),
        'limit': limit.toString(),
      },
    );

    return ApiResponse.decodeList(response.body)
        .map(
          (item) => Map<String, dynamic>.from(item),
    )
        .toList();
  }

  // ============================================================
  // MARK CONVERSATION AS READ
  // ============================================================

  static Future<void> markConversationAsRead(
      String conversationId,
      ) async {
    await HttpClient.request(
      method: HttpMethod.post,
      endpoint:
      'chats/$conversationId/read',
    );
  }

  // ============================================================
  // SEND MESSAGE
  // ============================================================

  static Future<Map<String, dynamic>> sendMessage({
    required String conversationId,
    required String content,
  }) async {
    final response = await HttpClient.request(
      method: HttpMethod.post,
      endpoint: 'messages',
      body: {
        'conversationId': conversationId,
        'content': content,
      },
    );

    return ApiResponse.decodeMap(
      response.body,
    );
  }
}