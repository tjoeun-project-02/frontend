import 'package:flutter/material.dart';
import '../../services/auth/auth_common.dart';

// 테마 및 컴포넌트 임포트
import '../../Directory/core/theme.dart';
import '../../widgets/components.dart';

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

  // 메모리 누수 방지를 위한 dispose
  @override
  void dispose() {
    _emailController.dispose();
    _nicknameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: OakeyTheme.backgroundMain,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const BackButton(color: OakeyTheme.textMain),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 헤더 텍스트 영역
            Text('회원가입', style: OakeyTheme.textTitleXL),
            OakeyTheme.boxV_S,
            Text(
              '당신의 취향을 기록하고\n딱 맞는 위스키를 추천받으세요',
              style: OakeyTheme.textBodyM.copyWith(
                color: OakeyTheme.textHint,
                height: 1.5,
              ),
            ),
            OakeyTheme.boxV_XL,

            // 이메일 입력 섹션
            _buildInputLabel('EMAIL'),
            OakeyTheme.boxV_XS,
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: OakeyTextField(
                    hintText: 'oakey@email.com',
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                  ),
                ),
                OakeyTheme.boxH_S,
                SizedBox(
                  width: 120,
                  height: 56, // 입력창 높이와 동일하게 맞춤
                  child: OakeyButton(
                    text: '인증 하기',
                    size: OakeyButtonSize.large,
                    type: OakeyButtonType.secondary,
                    onPressed: () {
                      // 이메일 인증 로직 추가 예정
                    },
                  ),
                ),
              ],
            ),
            OakeyTheme.boxV_L,

            // 닉네임 입력 섹션
            _buildInputLabel('NICKNAME'),
            OakeyTheme.boxV_XS,
            OakeyTextField(
              hintText: '닉네임을 입력하세요',
              controller: _nicknameController,
            ),
            OakeyTheme.boxV_L,

            // 비밀번호 입력 섹션
            _buildInputLabel('PASSWORD'),
            OakeyTheme.boxV_XS,
            OakeyTextField(
              hintText: '비밀번호를 입력하세요',
              obscureText: true,
              controller: _passwordController,
            ),
            OakeyTheme.boxV_L,

            // 비밀번호 확인 입력 섹션
            _buildInputLabel('CONFIRM PASSWORD'),
            OakeyTheme.boxV_XS,
            OakeyTextField(
              hintText: '위 비밀번호와 동일하게 입력하세요',
              obscureText: true,
              controller: _confirmPasswordController,
            ),

            const SizedBox(height: 50),

            // 가입하기 버튼
            OakeyButton(
              text: '회원가입',
              isLoading: isLoading,
              onPressed: isLoading ? null : _onSignupPressed,
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  // 입력창 라벨 빌더
  Widget _buildInputLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 12,
        color: OakeyTheme.textMain,
      ),
    );
  }

  // 회원가입 버튼 클릭 로직
  Future<void> _onSignupPressed() async {
    // 비밀번호 일치 확인
    if (_passwordController.text != _confirmPasswordController.text) {
      OakeyTheme.showToast('오류', '비밀번호가 일치하지 않습니다.', isError: true);
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
        OakeyTheme.showToast('가입 완료', '회원가입이 완료되었습니다. 로그인해 주세요.');
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        OakeyTheme.showToast(
          '가입 실패',
          e.toString().replaceAll('Exception: ', ''),
          isError: true,
        );
      }
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }
}
