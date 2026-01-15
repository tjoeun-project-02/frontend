import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'main_screen.dart';
import 'signup_screen.dart';
import 'pwfind_screen.dart';

class LoginScreen extends StatefulWidget {
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isLoggingIn = false;

  // 디자인 가이드 색상
  final Color _brandColor = const Color(0xFF4E342E); // 짙은 브라운
  final Color _kakaoColor = const Color(0xFFFEE500); // 카카오 노란색
  final Color _backgroundColor = const Color(0xFFF9F5F2); // 연한 베이지 배경

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: _isLoggingIn
              ? CircularProgressIndicator(color: _brandColor)
              : Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 로고 및 타이틀
              const Text(
                'Oakey',
                style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF4E342E),
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                '가장 세련된 위스키 여행의 시작\n취향의 문을 여는 열쇠',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 50),

              // EMAIL 입력창
              _buildInputField(label: 'EMAIL', hint: 'oakey@email.com'),
              const SizedBox(height: 20),

              // PASSWORD 입력창
              _buildInputField(label: 'PASSWORD', hint: '', isPassword: true),
              const SizedBox(height: 40),

              // 일반 로그인 버튼
              _buildActionButton(
                text: '로그인',
                color: _brandColor,
                textColor: Colors.white,
                onPressed: () {
                  // 일반 로그인 로직 (필요시 구현)
                },
              ),
              const SizedBox(height: 15),

              // 카카오 로그인 버튼
              _buildActionButton(
                icon: Image.asset(
                  'assets/icon/kakao_logo.png',
                  width: 24,
                  height: 24,
                ),
                text: '카카오로 시작하기',
                color: _kakaoColor,
                textColor: Colors.black,
                onPressed: () => _onLoginPressed(context),
              ),
              const SizedBox(height: 20),

              // 하단 텍스트 링크
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildTextLink('비밀번호 찾기', () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => PwfindScreen()),
                    );
                  }),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: Text('|', style: TextStyle(color: Colors.grey)),
                  ),
                  _buildTextLink('회원가입', (){
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => SignupScreen()),
                    );
                  }),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 공통 입력 필드 위젯
  Widget _buildInputField({required String label, required String hint, bool isPassword = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.black87),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: TextField(
            obscureText: isPassword,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(color: Colors.grey),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: const BorderSide(color: Color(0xFFD7CCC8)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: const BorderSide(color: Color(0xFFD7CCC8)),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            ),
          ),
        ),
      ],
    );
  }

  // 공통 버튼 위젯
  Widget _buildActionButton({
    required String text,
    required Color color,
    required Color textColor,
    required VoidCallback onPressed,
    Widget? icon, // 아이콘 매개변수 추가
  }) {
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: icon ?? const SizedBox.shrink(), // 아이콘이 없으면 빈 공간 처리
        label: Text(
          text,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: textColor,
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        ),
      ),
    );
  }

  Widget _buildTextLink(String text, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap, // 전달받은 함수 실행
      child: Text(
        text,
        style: const TextStyle(color: Colors.grey, fontSize: 13),
      ),
    );
  }

  // 카카오 로그인 로직 (분기 처리 포함)
  Future<void> _onLoginPressed(BuildContext context) async {
    if (_isLoggingIn) return;
    setState(() => _isLoggingIn = true);

    try {
      final success = await AuthService.handleKakaoLogin();

      if (success) {
        if (!mounted) return;
        // 서버에서 404가 왔을 때 ProfileScreen으로 가는 로직은
        // AuthService나 ApiService에서 처리되도록 구성하는 것이 좋습니다.
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => MainScreen()));
      } else {
        // 실제로는 여기서 404 에러 등을 체크하여 ProfileScreen으로 넘겨야 함
        // 예: Navigator.push(context, MaterialPageRoute(builder: (_) => ProfileScreen(token: ...)));
      }
    } finally {
      if (mounted) setState(() => _isLoggingIn = false);
    }
  }
}