import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../screen/auth/login_screen.dart';
import '../services/auth/auth_common.dart';
import '../controller/whisky_controller.dart';
import '../controller/tasting_note_controller.dart';

class UserController extends GetxController {
  static UserController get to => Get.find<UserController>();
  var nickname = "고객".obs;
  var userId = 0.obs;
  var isLoggedIn = false.obs;
  var loginType = "email".obs;
  var email = "".obs;
  var token = "".obs;

  @override
  void onInit() {
    super.onInit();
    loadUserData(); // 앱 시작 시 정보를 불러옴
  }

  Future<void> loadUserData() async {
    final prefs = await SharedPreferences.getInstance();

    // 1. SharedPreferences에서 토큰을 읽어 변수에 저장
    final storedToken = prefs.getString('accessToken') ?? "";
    token.value = storedToken;

    isLoggedIn.value = storedToken.isNotEmpty;
    nickname.value = prefs.getString('nickname') ?? "고객";
    userId.value = prefs.getInt('userId') ?? 0;
    loginType.value = prefs.getString('loginType') ?? "email";
    email.value = prefs.getString('email') ?? "";

    print(
      "✅ 전역 유저 정보 갱신 완료: ${nickname.value} (토큰 유무: ${token.value.isNotEmpty})",
    );
  }

  Future<bool> updateNickname(String newNickname) async {
    try {
      final updatedData = await AuthService.updateProfile(newNickname);

      if (updatedData != null) {
        nickname.value = updatedData['nickname'];

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('nickname', updatedData['nickname']);

        Get.snackbar("성공", "닉네임이 변경되었습니다.");
        return true; // 성공 반환
      }
    } catch (e) {
      print("Nickname Update Error: $e");
    }
    return false; // 실패 반환
  }

  // 2. 비밀번호 변경 메서드 추가
  Future<bool> updatePassword(
    String currentPw,
    String newPw,
    String confirmPw,
  ) async {
    if (currentPw.isEmpty || newPw.isEmpty || confirmPw.isEmpty) {
      Get.snackbar("알림", "모든 필드를 입력해 주세요.");
      return false;
    }
    if (newPw != confirmPw) {
      Get.snackbar("알림", "새 비밀번호가 일치하지 않습니다.");
      return false;
    }

    try {
      // AuthService.changePassword도 bool을 반환해야 합니다.
      bool success = await AuthService.changePassword(currentPw, newPw);

      if (success) {
        Get.snackbar("성공", "비밀번호가 변경되었습니다.");
        return true; // 성공 시 true 반환
      } else {
        Get.snackbar("실패", "현재 비밀번호가 올바르지 않습니다.");
        return false;
      }
    } catch (e) {
      Get.snackbar("오류", "서버 통신 중 에러가 발생했습니다.");
      return false;
    }
  }

  void logout() async {
    await AuthService.logout();
    nickname.value = "고객";
    userId.value = 0;
    email.value = ""; // 로그아웃 시 이메일도 초기화
    isLoggedIn.value = false;
    // WhiskyController가 메모리에 있다면 찾아서 정리합니다.
    if (Get.isRegistered<WhiskyController>()) {
      final whiskyController = Get.find<WhiskyController>();

      // 찜 목록 ID 비우기
      whiskyController.likedWhiskyIds.clear();

      // 화면에 떠있는 위스키들의 하트 표시도 모두 해제 (UI 갱신)
      for (var whisky in whiskyController.whiskies) {
        whisky.isLiked = false;
      }
      whiskyController.whiskies.refresh(); // 리스트 강제 새로고침
    }

    // (선택 사항) 테이스팅 노트 컨트롤러도 있다면 비워주기
    if (Get.isRegistered<TastingNoteController>()) {
      Get.find<TastingNoteController>().notes.clear();
    }
    Get.offAll(() => LoginScreen());
  }
}
