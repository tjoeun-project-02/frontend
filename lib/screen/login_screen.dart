// lib/screens/login_screen.dart
import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'main_screen.dart';

class LoginScreen extends StatefulWidget {
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isLoggingIn = false; // 로그인 진행 상태 변수
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('로그인')),
      body: Center(
        child: _isLoggingIn
            ? const CircularProgressIndicator()
            : Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              '오키(Oakey)에 오신 걸 환영합니다!',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () => _onLoginPressed(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.yellow, // 카카오 스타일링 예시
                foregroundColor: Colors.black,
              ),
              child: const Text('카카오로 시작하기'),
            ),
          ],
        ),
      ),
    );
  }

  // 로그인 버튼 로직
  Future<void> _onLoginPressed(BuildContext context) async {
    if (_isLoggingIn) return; // 이미 진행 중이면 무시

    setState(() => _isLoggingIn = true); // 로딩 시작

    try {
      final success = await AuthService.handleKakaoLogin();

      if (success) {
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => MainScreen()),
        );
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('로그인 실패')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoggingIn = false); // 완료 후 해제
      }
    }
  }
}