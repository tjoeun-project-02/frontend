import 'package:get/get.dart';

import '../screen/auth/login_screen.dart';
import '../services/pwfind/pw_find.dart';
import 'email_verification_controller.dart';

class PwfindController extends GetxController {
  final _resetService = ResetPasswordService();

  // 이미 생성된 이메일 인증 컨트롤러를 가져옵니다.
  final emailAuth = Get.find<EmailVerificationController>();

  var isSubmitting = false.obs;

  // 최종 비밀번호 재설정 실행
  Future<void> submitNewPassword(String email, String newPassword, String confirmPassword, String code) async {
    // 1. 유효성 검사 (입력값 확인)
    if (newPassword.isEmpty || confirmPassword.isEmpty) {
      Get.snackbar("알림", "비밀번호를 입력해주세요.");
      return;
    }
    if (newPassword != confirmPassword) {
      Get.snackbar("알림", "비밀번호가 일치하지 않습니다.");
      return;
    }
    if (newPassword.length < 8) {
      Get.snackbar("알림", "비밀번호는 8자 이상이어야 합니다.");
      return;
    }

    try {
      isSubmitting.value = true;

      // 2. 서비스 호출 (서버의 /api/users/reset-password 호출)
      bool success = await _resetService.resetPassword(
        email: email,
        newPassword: newPassword,
        code: code,
      );

      if (success) {
        emailAuth.resetStatus();
        Get.snackbar("성공", "비밀번호가 변경되었습니다.");

        // Named 방식 대신 직접 화면 클래스로 이동
        Future.delayed(const Duration(seconds: 1), () {
          Get.offAll(() => LoginScreen());
        });
      } else {
        Get.snackbar("실패", "비밀번호 재설정 실패. 인증번호를 확인해주세요.");
      }
    } catch (e) {
      Get.snackbar("오류", "서버 통신 중 에러가 발생했습니다.");
    } finally {
      isSubmitting.value = false;
    }
  }
}