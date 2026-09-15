import '../api_response.dart';
import '../http_client.dart';

class AuthService {
  // ============================================================
  // LOGIN
  // ============================================================

  static Future<void> login(
      Map<String, dynamic> credentials,
      ) async {
    final response = await HttpClient.request(
      method: HttpMethod.post,
      endpoint: 'auth/login',
      body: credentials,
      requiresAuth: false,
    );

    final data = ApiResponse.decodeMap(response.body);

    await TokenManager.saveTokens(
      data['accessToken'],
      data['refreshToken'],
    );
  }

  static Future<Map<String, dynamic>> loginWithUser(
      Map<String, dynamic> credentials,
      ) async {
    final response = await HttpClient.request(
      method: HttpMethod.post,
      endpoint: 'auth/login',
      body: credentials,
      requiresAuth: false,
    );

    final data = ApiResponse.decodeMap(response.body);

    await TokenManager.saveTokens(
      data['accessToken'],
      data['refreshToken'],
    );

    if (data['user'] is Map<String, dynamic>) {
      return Map<String, dynamic>.from(data['user']);
    }

    return getCurrentUser();
  }

  // ============================================================
  // REGISTER
  // ============================================================

  static Future<void> register(
      Map<String, dynamic> userData,
      ) async {
    await HttpClient.request(
      method: HttpMethod.post,
      endpoint: 'auth/register',
      body: userData,
      requiresAuth: false,
    );
  }

  // ============================================================
  // VERIFY EMAIL
  // ============================================================

  static Future<void> verifyEmail(
      String email,
      String code,
      ) async {
    await HttpClient.request(
      method: HttpMethod.post,
      endpoint: 'auth/verify-email',
      body: {
        'email': email,
        'code': code,
      },
      requiresAuth: false,
    );
  }

  // ============================================================
  // RESEND VERIFICATION CODE
  // ============================================================

  static Future<void> resendVerificationCode(
      String email,
      ) async {
    await HttpClient.request(
      method: HttpMethod.post,
      endpoint: 'auth/resend-verification',
      body: {
        'email': email,
      },
      requiresAuth: false,
    );
  }

  // ============================================================
  // LOGOUT
  // ============================================================

  static Future<void> logout() async {
    final refreshToken =
    await TokenManager.getRefreshToken();

    try {
      await HttpClient.request(
        method: HttpMethod.post,
        endpoint: 'auth/logout',
        body: {
          'refreshToken': refreshToken,
        },
        requiresAuth: false,
      );
    } finally {
      await TokenManager.clearTokens();
    }
  }

  // ============================================================
  // CURRENT USER
  // ============================================================

  static Future<Map<String, dynamic>> getCurrentUser() async {
    final response = await HttpClient.request(
      method: HttpMethod.get,
      endpoint: 'auth/me',
    );

    return ApiResponse.decodeMap(response.body);
  }

  // ============================================================
  // AUTHENTICATION STATE
  // ============================================================

  static Future<bool> isAuthenticated() async {
    final refreshToken = await TokenManager.getRefreshToken();

    if (refreshToken == null || refreshToken.isEmpty) {
      return false;
    }

    try {
      await getCurrentUser();
      return true;
    } catch (_) {
      await TokenManager.clearTokens();
      return false;
    }
  }

  static Future<Map<String, dynamic>> updateProfile(
      Map<String, dynamic> updates,
      ) async {
    final response = await HttpClient.request(
      method: HttpMethod.put,
      endpoint: 'users/me',
      body: updates,
    );

    return ApiResponse.decodeMap(response.body);
  }

  static Future<void> deleteAccount() async {
    await HttpClient.request(
      method: HttpMethod.delete,
      endpoint: 'users/me',
    );

    await TokenManager.clearTokens();
  }
}