import 'package:flutter/material.dart';

import '../../services/auth/auth_common.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _emailController = TextEditingController();
  final _nicknameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool isLoading = false;
  final Color _brandColor = const Color(0xFF4E342E); // 짙은 브라운
  final Color _subColor = const Color(0xFF8D776D); // 인증 버튼 색상
  final Color _backgroundColor = const Color(0xFFF9F5F2);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const BackButton(color: Colors.black),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '회원가입',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              '당신의 취향을 기록하고\n딱 맞는 위스키를 추천받으세요',
              style: TextStyle(fontSize: 15, color: Colors.grey, height: 1.5),
            ),
            const SizedBox(height: 40),

            // EMAIL 섹션 (인증 버튼 포함)
            const Text(
              'EMAIL',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    hint: 'oakey@email.com',
                    controller: _emailController,
                  ),
                ),
                const SizedBox(width: 10),
                SizedBox(
                  width: 100, // 버튼의 가로 길이를 명확히 지정
                  height: 55, // 텍스트 필드 높이와 맞춤
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _subColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      '인증 하기',
                      style: TextStyle(color: Colors.white, fontSize: 13),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // NICKNAME 섹션
            _buildLabelTextField(
              label: 'NICKNAME',
              hint: '닉네임을 입력하세요',
              controller: _nicknameController,
            ),
            const SizedBox(height: 20),

            // PASSWORD 섹션
            _buildLabelTextField(
              label: 'PASSWORD',
              hint: '비밀번호를 입력하세요',
              isPassword: true,
              controller: _passwordController,
            ),
            const SizedBox(height: 20),

            // CONFIRM PASSWORD 섹션
            _buildLabelTextField(
              label: 'CONFIRM PASSWORD',
              hint: '위 비밀번호와 동일하게 입력하세요',
              isPassword: true,
              controller: _confirmPasswordController,
            ),

            const SizedBox(height: 50),

            // 가입하기 버튼
            SizedBox(
              width: double.infinity,
              height: 60,
              child: ElevatedButton(
                onPressed: isLoading ? null : _onSignupPressed, // 회원가입 완료 로직
                style: ElevatedButton.styleFrom(
                  backgroundColor: _brandColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                child: const Text(
                  '회원가입',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  // 라벨이 포함된 텍스트 필드 빌더
  Widget _buildLabelTextField({
    required String label,
    required String hint,
    bool isPassword = false,
    required TextEditingController? controller,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
        ),
        const SizedBox(height: 8),
        _buildTextField(
          hint: hint,
          isPassword: isPassword,
          controller: controller,
        ),
      ],
    );
  }

  // 공통 텍스트 필드 스타일
  Widget _buildTextField({
    required String hint,
    bool isPassword = false,
    required TextEditingController? controller,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        obscureText: isPassword,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 18,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFD7CCC8)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFD7CCC8)),
          ),
        ),
      ),
    );
  }

  Future<void> _onSignupPressed() async {
    // 1. 기본 유효성 검사
    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('비밀번호가 일치하지 않습니다.')));
      return;
    }

    setState(() => isLoading = true);

    try {
      final success = await AuthService.handleEmailSignup(
        email: _emailController.text,
        password: _passwordController.text,
        nickname: _nicknameController.text,
      );

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('회원가입이 완료되었습니다. 로그인해 주세요.')),
        );
        Navigator.pop(context); // 로그인 화면으로 이동
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceAll('Exception: ', ''))),
        );
      }
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }
}
