import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../Directory/core/theme.dart';
import '../../controller/tasting_note_controller.dart';
import '../../widgets/oakey_detail_app_bar.dart';
import '../list/whisky_detail_screen.dart';
import '../../models/whisky.dart';

class TastingNoteScreen extends StatelessWidget {
  const TastingNoteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // 컨트롤러 주입
    final controller = Get.put(TastingNoteController());

    return Scaffold(
      backgroundColor: OakeyTheme.backgroundMain,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const OakeyDetailAppBar(),
            // 제목 옆의 숫자 배지도 실시간 반영되도록 Obx 처리
            Obx(() => _buildHeader("Tasting Notes", controller.notes.length)),

            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (controller.notes.isEmpty) {
                  return _buildEmptyState("작성된 노트가 없습니다.");
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: controller.notes.length,
                  itemBuilder: (context, index) {
                    // 인자를 2개만 넘기도록 수정 (또는 함수 정의를 3개로 수정)
                    return _buildNoteCard(context, controller, index);
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  // 상단 타이틀과 개수 배지를 생성하는 공통 헤더 빌더
  Widget _buildHeader(String title, int count) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 10),
      child: Row(
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: OakeyTheme.fontSizeL,
              fontWeight: FontWeight.w800,
              color: OakeyTheme.textMain,
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: OakeyTheme.accentOrange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              count.toString(),
              style: const TextStyle(
                fontSize: OakeyTheme.fontSizeM,
                fontWeight: FontWeight.w600,
                color: OakeyTheme.accentOrange,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 테이스팅 노트 전용 카드 위젯 빌더
  Widget _buildNoteCard(BuildContext context, TastingNoteController controller, int index) {
    final data = controller.notes[index];
    return InkWell(
      onTap: () => controller.goToDetail(data), // index 대신 data 맵 전체를 넘김
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(data['wsImage'] ?? '', width: 50, height: 50, fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const Icon(Icons.wine_bar, size: 30)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(data['wsNameKo'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold)),
                      Text(data['wsName'] ?? '', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                  onPressed: () {
                    // 삭제 확인 다이얼로그 호출
                    _showDeleteConfirmDialog(context, controller, data['commentId'], index);
                  },
                ),
              ],
            ),
            const Divider(height: 32),
            Text(data['content'] ?? '', style: const TextStyle(height: 1.5)),
          ],
        ),
      ),
    );
  }

  // 목록이 비어있을 때 표시할 공통 빈 화면 빌더
  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.edit_note_rounded,
            size: 64,
            color: OakeyTheme.textHint.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: OakeyTheme.textHint,
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmDialog(BuildContext context, TastingNoteController controller, int? commentId, int index) {
    Get.dialog(
      AlertDialog(
        backgroundColor: OakeyTheme.surfacePure,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          "노트 삭제",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: const Text("작성하신 테이스팅 노트를 삭제하시겠습니까?\n삭제된 내용은 복구할 수 없습니다."),
        actions: [
          TextButton(
            onPressed: () => Get.back(), // 다이얼로그 닫기
            child: Text("취소", style: TextStyle(color: OakeyTheme.textHint)),
          ),
          TextButton(
            onPressed: () {
              Get.back(); // 다이얼로그 먼저 닫기
              controller.deleteNote(commentId, index); // 실제 삭제 로직 실행

            },
            child: const Text("삭제", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
