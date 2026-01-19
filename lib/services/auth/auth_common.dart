import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../controller/user_controller.dart';
import 'package:get/get.dart';

class AuthService {
  static final String baseUrl = dotenv.env['API_BASE_URL']!;

  // 이메일 회원가입
  static Future<bool> handleEmailSignup({
    required String email,
    required String password,
    required String nickname,
  }) async {
    try {
      final signupData = {
        'email': email,
        'password': password,
        'nickname': nickname,
      };

      final response = await http.post(
        Uri.parse('$baseUrl/api/users/signup'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(signupData),
      );

      if (response.statusCode == 200) {
        final userId = jsonDecode(response.body);
        print('✅ 회원가입 성공! User ID: $userId');
        return true;
      } else {
        // 서버에서 내려주는 구체적인 에러 메시지 처리 (예: 중복 이메일 등)
        final errorBody = jsonDecode(response.body);
        throw Exception(errorBody['message'] ?? '회원가입에 실패했습니다.');
      }
    } catch (e) {
      print('❌ Signup Error: $e');
      rethrow; // UI(SignupScreen)에서 에러 팝업을 띄울 수 있도록 던짐
    }
  }

  // 이메일 로그인
  static Future<bool> handleEmailLogin({
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/users/emaillogin'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // 성공 시 토큰 저장 (내부 메서드 활용)
        if (data['accessToken'] != null) {
          await saveAuthData(data, 'email');
          return true;
        }
      } else {
        final errorBody = jsonDecode(response.body);
        throw Exception(
          errorBody['message'] ?? '로그인 실패: ${response.statusCode}',
        );
      }
      return false;
    } catch (e) {
      print('Email Login Error: $e');
      rethrow;
    }
  }

  static Future<dynamic> requestWithRefresh(
    String method,
    String path, {
    Map<String, dynamic>? body,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    String? accessToken = prefs.getString('accessToken');

    // 1. 요청 설정
    final url = Uri.parse('$baseUrl$path');
    final headers = {
      'Content-Type': 'application/json',
      if (accessToken != null) 'Authorization': 'Bearer $accessToken',
    };

    // 2. 1차 요청 수행
    http.Response response;
    if (method == 'POST') {
      response = await http.post(url, headers: headers, body: jsonEncode(body));
    } else if (method == 'PATCH') {
      response = await http.patch(
        url,
        headers: headers,
        body: jsonEncode(body),
      );
    } else {
      response = await http.get(url, headers: headers);
    }

    // 3. 만약 401(권한 없음) 에러가 나면 리프레시 시도
    if (response.statusCode == 401) {
      print('🔄 액세스 토큰 만료, 리프레시 시도 중...');
      String? refreshToken = prefs.getString('refreshToken');

      if (refreshToken == null) {
        await logout();
        throw Exception('인증 정보가 없습니다. 다시 로그인하세요.');
      }

      final refreshRes = await http.post(
        Uri.parse('$baseUrl/auth/refresh'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'refreshToken': refreshToken}),
      );

      if (refreshRes.statusCode == 200) {
        final newData = jsonDecode(refreshRes.body);

        // 새 토큰 저장
        await prefs.setString('accessToken', newData['accessToken']);
        await prefs.setString('refreshToken', newData['refreshToken']);

        print('✅ 토큰 갱신 성공, 재요청 수행');

        // 4. 새 토큰으로 기존 요청 재시도
        headers['Authorization'] = 'Bearer ${newData['accessToken']}';
        if (method == 'POST') {
          response = await http.post(
            url,
            headers: headers,
            body: jsonEncode(body),
          );
        } else if (method == 'PATCH') {
          response = await http.patch(
            url,
            headers: headers,
            body: jsonEncode(body),
          );
        } else {
          response = await http.get(url, headers: headers);
        }
      } else {
        // 리프레시 토큰까지 만료된 경우
        print('🚫 리프레시 토큰 만료, 로그아웃 처리');
        await logout();
        throw Exception('세션이 만료되었습니다. 다시 로그인해주세요.');
      }
    }

    return jsonDecode(response.body);
  }

  static Future<String?> getStoredToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('accessToken');
  }

  // 로그아웃
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  // 데이터 저장 로직 분리 (Clean Architecture - Data Source)
  static Future<void> saveAuthData(Map<String, dynamic> data, String loginType) async {
    final prefs = await SharedPreferences.getInstance();

    // 1. 기본 정보 먼저 확실히 저장
    await prefs.setString('accessToken', data['accessToken']);
    await prefs.setString('refreshToken', data['refreshToken']);
    await prefs.setInt('userId', data['userId']);
    await prefs.setString('loginType', loginType);
    if (loginType == 'email'){
      await prefs.setString('email', data['email'] ?? '');
    }else{
      await prefs.remove('email');
    }

    try {
      // 2. 닉네임과 이메일 정보 처리
      if (data['nickname'] != null && data['email'] != null) {
        // 로그인 응답에 정보가 다 있다면 바로 저장
        await prefs.setString('nickname', data['nickname']);
        if (loginType == 'email') await prefs.setString('email', data['email']);
      } else {
        // 3. 정보가 부족하다면 서버에 상세 프로필 요청 (fetchUserProfile)
        final profile = await fetchUserProfile();

        if (profile != null) {
          // 닉네임 저장
          if (profile['nickname'] != null) {
            await prefs.setString('nickname', profile['nickname']);
          }

          // 🔥 [수정 포인트] 이메일 저장 로직 추가
          if (loginType == 'email' && profile['email'] != null) {
            await prefs.setString('email', profile['email']);
            print("✅ SharedPreferences에 이메일 저장 완료: ${profile['email']}");
          }
        }
      }
    } catch (e) {
      print("유저 정보 세부 로드 실패: $e");
      if (prefs.getString('nickname') == null) await prefs.setString('nickname', '고객');
    }

    // 카카오 유저일 경우 이메일 삭제 (의도하신 대로)
    if (loginType != 'email') {
      await prefs.remove('email');
    }

    if (Get.isRegistered<UserController>()) {
      await UserController.to.loadUserData();
    }
  }

  static Future<Map<String, dynamic>> fetchUserProfile() async {
    try {
      print('유저정보 로드');
      return await AuthService.requestWithRefresh('GET', '/api/users/me');
    } catch (e) {
      rethrow;
    }
  }
}
