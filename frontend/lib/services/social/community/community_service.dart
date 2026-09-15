import '../../api_response.dart';
import '../../http_client.dart';

class CommunityService {
  // ============================================================
  // CREATE
  // ============================================================

  static Future<Map<String, dynamic>> create({
    required String name,
    required String description,
  }) async {
    final response = await HttpClient.request(
      method: HttpMethod.post,
      endpoint: 'communities',
      body: {
        'name': name,
        'description': description,
      },
    );

    return ApiResponse.decodeMap(response.body);
  }

  // ============================================================
  // GET ALL
  // ============================================================

  static Future<List<Map<String, dynamic>>> getAll() async {
    final response = await HttpClient.request(
      method: HttpMethod.get,
      endpoint: 'communities',
    );

    return ApiResponse.decodeList(response.body)
        .map((item) => Map<String, dynamic>.from(item))
        .toList();
  }

  // ============================================================
  // GET BY ID
  // ============================================================

  static Future<Map<String, dynamic>> getById(
      String communityId,
      ) async {
    final response = await HttpClient.request(
      method: HttpMethod.get,
      endpoint: 'communities/$communityId',
    );

    return ApiResponse.decodeMap(response.body);
  }

  // ============================================================
  // JOIN REQUEST
  // ============================================================

  static Future<void> requestToJoinById(
      String communityId,
      ) async {
    await HttpClient.request(
      method: HttpMethod.post,
      endpoint: 'communities/$communityId/join',
    );
  }

  // ============================================================
  // MEMBERS
  // ============================================================

  static Future<List<Map<String, dynamic>>> getMembers(
      String communityId,
      ) async {
    final response = await HttpClient.request(
      method: HttpMethod.get,
      endpoint: 'communities/$communityId/members',
    );

    return ApiResponse.decodeList(response.body)
        .map((item) => Map<String, dynamic>.from(item))
        .toList();
  }

  // ============================================================
  // APPROVE MEMBER
  // ============================================================

  static Future<void> approveMember({
    required String communityId,
    required String userId,
  }) async {
    await HttpClient.request(
      method: HttpMethod.post,
      endpoint:
      'communities/$communityId/members/$userId/approve',
    );
  }

  // ============================================================
  // MY COMMUNITIES
  // ============================================================

  static Future<List<Map<String, dynamic>>> getMine() async {
    final response = await HttpClient.request(
      method: HttpMethod.get,
      endpoint: 'communities/mine',
    );

    return ApiResponse.decodeList(response.body)
        .map((item) => Map<String, dynamic>.from(item))
        .toList();
  }

  // ============================================================
  // UPDATE
  // ============================================================

  static Future<Map<String, dynamic>> update({
    required String communityId,
    required Map<String, dynamic> data,
  }) async {
    final response = await HttpClient.request(
      method: HttpMethod.put,
      endpoint: 'communities/$communityId',
      body: data,
    );

    return ApiResponse.decodeMap(response.body);
  }

  // ============================================================
  // DELETE
  // ============================================================

  static Future<void> delete(
      String communityId,
      ) async {
    await HttpClient.request(
      method: HttpMethod.delete,
      endpoint: 'communities/$communityId',
    );
  }

  static Future<List<Map<String, dynamic>>> getPendingRequests(
      String communityId,
      ) async {
    final response = await HttpClient.request(
      method: HttpMethod.get,
      endpoint: 'communities/$communityId/requests',
    );

    return ApiResponse.decodeList(response.body)
        .map((item) => Map<String, dynamic>.from(item))
        .toList();
  }

  static Future<void> rejectMember({
    required String communityId,
    required String userId,
  }) async {
    await HttpClient.request(
      method: HttpMethod.post,
      endpoint: 'communities/$communityId/members/$userId/reject',
    );
  }

  static Future<void> promoteMember({
    required String communityId,
    required String userId,
    required String role,
  }) async {
    await HttpClient.request(
      method: HttpMethod.post,
      endpoint: 'communities/$communityId/members/$userId/promote',
      body: {'role': role},
    );
  }

  static Future<void> banMember({
    required String communityId,
    required String userId,
  }) async {
    await HttpClient.request(
      method: HttpMethod.post,
      endpoint: 'communities/$communityId/members/$userId/ban',
    );
  }
}