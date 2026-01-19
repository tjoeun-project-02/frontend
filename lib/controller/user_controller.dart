import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../screen/auth/login_screen.dart';
import '../services/auth/auth_common.dart';

class UserController extends GetxController {
  static UserController get to => Get.find<UserController>();
  var nickname = "고객".obs;
  var userId = 0.obs;
  var isLoggedIn = false.obs;

  @override
  void onInit() {
    super.onInit();
    checkLoginStatus();
    loadUserData(); // 앱 시작 시 정보를 불러옴
  }

  Future<void> checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('accessToken');
    isLoggedIn.value = (token != null && token.isNotEmpty);
    if (isLoggedIn.value) {
      nickname.value = prefs.getString('nickname') ?? "고객";
    }
  }

  // SharedPreferences에서 정보를 새로고침하는 함수
  Future<void> loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    nickname.value = prefs.getString('nickname') ?? "고객";
    userId.value = prefs.getInt('userId') ?? 0;
    print("✅ 전역 유저 정보 로드 완료: ${nickname.value}");
  }
  void logout() async {
    await AuthService.logout(); // SharedPreferences 비우기
    nickname.value = "고객";
    userId.value = 0;
    isLoggedIn.value = false;
    Get.offAll(() => LoginScreen());
  }
}