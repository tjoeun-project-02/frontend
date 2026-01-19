import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:frontend/services/auth/auth_common.dart';
import 'package:http/http.dart' as http;
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';

class AuthKakao{

  static final String baseUrl = dotenv.env['API_BASE_URL']!;

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

  // 카카오 로그인 및 서버 연동 로직
  static Future<dynamic> handleKakaoLogin() async {
    try {
      // 카카오 토큰 획득
      OAuthToken token = await isKakaoTalkInstalled()
          ? await UserApi.instance.loginWithKakaoTalk()
          : await UserApi.instance.loginWithKakaoAccount();

      // [중요] 백엔드 서버에 로그인 요청 (여기서 403이나 404가 발생할 수 있음)
      final response = await loginWithKakao(token.accessToken);

      if (response != null && response['accessToken'] != null) {
        // [CASE 1] 기존 회원: 즉시 로그인 처리 및 정보 저장
        await AuthService.saveAuthData(response, 'kakao');
        return true;
      }
      return false;
    } catch (e) {
      // [CASE 2] 신규 회원: 404 에러가 던져졌을 때 처리 (ApiService에서 404 처리 방식에 따라 다름)
      if (e.toString().contains('404')) {
        print('신규 회원 발견: 회원가입 페이지로 이동 필요');
        return 'NEW_USER';
      }

      // [CASE 3] 403 Forbidden 등 권한 에러
      print('Kakao Login Error: $e');
      rethrow; // 에러를 위로 던져 UI에서 알림을 띄우게 함
    }
  }

}