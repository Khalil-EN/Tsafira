import '../api_response.dart';
import '../http_client.dart';

class ItineraryService {
  // ============================================================
  // GENERATE SUGGESTED ITINERARY
  // ============================================================

  static Future<Map<String, dynamic>> generateSuggested(
      Map<String, dynamic> itineraryData,
      ) async {
    final response = await HttpClient.request(
      method: HttpMethod.post,
      endpoint: 'itineraries/suggest',
      body: itineraryData,
      handlePremiumException: true,
    );

    return ApiResponse.decodeMap(response.body);
  }
}