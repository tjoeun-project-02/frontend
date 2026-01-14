import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import 'main_screen.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {

  Future<void> _kakaoLogin() async {
    try {
      print('카카오 로그인 시작');

      OAuthToken token;
      if (await isKakaoTalkInstalled()) {
        token = await UserApi.instance.loginWithKakaoTalk();
      } else {
        token = await UserApi.instance.loginWithKakaoAccount();
      }

      print('카카오 토큰 받음: ${token.accessToken}');

      final response = await http.post(
        Uri.parse('http://10.0.2.2:8080/auth/kakao'),
        headers: {
          'Authorization': 'Bearer ${token.accessToken}',
        },
      );

      print('서버 응답 코드: ${response.statusCode}');
      print('서버 응답 바디: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // 3. JWT 저장
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('accessToken', data['accessToken']);
        await prefs.setString('refreshToken', data['refreshToken']);
        await prefs.setInt('userId', data['userId']);
        // 4. 메인 화면 이동
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => MainScreen()),
        );
      } else {
        throw Exception('서버 로그인 실패');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('카카오 로그인 실패')),
      );
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('로그인')),
      body: Center(
        child: ElevatedButton(
          onPressed: _kakaoLogin,
          child: Text('카카오 로그인'),
        ),
      ),
    );
  }
}
