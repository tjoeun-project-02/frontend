import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../Directory/core/theme.dart';
import '../../widgets/components.dart';
import '../../controller/home_controller.dart';
import '../../controller/survey_controller.dart';
import '../../controller/user_controller.dart';
import '../../screen/main/main_screen.dart';
import '../../models/whisky.dart';
import '../list/whisky_detail_screen.dart';

class ResultScreen extends StatelessWidget {
  const ResultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<dynamic> results = Get.arguments ?? [];
    final PageController pageController = PageController(
      viewportFraction: 0.85,
    );

    return Scaffold(
      backgroundColor: OakeyTheme.backgroundMain,
      appBar: AppBar(
        title: const Text("추천 결과", style: OakeyTheme.textTitleM),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.home_rounded, color: OakeyTheme.textMain),
          onPressed: _goHome,
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 20),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                children: [
                  Text(
                    "당신을 위한\n특별한 위스키를 찾았어요!",
                    style: OakeyTheme.textTitleL.copyWith(height: 1.3),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "${UserController.to.nickname.value}님의 취향을 완벽하게 저격할\n베스트 매치입니다.",
                    style: OakeyTheme.textBodyM.copyWith(
                      color: OakeyTheme.textHint,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            Expanded(
              child: results.isEmpty
                  ? _buildEmptyState()
                  : PageView.builder(
                      controller: pageController,
                      itemCount: results.length,
                      itemBuilder: (context, index) {
                        final whisky = results[index];
                        return AnimatedBuilder(
                          animation: pageController,
                          builder: (context, child) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 10,
                              ),
                              child: _buildWhiskyCard(whisky),
                            );
                          },
                        );
                      },
                    ),
            ),

            const SizedBox(height: 20),

            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 30),
              child: TextButton.icon(
                onPressed: _retryTest,
                icon: const Icon(
                  Icons.refresh_rounded,
                  size: 18,
                  color: OakeyTheme.textSub,
                ),
                label: Text(
                  "테스트 다시 하기",
                  style: OakeyTheme.textBodyM.copyWith(
                    color: OakeyTheme.textSub,
                    decoration: TextDecoration.underline,
                  ),
                ),
                style: TextButton.styleFrom(
                  overlayColor: OakeyTheme.textHint.withOpacity(0.1),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Text(
        "추천 결과를 불러올 수 없습니다.\n다시 시도해주세요.",
        textAlign: TextAlign.center,
        style: OakeyTheme.textBodyM.copyWith(color: OakeyTheme.textHint),
      ),
    );
  }

  Widget _buildWhiskyCard(dynamic whiskyData) {
    return Container(
      decoration: OakeyTheme.decoCard,
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            flex: 4,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 20),
              decoration: BoxDecoration(
                color: OakeyTheme.surfaceMuted.withOpacity(0.3),
                borderRadius: OakeyTheme.radiusL,
              ),
              child:
                  whiskyData['wsImage'] != null &&
                      whiskyData['wsImage'].toString().isNotEmpty
                  ? Image.network(
                      whiskyData['wsImage'],
                      fit: BoxFit.contain,
                      errorBuilder: (ctx, err, st) => const Icon(
                        Icons.liquor_rounded,
                        size: 80,
                        color: OakeyTheme.primarySoft,
                      ),
                    )
                  : const Icon(
                      Icons.liquor_rounded,
                      size: 80,
                      color: OakeyTheme.primarySoft,
                    ),
            ),
          ),

          const SizedBox(height: 24),

          Column(
            children: [
              Text(
                whiskyData['wsNameKo'] ?? '이름 없음',
                style: OakeyTheme.textTitleM.copyWith(fontSize: 20),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                whiskyData['wsNameEn'] ?? '',
                style: OakeyTheme.textBodyS.copyWith(
                  color: OakeyTheme.textHint,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),

          const SizedBox(height: 20),

          Expanded(flex: 3, child: _buildReasonSection(whiskyData)),

          const SizedBox(height: 20),

          OakeyButton(
            text: "상세 정보 보러가기",
            type: OakeyButtonType.primary,
            size: OakeyButtonSize.large,
            onPressed: () => _goToDetail(whiskyData),
          ),
        ],
      ),
    );
  }

  Widget _buildReasonSection(dynamic whisky) {
    final List<String> tags = List<String>.from(whisky['tags'] ?? []);
    // ★ 에러 방지: 숫자가 문자열로 와도 처리되도록 수정
    final int matchPercent =
        int.tryParse(whisky['matchPercent'].toString()) ?? 95;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: OakeyTheme.backgroundMain,
        borderRadius: OakeyTheme.radiusM,
        border: Border.all(color: OakeyTheme.borderLine.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "이런 점이 딱 맞아요!",
                style: OakeyTheme.textBodyS.copyWith(
                  fontWeight: FontWeight.bold,
                  color: OakeyTheme.primaryDeep,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: OakeyTheme.accentOrange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  "일치도 $matchPercent%",
                  style: OakeyTheme.textBodyS.copyWith(
                    fontSize: 11,
                    color: OakeyTheme.accentOrange,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: tags.isEmpty
                ? [const Text("-")]
                : tags.take(4).map((tag) => _buildTagChip(tag)).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildTagChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: OakeyTheme.surfacePure,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: OakeyTheme.borderLine),
      ),
      child: Text(
        "#$label",
        style: OakeyTheme.textBodyS.copyWith(
          fontSize: 11,
          color: OakeyTheme.textSub,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  void _goHome() {
    Get.delete<SurveyController>();
    Get.offAll(() => MainScreen());
  }

  void _retryTest() {
    Get.delete<SurveyController>();
    if (Get.isRegistered<HomeController>()) {
      Get.find<HomeController>().changeTabIndex(2);
    }
    Get.offAll(() => MainScreen());
  }

  // ★ [핵심 수정] 데이터 타입 에러 방지 (_goToDetail)
  void _goToDetail(dynamic whiskyData) {
    try {
      final Map<String, dynamic> normalizedData = {
        // 1. 숫자가 문자열("123")로 오더라도 int로 안전하게 변환
        'wsId': int.tryParse(whiskyData['wsId'].toString()) ?? 0,

        'wsName': whiskyData['wsNameEn'] ?? whiskyData['wsName'] ?? '',
        'wsNameKo': whiskyData['wsNameKo'] ?? '',
        'wsCategory': whiskyData['wsCategory'] ?? '',
        'wsDistillery': whiskyData['distillery'] ?? '정보 없음',
        'wsImage': whiskyData['wsImage'],

        // 2. 소수점(double) 변환 안전 장치
        'wsAbv': double.tryParse(whiskyData['wsAbv'].toString()) ?? 0.0,

        // 3. 정수(int) 변환 안전 장치
        'wsAge': int.tryParse(whiskyData['wsAge'].toString()) ?? 0,
        'wsRating': double.tryParse(whiskyData['wsRating'].toString()) ?? 0.0,
        'wsVoteCnt': int.tryParse(whiskyData['votes'].toString()) ?? 0,

        'tags': List<String>.from(whiskyData['tags'] ?? []),
        'tasteProfile': whiskyData['tasteProfile'] is Map
            ? whiskyData['tasteProfile']
            : {},
      };

      final whiskyObject = Whisky.fromJson(normalizedData);
      Get.to(() => WhiskyDetailScreen(whisky: whiskyObject));
    } catch (e) {
      print("상세 이동 에러: $e");
      OakeyTheme.showToast("오류", "상세 정보를 불러올 수 없습니다.", isError: true);
    }
  }
}
