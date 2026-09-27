import '../../api_response.dart';
import '../../http_client.dart';

class RequestService {

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

  static Future<void> acceptRequest(
      String requestId,
      ) async {
    await HttpClient.request(
      method: HttpMethod.post,
      endpoint:
      'requests/$requestId/accept',
    );
  }

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