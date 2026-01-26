import 'package:get/get.dart';
import '../../services/api_service.dart';
import '../../Directory/core/theme.dart'; // OakeyTheme 임포트
import '../models/whisky.dart';
import '../screen/list/whisky_detail_screen.dart';
import 'whisky_controller.dart'; // WhiskyController 임포트

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
    } catch (e) {
      print("노트 불러오기 실패: $e");
    } finally {
      isLoading(false);
    }
  }

  // ID로 실제 위스키 데이터를 찾아서 이동
  void goToDetail(Map<String, dynamic> noteData) {
    try {
      // 1. 노트 데이터에서 위스키 ID 추출
      int targetId = int.tryParse(noteData['wsId'].toString()) ?? 0;

      if (targetId == 0) {
        OakeyTheme.showToast("오류", "위스키 정보를 찾을 수 없습니다.", isError: true);
        return;
      }

      // 2. WhiskyController에 이미 로드된 전체 리스트에서 해당 ID 찾기
      Whisky? realWhisky;
      try {
        if (Get.isRegistered<WhiskyController>()) {
          final whiskyController = Get.find<WhiskyController>();
          // 리스트에서 ID가 같은 첫 번째 요소 찾기
          realWhisky = whiskyController.whiskies.firstWhere(
            (w) => w.wsId == targetId,
            orElse: () => Whisky(
              wsId: targetId,
              wsName: noteData['wsName'] ?? '',
              wsNameKo: noteData['wsNameKo'] ?? '',
              wsCategory: noteData['wsCategory'] ?? '',
              wsImage: noteData['wsImage'],
              wsDistillery: '',
              wsAbv: 0.0,
              wsAge: 0,
              wsRating: 0.0,
              wsVoteCnt: 0,
              tags: [],
              tasteProfile: {},
            ),
          );
        }
      } catch (e) {
        print("위스키 찾기 에러: $e");
      }

      // 3. 찾은 객체(또는 임시 객체)를 가지고 상세 페이지로 이동
      // (realWhisky가 null일 경우를 대비해 위 orElse에서 임시 객체를 생성했습니다)
      if (realWhisky != null) {
        Get.to(() => WhiskyDetailScreen(whisky: realWhisky!));
      }
    } catch (e) {
      print("상세 이동 에러: $e");
      OakeyTheme.showToast("에러", "상세 페이지로 이동할 수 없습니다.", isError: true);
    }
  }

  // OakeyTheme.showToast 적용
  Future<void> deleteNote(int? commentId, int index) async {
    if (commentId == null) {
      OakeyTheme.showToast("에러", "삭제할 수 없는 항목입니다.", isError: true);
      return;
    }

    // 1. 서버에 DELETE 요청
    bool success = await ApiService.deleteNote(commentId: commentId);

    if (success) {
      // 2. 성공 시 로컬 리스트에서 즉시 삭제 (UI 반영)
      notes.removeAt(index);

      // 공통 토스트 사용
      OakeyTheme.showToast("삭제 완료", "테이스팅 노트가 삭제되었습니다.");
    } else {
      OakeyTheme.showToast("삭제 실패", "서버 오류로 삭제하지 못했습니다.", isError: true);
    }
  }
}
