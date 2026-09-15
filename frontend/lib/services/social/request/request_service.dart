import '../../api_response.dart';
import '../../http_client.dart';

class RequestService {

  // ============================================================
  // REQUESTS
  // ============================================================

  static Future<
      Map<String, List<Map<String, dynamic>>>
  > getRequests() async {
    final response = await HttpClient.request(
      method: HttpMethod.get,
      endpoint: 'requests',
    );

    final data =
    ApiResponse.decodeMap(response.body);

    return {
      'received':
      List<Map<String, dynamic>>.from(
        data['received'] ?? [],
      ),
      'sent':
      List<Map<String, dynamic>>.from(
        data['sent'] ?? [],
      ),
    };
  }

  // ============================================================
  // PENDING RECEIVED REQUEST COUNT
  // ============================================================

  static Future<int> getPendingReceivedCount() async {
    final requests =
    await getRequests();

    final received =
        requests['received'] ?? [];

    return received.where((request) {
      return request['status']
          ?.toString()
          .toLowerCase() ==
          'pending';
    }).length;
  }

  // ============================================================
  // ACCEPT
  // ============================================================

  static Future<void> acceptRequest(
      String requestId,
      ) async {
    await HttpClient.request(
      method: HttpMethod.post,
      endpoint:
      'requests/$requestId/accept',
    );
  }

  // ============================================================
  // REJECT
  // ============================================================

  static Future<void> rejectRequest(
      String requestId,
      ) async {
    await HttpClient.request(
      method: HttpMethod.post,
      endpoint:
      'requests/$requestId/reject',
    );
  }
}