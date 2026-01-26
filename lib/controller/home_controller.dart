import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../screen/main/main_screen.dart';
// import '../services/auth/auth_common.dart';
// import '../screen/auth/login_screen.dart';

class HomeController extends GetxController {
  // 관찰 가능한 상태 변수들
  RxInt currentIndex = 0.obs;
  RxList<String> recentSearches = <String>[].obs; // 최근 검색어 리스트

  @override
  void onInit() {
    super.onInit();
    _loadRecentSearches(); // 앱 실행 시 저장된 검색어 불러오기
  }

  void changeTabIndex(int index) {
    currentIndex.value = index;
  }

  // 검색어 추가 및 로컬 저장
  Future<void> addRecentSearch(String term) async {
    if (term.isEmpty) return;

    // 중복 제거 및 최신 검색어를 맨 앞으로
    if (recentSearches.contains(term)) {
      recentSearches.remove(term);
    }
    recentSearches.insert(0, term);

    // 최대 10개까지만 저장
    if (recentSearches.length > 10) {
      recentSearches.removeLast();
    }

    // SharedPreferences에 저장
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('recent_searches', recentSearches);
  }

  // 저장된 검색어 불러오기
  Future<void> _loadRecentSearches() async {
    final prefs = await SharedPreferences.getInstance();
    final savedList = prefs.getStringList('recent_searches');
    if (savedList != null) {
      recentSearches.assignAll(savedList);
    }
  }

  // 검색어 삭제 (옵션)
  Future<void> removeSearch(String term) async {
    recentSearches.remove(term);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('recent_searches', recentSearches);
  }

  void goToTab(int index) {
    currentIndex.value = index;
    Get.offAll(() => MainScreen()); // 메인으로 돌아가면서 해당 탭 보여주기
  }
}
