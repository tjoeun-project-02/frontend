import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controller/email_verification_controller.dart';
import '../../controller/pwfind_controller.dart';
// 위에서 만든 컨트롤러와 서비스를 import 하세요.
// import 'package:your_app/controller/email_verification_controller.dart';

class PwfindScreen extends StatefulWidget {
  const PwfindScreen({super.key});

  @override
  State<PwfindScreen> createState() => _PwfindScreenState();
}

class _PwfindScreenState extends State<PwfindScreen> {
  // 컨트롤러 주입
  final emailAuth = Get.put(EmailVerificationController());

  final TextEditingController emailController = TextEditingController();
  final TextEditingController codeController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  final pwfindController = Get.put(PwfindController());

  final Color _brandColor = const Color(0xFF4E342E);
  final Color _subColor = const Color(0xFF8D776D);
  final Color _backgroundColor = const Color(0xFFF9F5F2);

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvokedWithResult: (didPop, result){
        if (didPop){
          emailAuth.resetStatus();
        }
      },
      child: Scaffold(
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
              const Text('비밀번호 재설정', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
              const SizedBox(height: 40),

              // 1. EMAIL 섹션
              const Text('EMAIL', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: Obx(() => _buildTextField(
                      hint: 'oakey@email.com',
                      controller: emailController,
                      // 인증 완료되면 읽기 전용(readOnly)으로 변경
                      readOnly: emailAuth.isVerified.value,
                    )),
                  ),
                  const SizedBox(width: 10),
                  SizedBox(
                    height: 55,
                    width: 100,
                    child: Obx(() {
                      // 인증 완료 상태일 때의 UI
                      if (emailAuth.isVerified.value) {
                        return Container(
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.1), // 연한 초록 배경
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.green),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.check_circle, color: Colors.green, size: 20),
                              SizedBox(width: 4),
                              Text('완료', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        );
                      }

                      // 인증 진행 중/전 상태일 때의 버튼
                      return ElevatedButton(
                        onPressed: emailAuth.isLoading.value
                            ? null
                            : () => emailAuth.requestSendCode(emailController.text),
                        style: ElevatedButton.styleFrom(
                            backgroundColor: _subColor,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            padding: EdgeInsets.zero
                        ),
                        child: emailAuth.isLoading.value
                            ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)
                        )
                            : Text(emailAuth.isEmailSent.value ? '재발송' : '인증하기',
                            style: const TextStyle(color: Colors.white)),
                      );
                    }),
                  ),
                ],
              ),

              // 2. 인증번호 입력 섹션 (메일 발송 시에만 노출)
              Obx(() => emailAuth.isEmailSent.value && !emailAuth.isVerified.value
                  ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  const Text('VERIFICATION CODE', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: _buildTextField(hint: '6자리 코드 입력', controller: codeController),
                      ),
                      const SizedBox(width: 10),
                      Column(
                        children: [
                          Text(
                            "${emailAuth.timerSeconds.value ~/ 60}:${(emailAuth.timerSeconds.value % 60).toString().padLeft(2, '0')}",
                            style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                          ),
                          TextButton(
                            onPressed: () => {
                              emailAuth.requestVerifyCode(emailController.text, codeController.text),

                            },
                            child: const Text("확인"),
                          )
                        ],
                      )
                    ],
                  ),
                ],
              )
                  : const SizedBox.shrink()
              ),

              const SizedBox(height: 20),

              // 3. PASSWORD 섹션
              _buildLabelTextField(label: 'NEW PASSWORD', hint: '비밀번호를 입력하세요', isPassword: true, controller: passwordController),
              const SizedBox(height: 20),

              // 4. CONFIRM PASSWORD 섹션
              _buildLabelTextField(label: 'CONFIRM PASSWORD', hint: '비밀번호와 다시 입력하세요', isPassword: true, controller: confirmPasswordController),

              const SizedBox(height: 50),

              // 최종 재설정 버튼
              SizedBox(
                width: double.infinity,
                height: 60,
                child: Obx(() => ElevatedButton(
                  // 로딩 중이거나 이메일 인증이 안 되었으면 버튼 비활성화
                  onPressed: (emailAuth.isVerified.value && !pwfindController.isSubmitting.value)
                      ? () => pwfindController.submitNewPassword(
                    emailController.text,
                    passwordController.text,
                    confirmPasswordController.text,
                    codeController.text, // 서버 검증용 코드 전달
                  )
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: emailAuth.isVerified.value ? _brandColor : Colors.grey,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  ),
                  child: pwfindController.isSubmitting.value
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                    '비밀번호 재설정',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                )),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      )
    );
  }

  // 최종 제출 로직
  void _handleResetPassword() {
    if (passwordController.text != confirmPasswordController.text) {
      Get.snackbar("오류", "비밀번호가 일치하지 않습니다.");
      return;
    }
    // 여기서 최종 Reset API 호출 로직 추가
    print("비밀번호 재설정 시도: ${emailController.text} / ${passwordController.text}");
  }

  Widget _buildLabelTextField({required String label, required String hint, bool isPassword = false, required TextEditingController controller}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
        const SizedBox(height: 8),
        _buildTextField(hint: hint, isPassword: isPassword, controller: controller),
      ],
    );
  }

  Widget _buildTextField({
    required String hint,
    bool isPassword = false,
    required TextEditingController controller,
    bool readOnly = false, // 기본값은 false
  }) {
    return Container(
      decoration: BoxDecoration(
        color: readOnly ? Colors.grey[200] : Colors.white, // 읽기 전용일 때 배경색 변경 (선택사항)
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          if (!readOnly) // 읽기 전용이 아닐 때만 그림자 효과
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))
        ],
      ),
      child: TextField(
        controller: controller,
        obscureText: isPassword,
        readOnly: readOnly, // 필드 수정 가능 여부 결정
        style: TextStyle(color: readOnly ? Colors.grey[600] : Colors.black),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: readOnly ? Colors.transparent : const Color(0xFFD7CCC8))
          ),
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: readOnly ? Colors.transparent : const Color(0xFFD7CCC8))
          ),
        ),
      ),
    );
  }
}