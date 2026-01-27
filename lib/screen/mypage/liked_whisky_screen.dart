import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:convert';

import '../../Directory/core/theme.dart';
import '../../widgets/detail_app_bar.dart';
import '../list/whisky_detail_screen.dart';
import '../../models/whisky.dart';
import '../../controller/user_controller.dart';
import '../../controller/whisky_controller.dart';

class LikedWhiskyScreen extends StatefulWidget {
  const LikedWhiskyScreen({super.key});

  @override
  State<LikedWhiskyScreen> createState() => _LikedWhiskyScreenState();
}

class _LikedWhiskyScreenState extends State<LikedWhiskyScreen> {
  // WhiskyController를 가져옵니다.
  final WhiskyController controller = Get.put(WhiskyController());

  @override
  void initState() {
    super.initState();
    // 화면 진입 시 데이터가 없다면 로드 시도
    if (controller.whiskies.isEmpty) {
      controller.loadData();
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

            // 헤더 영역 (Obx로 감싸서 갯수 실시간 반영)
            Obx(
              () => _buildHeader("내가 찜한 위스키", controller.likedWhiskyIds.length),
            ),

            // 리스트 영역 (여기도 Obx로 감싸서 리스트 실시간 반영)
            Expanded(
              child: Obx(() {
                // 1. 전체 위스키 목록이 로드되지 않았을 때
                if (controller.whiskies.isEmpty && controller.isLoading.value) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: OakeyTheme.primaryDeep,
                    ),
                  );
                }

                // 2. 컨트롤러의 likedWhiskyIds를 이용해 실제 위스키 객체 리스트를 만듦
                // (최신순으로 보여주기 위해 reversed 사용)
                final myLikedWhiskies = controller.whiskies
                    .where((w) => controller.likedWhiskyIds.contains(w.wsId))
                    .toList()
                    .reversed
                    .toList();

                // 3. 찜한 위스키가 없을 때
                if (myLikedWhiskies.isEmpty) {
                  return _buildEmptyState("찜한 위스키가 없습니다.");
                }

                // 4. 리스트 출력
                return ListView.separated(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 15,
                  ),
                  itemCount: myLikedWhiskies.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    final whisky = myLikedWhiskies[index];
                    return _buildSimpleLikedCard(
                      whisky: whisky,
                      onTap: () {
                        Get.to(() => WhiskyDetailScreen(whisky: whisky));
                      },
                      onLikeTap: () {
                        // 여기서 찜 해제하면 리스트에서도 즉시 사라짐
                        controller.toggleLike(whisky.wsId);
                      },
                    );
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  // 카드 위젯 (Whisky 객체를 직접 받도록 수정)
  Widget _buildSimpleLikedCard({
    required Whisky whisky,
    required VoidCallback onTap,
    required VoidCallback onLikeTap,
  }) {
    // 이미지 URL 처리
    String imageUrl = whisky.wsImage ?? '';
    if (imageUrl.isNotEmpty && imageUrl.startsWith('/')) {
      imageUrl = 'http://10.0.2.2:8080$imageUrl';
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: OakeyTheme.decoCard,
        child: Row(
          children: [
            // 이미지 영역
            Container(
              width: 90,
              height: 100,
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              decoration: OakeyTheme.decoTag.copyWith(
                borderRadius: OakeyTheme.radiusS,
                color: OakeyTheme.surfaceMuted.withOpacity(0.3),
              ),
              child: imageUrl.isNotEmpty
                  ? ClipRRect(
                      borderRadius: OakeyTheme.radiusM,
                      child: Image.network(
                        imageUrl,
                        fit: BoxFit.contain,
                        errorBuilder: (ctx, err, st) => const Icon(
                          Icons.liquor,
                          color: OakeyTheme.primarySoft,
                          size: 40,
                        ),
                      ),
                    )
                  : const Icon(
                      Icons.liquor,
                      color: OakeyTheme.primarySoft,
                      size: 40,
                    ),
            ),
            const SizedBox(width: 16),

            // 정보 텍스트 영역
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ★ 카테고리 태그 (맨 위로 이동)
                  if (whisky.wsCategory.isNotEmpty) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: OakeyTheme.primarySoft.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        whisky.wsCategory,
                        style: OakeyTheme.textBodyS.copyWith(
                          fontSize: 11,
                          color: OakeyTheme.primaryDeep,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6), // 이름과의 간격
                  ],

                  // 한글 이름
                  Text(
                    whisky.wsNameKo.isNotEmpty ? whisky.wsNameKo : '이름 없음',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: OakeyTheme.textTitleM,
                  ),

                  // 영문 이름
                  if (whisky.wsName.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      whisky.wsName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: OakeyTheme.textBodyS,
                    ),
                  ],
                ],
              ),
            ),

            // 찜 버튼 (항상 빨간 하트)
            IconButton(
              onPressed: onLikeTap,
              icon: const Icon(Icons.favorite, color: Colors.red, size: 28),
            ),
          ],
        ),
      ),
    );
  }

  // 헤더 위젯
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

  // 데이터 없음 상태 위젯
  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.favorite_border_rounded,
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
}
