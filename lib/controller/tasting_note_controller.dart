import 'package:get/get.dart';
import '../../services/api_service.dart';
import '../models/whisky.dart';
import '../screen/list/whisky_detail_screen.dart';

class TastingNoteController extends GetxController {
  var notes = <Map<String, dynamic>>[].obs;
  var isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    fetchNotes();
  }

  Future<void> fetchNotes() async {
    try {
      isLoading(true);
      var fetched = await ApiService.fetchAllMyNotes();
      notes.assignAll(fetched);
    } finally {
      isLoading(false);
    }
  }

  void goToDetail(Map<String, dynamic> data) {
    try {
      // 1. 서버에서 온 Map 데이터를 Whisky 객체로 변환
      // (모델에 fromJson 또는 fromDbMap 같은 팩토리 생성자가 있다고 가정합니다)
      final whisky = Whisky.fromJson(data);

      // 2. 객체를 생성자에 직접 전달
      Get.to(() => WhiskyDetailScreen(whisky: whisky));
    } catch (e) {
      print("데이터 변환 에러: $e");
      Get.snackbar("에러", "위스키 정보를 불러올 수 없습니다.");
    }
  }

  // 🔥 수정된 삭제 로직
  Future<void> deleteNote(int? commentId, int index) async {
    if (commentId == null) {
      Get.snackbar("에러", "삭제할 수 없는 항목입니다.");
      return;
    }

    // 1. ApiService를 사용하여 서버에 DELETE 요청
    bool success = await ApiService.deleteNote(commentId: commentId);

    if (success) {
      // 2. 서버 삭제 성공 시 로컬 리스트에서도 삭제 (UI 자동 업데이트)
      notes.removeAt(index);

      Get.snackbar(
        "삭제 완료",
        "테이스팅 노트가 안전하게 삭제되었습니다.",
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 1),
      );
    } else {
      Get.snackbar("삭제 실패", "서버 오류로 삭제하지 못했습니다.");
    }
  }
}