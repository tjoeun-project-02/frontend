import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String baseUrl = 'http://10.0.2.2:8080';

  // 카카오 액세스 토큰을 서버로 보내 JWT 발급받기
  static Future<Map<String, dynamic>> loginWithKakao(String kakaoToken) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/kakao'),
      headers: {
        'Authorization': 'Bearer $kakaoToken',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('서버 로그인 실패: ${response.statusCode}');
    }
  }
  // lib/services/api_service.dart
  static Future<Map<String, dynamic>> fetchUserProfile(String token) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/users/me'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 5)); // 타임아웃 추가

      print('📡 서버 응답 코드: ${response.statusCode}');
      print('📡 서버 응답 내용: ${response.body}');

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else if (response.statusCode == 401) {
        throw Exception('인증 만료: 다시 로그인하세요.');
      } else {
        throw Exception('서버 에러: ${response.statusCode}');
      }
    } catch (e) {
      print('🌐 네트워크/서버 에러: $e');
      rethrow;
    }
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // 모든 저장 데이터 삭제

  }
}