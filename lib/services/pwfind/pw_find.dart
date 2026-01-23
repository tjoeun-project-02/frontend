import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ResetPasswordService {
  final String baseUrl = dotenv.env['API_BASE_URL']!;

  Future<bool> resetPassword({
    required String email,
    required String newPassword,
    required String code, // 보안을 위해 서버에서 다시 한번 코드를 확인할 수도 있습니다.
  }) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/api/users/reset-password"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "email": email,
          "newPassword": newPassword,
          "code": code,
        }),
      ).timeout(const Duration(seconds: 5));

      return response.statusCode == 200;
    } catch (e) {
      print("Reset Service Error: $e");
      return false;
    }
  }
}