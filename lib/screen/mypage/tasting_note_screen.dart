import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../Directory/core/theme.dart';
import '../../controller/tasting_note_controller.dart';
import '../../widgets/detail_app_bar.dart';

// 테이스팅 노트 메인 화면
class TastingNoteScreen extends StatefulWidget {
  const TastingNoteScreen({super.key});

  @override
  State<TastingNoteScreen> createState() => _TastingNoteScreenState();
}

class _TastingNoteScreenState extends State<TastingNoteScreen> {
  // 컨트롤러 주입
  final controller = Get.put(TastingNoteController());

  @override
  void initState() {
    super.initState();
    // 화면 진입 시 데이터 초기화
    if (Get.isRegistered<TastingNoteController>()) {
      controller.fetchNotes();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: OakeyTheme.backgroundMain,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const OakeyDetailAppBar(),

            // 상단 타이틀 및 개수 표시
            Obx(() => _buildHeader("Tasting Notes", controller.notes.length)),

            // 메인 리스트 영역
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

                // 당겨서 새로고침 기능 포함
                return RefreshIndicator(
                  onRefresh: () async {
                    await controller.fetchNotes();
                  },
                  color: OakeyTheme.primaryDeep,
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    itemCount: controller.notes.length,
                    itemBuilder: (context, index) {
                      return _buildNoteCard(context, controller, index);
                    },
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  // 상단 헤더 위젯
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

  // 개별 노트 카드 위젯
  Widget _buildNoteCard(
    BuildContext context,
    TastingNoteController controller,
    int index,
  ) {
    final data = controller.notes[index];

    return GestureDetector(
      // 상세 화면 이동 및 복귀 시 목록 갱신 로직
      onTap: () async {
        await controller.goToDetail(data);
        if (controller.initialized) {
          await controller.fetchNotes();
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: OakeyTheme.decoCard,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 왼쪽 이미지 영역
            Container(
              width: 90,
              height: 110,
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              decoration: BoxDecoration(
                color: OakeyTheme.surfaceMuted.withOpacity(0.3),
                borderRadius: OakeyTheme.radiusM,
              ),
              child: ClipRRect(
                borderRadius: OakeyTheme.radiusM,
                child: Image.network(
                  data['wsImage'] ?? '',
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => const Icon(
                    Icons.liquor,
                    color: OakeyTheme.primarySoft,
                    size: 40,
                  ),
                ),
              ),
            ),

            const SizedBox(width: 16),

            // 오른쪽 텍스트 정보 영역
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 위스키 이름 및 삭제 버튼
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              data['wsNameKo'] ?? '',
                              style: OakeyTheme.textTitleM.copyWith(
                                fontSize: 16,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              data['wsName'] ?? '',
                              style: OakeyTheme.textBodyS.copyWith(
                                color: OakeyTheme.textHint,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      // 삭제 아이콘 버튼
                      GestureDetector(
                        onTap: () => _showDeleteConfirmDialog(
                          context,
                          controller,
                          data['commentId'],
                          index,
                        ),
                        child: const Padding(
                          padding: EdgeInsets.only(left: 8, bottom: 8),
                          child: Icon(
                            Icons.delete_outline_rounded,
                            size: 20,
                            color: OakeyTheme.statusError,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // 노트 내용 미리보기
                  Text(
                    data['content'] ?? '',
                    style: OakeyTheme.textBodyM.copyWith(
                      height: 1.4,
                      color: OakeyTheme.textMain.withOpacity(0.8),
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 데이터 없을 때 표시할 위젯
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

  // 삭제 확인 팝업
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
