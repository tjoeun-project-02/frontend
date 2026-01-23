import 'dart:async';
import 'package:get/get.dart';

import '../services/emailVerification/email_verification.dart';

class EmailVerificationController extends GetxController {
  final EmailService _service = EmailService();

  var isLoading = false.obs;
  var isEmailSent = false.obs;
  var isVerified = false.obs;

  var timerSeconds = 180.obs;
  Timer? _timer;

  // 인증번호 받기 버튼 클릭 시
  Future<void> requestSendCode(String email) async {
    if (email.trim().isEmpty) {
      Get.snackbar("알림", "이메일을 입력해주세요.");
      return;
    }

    try {
      isLoading.value = true; // 로딩 시작

      // 서비스 호출 (여기서 타임아웃이나 에러가 나도 catch로 이동함)
      bool success = await _service.sendCode(email);

      if (success) {
        isEmailSent.value = true;
        startTimer();
        Get.snackbar("성공", "인증번호가 발송되었습니다.");
      } else {
        Get.snackbar("오류", "서버 응답이 없거나 발송에 실패했습니다.");
      }
    } catch (e) {
      Get.snackbar("에러", "네트워크 연결을 확인해주세요.");
    } finally {
      isLoading.value = false;
      print("Loading state set to false");
    }
  }

  // 번호 확인 버튼 클릭 시
  Future<void> requestVerifyCode(String email, String code) async {
    isLoading.value = true;
    bool isValid = await _service.verifyCode(email, code);

    if (isValid) {
      isVerified.value = true;
      _timer?.cancel();
      Get.snackbar("성공", "이메일 인증이 완료되었습니다.");
    } else {
      Get.snackbar("실패", "인증번호가 일치하지 않거나 만료되었습니다.");
    }
    isLoading.value = false;
  }

  void startTimer() {
    _timer?.cancel();
    timerSeconds.value = 180;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (timerSeconds.value > 0) {
        timerSeconds.value--;
      } else {
        _timer?.cancel();
      }
    });
  }
  void resetStatus() {
    isEmailSent.value = false;
    isVerified.value = false;
    isLoading.value = false;
    timerSeconds.value = 180;
    _timer?.cancel();
  }
  @override
  void onClose() {
    _timer?.cancel();
    super.onClose();
  }
}