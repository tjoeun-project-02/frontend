import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../screen/auth/login_screen.dart';
import '../services/auth/auth_common.dart';

class UserController extends GetxController {
  static UserController get to => Get.find<UserController>();
  var nickname = "고객".obs;
  var userId = 0.obs;
  var isLoggedIn = false.obs;
  var loginType = "email".obs;
  var email = "".obs;

  @override
  void onInit() {
    super.onInit();
    loadUserData(); // 앱 시작 시 정보를 불러옴
  }

  Future<void> loadUserData() async {
    final prefs = await SharedPreferences.getInstance();

    final token = prefs.getString('accessToken');
    isLoggedIn.value = (token != null && token.isNotEmpty);

    nickname.value = prefs.getString('nickname') ?? "고객";
    userId.value = prefs.getInt('userId') ?? 0;
    loginType.value = prefs.getString('loginType') ?? "email";

    // 🔥 이메일 불러오기 추가
    // 카카오 유저라서 null로 저장했다면 빈 문자열("")이 들어갑니다.
    email.value = prefs.getString('email') ?? "";

    print("✅ 전역 유저 정보 갱신 완료: ${nickname.value} (이메일: ${email.value})");
  }

  void logout() async {
    await AuthService.logout();
    nickname.value = "고객";
    userId.value = 0;
    email.value = ""; // 로그아웃 시 이메일도 초기화
    isLoggedIn.value = false;
    Get.offAll(() => LoginScreen());
  }
}