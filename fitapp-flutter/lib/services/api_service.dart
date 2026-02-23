import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'http://localhost:3000/api';
  static const Duration timeout = Duration(seconds: 15);

  static Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

  static Future<Map<String, dynamic>> _handleResponse(http.Response res) async {
    final body = jsonDecode(res.body) as Map<String, dynamic>;
    if (res.statusCode >= 200 && res.statusCode < 300) return body;
    throw ApiException(
      message: body['message'] ?? 'Unknown error',
      statusCode: res.statusCode,
    );
  }

  // ── Profile ──────────────────────────────────────────────
  static Future<Map<String, dynamic>> upsertProfile({
    required String userId,
    required double weight,
    required double height,
    required int age,
    required String gender,
    required String activityLevel,
    String injury = 'none',
  }) async {
    final res = await http
        .post(
          Uri.parse('$baseUrl/profile'),
          headers: _headers,
          body: jsonEncode({
            'userId': userId,
            'weight': weight,
            'height': height,
            'age': age,
            'gender': gender,
            'activityLevel': activityLevel,
            'injury': injury,
          }),
        )
        .timeout(timeout);
    return _handleResponse(res);
  }

  static Future<Map<String, dynamic>> getProfile(String userId) async {
    final res = await http
        .get(Uri.parse('$baseUrl/profile/$userId'), headers: _headers)
        .timeout(timeout);
    return _handleResponse(res);
  }

  // ── Goals ─────────────────────────────────────────────────
  static Future<Map<String, dynamic>> setGoal({
    required String userId,
    required String goalType,
    int manualCaloricAdjustment = 0,
  }) async {
    final res = await http
        .post(
          Uri.parse('$baseUrl/goals'),
          headers: _headers,
          body: jsonEncode({
            'userId': userId,
            'goalType': goalType,
            'manualCaloricAdjustment': manualCaloricAdjustment,
          }),
        )
        .timeout(timeout);
    return _handleResponse(res);
  }

  static Future<Map<String, dynamic>> adjustGoal({
    required String goalId,
    required int delta,
  }) async {
    final res = await http
        .patch(
          Uri.parse('$baseUrl/goals/$goalId/adjust'),
          headers: _headers,
          body: jsonEncode({'delta': delta}),
        )
        .timeout(timeout);
    return _handleResponse(res);
  }

  static Future<Map<String, dynamic>> getActiveGoal(String userId) async {
    final res = await http
        .get(Uri.parse('$baseUrl/goals/active/$userId'), headers: _headers)
        .timeout(timeout);
    return _handleResponse(res);
  }

  // ── Workouts ──────────────────────────────────────────────
  static Future<Map<String, dynamic>> getWorkouts({
    String injury = 'none',
    String? intensity,
    String? equipment,
    String? muscle,
  }) async {
    final params = <String, String>{'injury': injury};
    if (intensity  != null) params['intensity']  = intensity;
    if (equipment  != null) params['equipment']  = equipment;
    if (muscle     != null) params['muscle']     = muscle;

    final uri = Uri.parse('$baseUrl/workouts').replace(queryParameters: params);
    final res = await http.get(uri, headers: _headers).timeout(timeout);
    return _handleResponse(res);
  }

  static Future<void> seedWorkouts() async {
    await http.post(Uri.parse('$baseUrl/workouts/seed'), headers: _headers).timeout(timeout);
  }

  // ── Daily Plan ────────────────────────────────────────────
  static Future<Map<String, dynamic>> generatePlan({
    required String userId,
    String? date,
  }) async {
    final res = await http
        .post(
          Uri.parse('$baseUrl/plan/generate'),
          headers: _headers,
          body: jsonEncode({
            'userId': userId,
            if (date != null) 'date': date,
          }),
        )
        .timeout(timeout);
    return _handleResponse(res);
  }

  static Future<Map<String, dynamic>> getPlan(String userId, String date) async {
    final res = await http
        .get(Uri.parse('$baseUrl/plan/$userId/$date'), headers: _headers)
        .timeout(timeout);
    return _handleResponse(res);
  }
}

class ApiException implements Exception {
  final String message;
  final int statusCode;
  const ApiException({required this.message, required this.statusCode});

  @override
  String toString() => 'ApiException($statusCode): $message';
}
