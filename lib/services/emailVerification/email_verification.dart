import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class EmailService {
  // 본인의 서버 주소로 변경하세요 (에뮬레이터는 보통 10.0.2.2)
  static final String baseUrl = dotenv.env['API_BASE_URL']!;

  Future<bool> sendCode(String email) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/api/email/send-code"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": email}),
      ).timeout(const Duration(seconds: 5)); // 5초 안에 응답 없으면 에러 발생

      return response.statusCode == 200;
    } catch (e) {
      print("Service Error: $e");
      return false; // 에러 발생 시 false 반환
    }
  }

  // 인증번호 검증 요청
  Future<bool> verifyCode(String email, String code) async {
    final response = await http.post(
      Uri.parse("$baseUrl/api/email/verify-code"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"email": email, "code": code}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['valid'] ?? false; // 서버가 반환하는 "valid" 값 확인
    }
    return false;
  }
}