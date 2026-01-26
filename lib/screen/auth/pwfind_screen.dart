import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controller/email_verification_controller.dart';
import '../../controller/pwfind_controller.dart';

// 테마 및 컴포넌트 임포트
import '../../Directory/core/theme.dart';
import '../../widgets/components.dart';

class PwfindScreen extends StatefulWidget {
  const PwfindScreen({super.key});

  @override
  State<PwfindScreen> createState() => _PwfindScreenState();
}

class _PwfindScreenState extends State<PwfindScreen> {
  // 컨트롤러 주입
  final emailAuth = Get.put(EmailVerificationController());
  final pwfindController = Get.put(PwfindController());

  final TextEditingController emailController = TextEditingController();
  final TextEditingController codeController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  @override
  Widget build(BuildContext context) {
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
              Text('비밀번호 재설정', style: OakeyTheme.textTitleXL),
              OakeyTheme.boxV_XL,

              // 이메일 입력 섹션
              _buildInputLabel('EMAIL'),
              OakeyTheme.boxV_XS,
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Obx(
                      () => OakeyTextField(
                        controller: emailController,
                        hintText: 'oakey@email.com',
                        // 인증 완료 시 수정 불가 처리
                        readOnly: emailAuth.isVerified.value,
                        keyboardType: TextInputType.emailAddress,
                      ),
                    ),
                  ),
                  OakeyTheme.boxH_S,
                  SizedBox(
                    height: 56, // 입력창 높이와 동일하게 맞춤
                    width: 120,
                    child: Obx(() {
                      // 인증 완료 상태 UI
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
                        // 로딩 상태 연동
                        isLoading: emailAuth.isLoading.value,
                        type: OakeyButtonType.secondary, // 보조 버튼 스타일 사용
                        onPressed: () =>
                            emailAuth.requestSendCode(emailController.text),
                      );
                    }),
                  ),
                ],
              ),

              // 인증코드 입력 섹션
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
                                  controller: codeController,
                                  hintText: '6자리 코드 입력',
                                  keyboardType: TextInputType.number,
                                ),
                              ),
                              OakeyTheme.boxH_S,
                              Column(
                                children: [
                                  Text(
                                    "${emailAuth.timerSeconds.value ~/ 60}:${(emailAuth.timerSeconds.value % 60).toString().padLeft(2, '0')}",
                                    style: const TextStyle(
                                      color: OakeyTheme.statusError,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      emailAuth.requestVerifyCode(
                                        emailController.text,
                                        codeController.text,
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

              // 새 비밀번호 입력 섹션
              _buildInputLabel('NEW PASSWORD'),
              OakeyTheme.boxV_XS,
              OakeyTextField(
                controller: passwordController,
                hintText: '비밀번호를 입력하세요',
                obscureText: true,
              ),

              OakeyTheme.boxV_L,

              // 비밀번호 확인 입력 섹션
              _buildInputLabel('CONFIRM PASSWORD'),
              OakeyTheme.boxV_XS,
              OakeyTextField(
                controller: confirmPasswordController,
                hintText: '비밀번호를 다시 입력하세요',
                obscureText: true,
              ),

              const SizedBox(height: 50),

              // 최종 재설정 버튼
              Obx(() {
                final bool isEnabled =
                    emailAuth.isVerified.value &&
                    !pwfindController.isSubmitting.value;
                return OakeyButton(
                  text: '비밀번호 재설정',
                  isLoading: pwfindController.isSubmitting.value,
                  // 비활성화 처리는 onPressed를 null로 줌으로써 해결
                  onPressed: isEnabled
                      ? () => pwfindController.submitNewPassword(
                          emailController.text,
                          passwordController.text,
                          confirmPasswordController.text,
                          codeController.text,
                        )
                      : null,
                );
              }),
              const SizedBox(height: 30),
            ],
          ),
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
}
