import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../screen/main/main_screen.dart';
import '../services/auth/auth_common.dart';
import '../screen/auth/login_screen.dart';

class HomeController extends GetxController {
  // 관찰 가능한 상태 변수들
  var currentIndex = 0.obs;
  var recentSearches = <String>['피트 입문', '맥캘란', '셰리 캐스크'].obs;

  @override
  void onInit() {
    super.onInit();
  }

  // 탭 변경
  void changeTabIndex(int index) {
    currentIndex.value = index;
  }
  void goToTab(int index) {
    currentIndex.value = index;
    Get.offAll(() => MainScreen()); // 메인으로 돌아가면서 해당 탭 보여주기
  }
}