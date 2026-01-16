// lib/screens/splash_screen.dart
import 'package:flutter/material.dart';
import '../services/auth/auth_common.dart';
import 'login_screen.dart';
import 'main_screen.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _initAndNavigate();
  }

  Future<void> _initAndNavigate() async {

    // 2. 최소 로딩 시간 보장 (스플래시 애니메이션 감상용)
    await Future.delayed(Duration(seconds: 2));

    // 3. 로그인 여부 판단
    bool isLogged = await AuthService.isLoggedIn();

    // 4. 화면 이동
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => isLogged ? MainScreen() : LoginScreen(),
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
            // 로고 이미지 (경로를 상수로 관리하면 더 좋습니다)
            Image.asset(
                'assets/img/whiskey_logo.png',
                width: 200,
                height: 200
            ),
            const SizedBox(height: 20),
            const CircularProgressIndicator(),
            const SizedBox(height: 20),
            const Text(
                'Oakey',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)
            ),
          ],
        ),
      ),
    );
  }
}