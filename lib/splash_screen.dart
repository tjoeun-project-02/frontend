import 'package:flutter/material.dart';
import 'login_screen.dart';
import 'main_screen.dart';  // 메인 페이지 파일 생성 필요
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}
Future<void> printKeyHash() async {
  final keyHash = await KakaoSdk.origin;
  print('🔥 Kakao KeyHash: $keyHash');
}
class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
    printKeyHash();
  }

  _checkLoginStatus() async {
    await Future.delayed(Duration(seconds: 2));

    final prefs = await SharedPreferences.getInstance();
    final accessToken = prefs.getString('accessToken');

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) =>
        accessToken != null ? MainScreen() : LoginScreen(),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/img/whiskey_logo.png', width: 200, height: 200),  // 앱 로고 경로 수정
            SizedBox(height: 20),
            CircularProgressIndicator(),
            SizedBox(height: 20),
            Text('Oakey', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
