import 'package:flutter/material.dart';
import 'package:frontend/services/auth/auth_kakao.dart';
import '../../services/auth/auth_common.dart';
import '../main/main_screen.dart';
import 'signup_screen.dart';
import 'pwfind_screen.dart';

// 테마 및 컴포넌트 임포트
import '../../Directory/core/theme.dart';
import '../../widgets/components.dart';

class LoginScreen extends StatefulWidget {
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isLoggingIn = false;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // 카카오 브랜드 색상 정의
  final Color _kakaoColor = const Color(0xFFFEE500);

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 테마 배경색 적용
      backgroundColor: OakeyTheme.backgroundMain,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: _isLoggingIn
              ? const CircularProgressIndicator(color: OakeyTheme.primaryDeep)
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // 로고 텍스트
                    const Text(
                      'Oakey',
                      style: TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.w900,
                        color: OakeyTheme.primaryDeep,
                      ),
                    ),
                    OakeyTheme.boxV_S,

                    // 서브 타이틀
                    Text(
                      '가장 세련된 위스키 여행의 시작\n취향의 문을 여는 열쇠',
                      textAlign: TextAlign.center,
                      style: OakeyTheme.textBodyM.copyWith(
                        color: OakeyTheme.textHint,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 50),

                    // 이메일 입력 영역
                    _buildInputLabel('EMAIL'),
                    OakeyTheme.boxV_XS,
                    OakeyTextField(
                      controller: _emailController,
                      hintText: 'oakey@email.com',
                      keyboardType: TextInputType.emailAddress,
                    ),
                    OakeyTheme.boxV_L,

                    // 비밀번호 입력 영역
                    _buildInputLabel('PASSWORD'),
                    OakeyTheme.boxV_XS,
                    OakeyTextField(
                      controller: _passwordController,
                      hintText: '비밀번호를 입력하세요',
                      obscureText: true,
                    ),
                    const SizedBox(height: 40),

                    // 로그인 버튼
                    OakeyButton(
                      text: '로그인',
                      onPressed: _onEmailLoginPressed,
                      type: OakeyButtonType.primary,
                    ),
                    OakeyTheme.boxV_M,

                    // 카카오 로그인 버튼
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton.icon(
                        onPressed: () => _onLoginPressed(context),
                        icon: Image.asset(
                          'assets/icon/kakao_logo.png',
                          width: 24,
                          height: 24,
                        ),
                        label: const Text(
                          '카카오로 시작하기',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _kakaoColor,
                          foregroundColor: Colors.black,
                          elevation: 0,
                          // 테마 둥글기 적용
                          shape: RoundedRectangleBorder(
                            borderRadius: OakeyTheme.radiusM,
                          ),
                        ),
                      ),
                    ),
                    OakeyTheme.boxV_L,

                    // 하단 링크 영역
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildTextLink('비밀번호 찾기', () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PwfindScreen(),
                            ),
                          );
                        }),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: Text(
                            '|',
                            style: OakeyTheme.textBodyS.copyWith(
                              color: OakeyTheme.borderLine,
                            ),
                          ),
                        ),
                        _buildTextLink('회원가입', () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => SignupScreen(),
                            ),
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

  // 입력창 상단 라벨 위젯
  Widget _buildInputLabel(String label) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        label,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 12,
          color: OakeyTheme.textMain,
        ),
      ),
    );
  }

  // 텍스트 링크 위젯
  Widget _buildTextLink(String text, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Text(
        text,
        style: OakeyTheme.textBodyS.copyWith(color: OakeyTheme.textHint),
      ),
    );
  }

  // 카카오 로그인 로직
  Future<void> _onLoginPressed(BuildContext context) async {
    if (_isLoggingIn) return;
    setState(() => _isLoggingIn = true);

    try {
      final success = await AuthKakao.handleKakaoLogin();

      if (success) {
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => MainScreen()),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoggingIn = false);
    }
  }

  // 이메일 로그인 로직
  Future<void> _onEmailLoginPressed() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      OakeyTheme.showToast('알림', '이메일과 비밀번호를 모두 입력해주세요.', isError: true);
      return;
    }

    setState(() => _isLoggingIn = true);

    try {
      final success = await AuthService.handleEmailLogin(
        email: _emailController.text,
        password: _passwordController.text,
      );

      if (success && mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => MainScreen()),
        );
      }
    } catch (e) {
      if (mounted) {
        OakeyTheme.showToast('로그인 실패', e.toString(), isError: true);
      }
    } finally {
      if (mounted) setState(() => _isLoggingIn = false);
    }
  }
}
