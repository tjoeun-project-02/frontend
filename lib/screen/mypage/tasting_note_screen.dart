import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../Directory/core/theme.dart';
import '../../controller/tasting_note_controller.dart';
import '../../widgets/detail_app_bar.dart';

class TastingNoteScreen extends StatelessWidget {
  const TastingNoteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(TastingNoteController());

    return Scaffold(
      backgroundColor: OakeyTheme.backgroundMain,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const OakeyDetailAppBar(),

            // 헤더 영역 (제목 + 갯수)
            Obx(() => _buildHeader("Tasting Notes", controller.notes.length)),

            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: OakeyTheme.primaryDeep,
                    ),
                  );
                }

                if (controller.notes.isEmpty) {
                  return _buildEmptyState("작성된 노트가 없습니다.");
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  itemCount: controller.notes.length,
                  itemBuilder: (context, index) {
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

  // 헤더 위젯 빌더
  Widget _buildHeader(String title, int count) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 10),
      child: Row(
        children: [
          Text(title, style: OakeyTheme.textTitleXL),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: OakeyTheme.accentOrange.withOpacity(0.1),
              borderRadius: OakeyTheme.radiusM,
            ),
            child: Text(
              count.toString(),
              style: OakeyTheme.textBodyM.copyWith(
                color: OakeyTheme.accentOrange,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 노트 카드 위젯 빌더
  Widget _buildNoteCard(
    BuildContext context,
    TastingNoteController controller,
    int index,
  ) {
    final data = controller.notes[index];

    return GestureDetector(
      onTap: () => controller.goToDetail(data),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(20),
        // 테마의 카드 스타일 적용
        decoration: OakeyTheme.decoCard,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // 위스키 이미지
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: OakeyTheme.surfaceMuted,
                    borderRadius: OakeyTheme.radiusS,
                  ),
                  child: ClipRRect(
                    borderRadius: OakeyTheme.radiusS,
                    child: Image.network(
                      data['wsImage'] ?? '',
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const Icon(
                        Icons.liquor,
                        color: OakeyTheme.primarySoft,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),

                // 위스키 이름 정보
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        data['wsNameKo'] ?? '',
                        style: OakeyTheme.textBodyL.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        data['wsName'] ?? '',
                        style: OakeyTheme.textBodyS,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),

                // 삭제 버튼
                IconButton(
                  icon: const Icon(
                    Icons.delete_outline_rounded,
                    color: OakeyTheme.statusError,
                  ),
                  onPressed: () => _showDeleteConfirmDialog(
                    context,
                    controller,
                    data['commentId'],
                    index,
                  ),
                ),
              ],
            ),

            // 구분선 및 내용
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Divider(
                height: 1,
                color: OakeyTheme.borderLine.withOpacity(0.5),
              ),
            ),
            Text(
              data['content'] ?? '',
              style: OakeyTheme.textBodyM.copyWith(height: 1.5),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  // 빈 화면 상태 위젯
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
            style: OakeyTheme.textBodyL.copyWith(color: OakeyTheme.textHint),
          ),
        ],
      ),
    );
  }

  // 삭제 확인 다이얼로그
  void _showDeleteConfirmDialog(
    BuildContext context,
    TastingNoteController controller,
    int? commentId,
    int index,
  ) {
    Get.dialog(
      AlertDialog(
        backgroundColor: OakeyTheme.surfacePure,
        shape: RoundedRectangleBorder(borderRadius: OakeyTheme.radiusL),
        title: const Text("노트 삭제", style: OakeyTheme.textTitleM),
        content: Text(
          "작성하신 테이스팅 노트를 삭제하시겠습니까?\n삭제된 내용은 복구할 수 없습니다.",
          style: OakeyTheme.textBodyM,
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              "취소",
              style: OakeyTheme.textBodyM.copyWith(color: OakeyTheme.textHint),
            ),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              controller.deleteNote(commentId, index);
            },
            child: Text(
              "삭제",
              style: OakeyTheme.textBodyM.copyWith(
                color: OakeyTheme.statusError,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
