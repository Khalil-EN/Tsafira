import '../api_response.dart';
import '../http_client.dart';

class ActivityService {
  // ============================================================
  // GET ALL
  // ============================================================

  static Future<List<Map<String, dynamic>>> getAll() async {
    final response = await HttpClient.request(
      method: HttpMethod.get,
      endpoint: 'activities',
    );

    return ApiResponse.decodeList(response.body)
        .map((item) => Map<String, dynamic>.from(item))
        .toList();
  }
}