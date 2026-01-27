import 'package:flutter/material.dart';
import 'package:get/get.dart';

// 컨트롤러 및 서비스 임포트
import '../../controller/email_verification_controller.dart';
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
  // 이메일 인증 컨트롤러
  final emailAuth = Get.put(EmailVerificationController());

  final _emailController = TextEditingController();
  final _codeController = TextEditingController(); // 인증번호 입력용
  final _nicknameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _codeController.dispose();
    _nicknameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 화면 나갈 때 인증 상태 초기화
    return PopScope(
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          emailAuth.resetStatus();
        }
      },
      child: Scaffold(
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
              // 헤더 텍스트
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

              // 1. 이메일 입력 및 인증 요청 섹션
              _buildInputLabel('EMAIL'),
              OakeyTheme.boxV_XS,
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Obx(
                      () => OakeyTextField(
                        hintText: 'oakey@email.com',
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        // 인증 완료 시 수정 불가 처리
                        readOnly: emailAuth.isVerified.value,
                      ),
                    ),
                  ),
                  OakeyTheme.boxH_S,
                  SizedBox(
                    width: 120,
                    height: 56,
                    child: Obx(() {
                      // 인증 완료 상태 UI (체크 아이콘)
                      if (emailAuth.isVerified.value) {
                        return Container(
                          decoration: BoxDecoration(
                            color: OakeyTheme.statusSuccess.withOpacity(0.1),
                            borderRadius: OakeyTheme.radiusM,
                            border: Border.all(color: OakeyTheme.statusSuccess),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.check_circle,
                                color: OakeyTheme.statusSuccess,
                                size: 20,
                              ),
                              SizedBox(width: 4),
                              Text(
                                '완료',
                                style: TextStyle(
                                  color: OakeyTheme.statusSuccess,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      // 인증 요청 버튼
                      return OakeyButton(
                        text: emailAuth.isEmailSent.value ? '재발송' : '인증하기',
                        size: OakeyButtonSize.large,
                        isLoading: emailAuth.isLoading.value,
                        type: OakeyButtonType.secondary,
                        onPressed: () =>
                            emailAuth.requestSendCode(_emailController.text),
                      );
                    }),
                  ),
                ],
              ),

              // 2. 인증코드 입력 섹션 (발송 후 & 인증 미완료 시 노출)
              Obx(
                () => emailAuth.isEmailSent.value && !emailAuth.isVerified.value
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          OakeyTheme.boxV_L,
                          _buildInputLabel('VERIFICATION CODE'),
                          OakeyTheme.boxV_XS,
                          Row(
                            children: [
                              Expanded(
                                child: OakeyTextField(
                                  controller: _codeController,
                                  hintText: '6자리 코드 입력',
                                  keyboardType: TextInputType.number,
                                ),
                              ),
                              OakeyTheme.boxH_S,
                              Column(
                                children: [
                                  // 타이머 표시
                                  Text(
                                    "${emailAuth.timerSeconds.value ~/ 60}:${(emailAuth.timerSeconds.value % 60).toString().padLeft(2, '0')}",
                                    style: const TextStyle(
                                      color: OakeyTheme.statusError,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  // 확인 버튼
                                  TextButton(
                                    onPressed: () {
                                      emailAuth.requestVerifyCode(
                                        _emailController.text,
                                        _codeController.text,
                                      );
                                    },
                                    child: const Text(
                                      "확인",
                                      style: TextStyle(
                                        color: OakeyTheme.primaryDeep,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      )
                    : const SizedBox.shrink(),
              ),

              OakeyTheme.boxV_L,

              // 닉네임 입력
              _buildInputLabel('NICKNAME'),
              OakeyTheme.boxV_XS,
              OakeyTextField(
                hintText: '닉네임을 입력하세요',
                controller: _nicknameController,
              ),
              OakeyTheme.boxV_L,

              // 비밀번호 입력
              _buildInputLabel('PASSWORD'),
              OakeyTheme.boxV_XS,
              OakeyTextField(
                hintText: '비밀번호를 입력하세요',
                obscureText: true,
                controller: _passwordController,
              ),
              OakeyTheme.boxV_L,

              // 비밀번호 확인
              _buildInputLabel('CONFIRM PASSWORD'),
              OakeyTheme.boxV_XS,
              OakeyTextField(
                hintText: '위 비밀번호와 동일하게 입력하세요',
                obscureText: true,
                controller: _confirmPasswordController,
              ),

              const SizedBox(height: 50),

              // 가입하기 버튼
              Obx(() {
                // 이메일 인증이 완료되어야만 버튼 활성화
                final bool isEnabled = emailAuth.isVerified.value;

                return OakeyButton(
                  text: '회원가입',
                  isLoading: isLoading,
                  onPressed: (isLoading || !isEnabled)
                      ? null
                      : _onSignupPressed,
                );
              }),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

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
    // 1. 비밀번호 일치 확인
    if (_passwordController.text != _confirmPasswordController.text) {
      OakeyTheme.showToast('오류', '비밀번호가 일치하지 않습니다.', isError: true);
      return;
    }

    // 2. 이메일 인증 여부 재확인 (버튼 비활성화로 막았지만 더블 체크)
    if (!emailAuth.isVerified.value) {
      OakeyTheme.showToast('오류', '이메일 인증을 완료해주세요.', isError: true);
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
        // 상태 초기화 후 뒤로가기
        emailAuth.resetStatus();
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
