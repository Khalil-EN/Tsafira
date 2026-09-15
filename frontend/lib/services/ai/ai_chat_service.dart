import '../api_response.dart';
import '../http_client.dart';

class AIChatService {
  // ============================================================
  // Get or create the user's AI conversation
  // ============================================================

  static Future<Map<String, dynamic>>
  getOrCreateConversation() async {
    final response = await HttpClient.request(
      method: HttpMethod.post,
      endpoint: 'ai/conversation',
    );

    return ApiResponse.decodeMap(
      response.body,
    );
  }

  // ============================================================
  // Send a message to the AI
  // ============================================================

  static Future<Map<String, dynamic>>
  sendMessage({
    required String conversationId,
    required String message,
  }) async {
    final response = await HttpClient.request(
      method: HttpMethod.post,
      endpoint: 'ai/chat',
      body: {
        'conversationId': conversationId,
        'content': message,
      },
    );

    return ApiResponse.decodeMap(
      response.body,
    );
  }
}