import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../Directory/core/theme.dart';
import '../../controller/home_controller.dart';
import '../../controller/survey_controller.dart';
import '../../controller/user_controller.dart';
import '../../controller/whisky_controller.dart';

import '../../widgets/bottom_bar.dart';
import '../../widgets/search_bar.dart';

import '../list/whisky_list_screen.dart';
import '../mypage/mypage_screen.dart';
import '../recommend/survey_screen.dart';
import 'guide_screen.dart';
import '../../models/whisky.dart'; // Whisky 모델 임포트 필요

class MainScreen extends StatelessWidget {
  MainScreen({super.key});

  final HomeController homeController = Get.put(HomeController());
  final SurveyController surveyController = Get.put(SurveyController());
  final WhiskyController whiskyController = Get.put(WhiskyController());

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      _buildHomeBody(),
      WhiskyListScreen(),
      const SurveyScreen(),
      const MyPage(),
    ];

    return Scaffold(
      backgroundColor: OakeyTheme.backgroundMain,
      appBar: AppBar(
        title: const Text(
          'Oakey',
          style: TextStyle(
            color: OakeyTheme.primaryDeep,
            fontWeight: FontWeight.w900,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: Obx(
        () => IndexedStack(
          index: homeController.currentIndex.value,
          children: pages,
        ),
      ),
      bottomNavigationBar: Obx(() {
        if (surveyController.surveyStep.value != 0) {
          return const SizedBox.shrink();
        }
        return OakeyBottomBar(
          currentIndex: homeController.currentIndex.value,
          onTap: homeController.changeTabIndex,
        );
      }),
    );
  }

  // 홈 탭 메인 화면
  Widget _buildHomeBody() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 인사말 영역
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Obx(
              () => Text(
                '안녕하세요 ${UserController.to.nickname.value}님\n어떤 위스키를 찾아볼까요?',
                style: OakeyTheme.textTitleL.copyWith(height: 1.3),
              ),
            ),
          ),
          OakeyTheme.boxV_L,

          // 검색바
          OakeySearchBar(
            controller: whiskyController.searchController,
            hintText: '위스키 이름이나 맛을 검색해보세요',
            onSubmitted: (value) {
              whiskyController.loadData();
              homeController.changeTabIndex(1); // 리스트 탭으로 이동
            },
            onCameraTap: () {
              print("카메라 버튼 클릭");
            },
          ),

          OakeyTheme.boxV_S,

          // 최근 검색어 영역
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '최근 검색어',
                  style: OakeyTheme.textBodyM.copyWith(
                    color: OakeyTheme.textHint,
                  ),
                ),
                OakeyTheme.boxV_S,
                _buildRecentSearches(),
              ],
            ),
          ),

          OakeyTheme.boxV_XL,

          // 가이드 배너 영역
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: _buildGuideBanner(),
          ),

          OakeyTheme.boxV_XL,

          // ★ 추천 위스키 영역 (데이터 연동)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Obx(
              () => Text(
                whiskyController.recommendedCategory.value.isEmpty
                    ? '오늘의 추천 위스키'
                    : '오늘의 추천 : ${whiskyController.recommendedCategory.value}',
                style: OakeyTheme.textTitleM,
              ),
            ),
          ),
          OakeyTheme.boxV_M,
          _buildRecommendationList(),

          const SizedBox(height: 40), // 하단 여백
        ],
      ),
    );
  }

  // 최근 검색어 칩 리스트
  Widget _buildRecentSearches() {
    return Obx(
      () => Wrap(
        spacing: 10,
        runSpacing: 10,
        children: homeController.recentSearches
            .map(
              (tag) => ActionChip(
                label: Text(
                  tag,
                  style: OakeyTheme.textBodyS.copyWith(
                    color: OakeyTheme.textSub,
                  ),
                ),
                backgroundColor: OakeyTheme.surfacePure,
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                shape: RoundedRectangleBorder(
                  borderRadius: OakeyTheme.radiusS,
                  side: const BorderSide(color: OakeyTheme.borderLine),
                ),
                onPressed: () {
                  whiskyController.searchController.text = tag;
                  whiskyController.loadData();
                  homeController.changeTabIndex(1);
                },
              ),
            )
            .toList(),
      ),
    );
  }

  // 가이드 배너
  Widget _buildGuideBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: OakeyTheme.primaryDeep,
        borderRadius: OakeyTheme.radiusL,
        boxShadow: [
          BoxShadow(
            color: OakeyTheme.primaryDeep.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'GUIDE FOR BEGINNER',
            style: OakeyTheme.textBodyS.copyWith(
              color: OakeyTheme.accentGold,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            '"위스키, 어떻게 시작해야 할까요?"\n초보자를 위한 친절한 안내서',
            style: OakeyTheme.textTitleM.copyWith(
              color: OakeyTheme.textWhite,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            '양주와의 차이점부터 나에게 맞는 시음법까지...',
            style: OakeyTheme.textBodyS.copyWith(
              color: OakeyTheme.textWhite.withOpacity(0.8),
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 44,
            child: ElevatedButton(
              onPressed: () => Get.to(() => const WhiskyGuideScreen()),
              style: ElevatedButton.styleFrom(
                backgroundColor: OakeyTheme.accentGold,
                foregroundColor: OakeyTheme.textMain,
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                shape: RoundedRectangleBorder(borderRadius: OakeyTheme.radiusM),
              ),
              child: const Text(
                '가이드 확인하기',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 추천 위스키 리스트
  Widget _buildRecommendationList() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 30),
      child: SizedBox(
        height: 220,
        child: Obx(() {
          // 데이터가 없을 때 처리
          if (whiskyController.recommendedWhiskies.isEmpty) {
            return const Center(child: Text("데이터를 불러오는 중입니다..."));
          }

          return ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20), // 리스트 양옆 여백
            itemCount: whiskyController.recommendedWhiskies.length,
            separatorBuilder: (_, __) => const SizedBox(width: 16),
            itemBuilder: (context, index) {
              final whisky = whiskyController.recommendedWhiskies[index];

              // 위스키 카드 UI
              return GestureDetector(
                onTap: () {
                  // 상세 페이지 이동 등 구현 가능
                  print("${whisky.wsName} 클릭됨");
                },
                child: Container(
                  width: 160,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: OakeyTheme.surfacePure,
                    borderRadius: OakeyTheme.radiusL,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 이미지 영역 (없으면 아이콘)
                      Expanded(
                        child: Center(
                          child:
                              whisky.wsImage != null &&
                                  whisky.wsImage!.isNotEmpty
                              ? Image.network(
                                  whisky.wsImage!, // 이미지 URL (서버 주소 확인 필요)
                                  errorBuilder: (context, error, stackTrace) {
                                    return const Icon(
                                      Icons.liquor,
                                      size: 48,
                                      color: OakeyTheme.textHint,
                                    );
                                  },
                                )
                              : const Icon(
                                  Icons.liquor,
                                  size: 50,
                                  color: OakeyTheme.primarySoft,
                                ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      // 텍스트 정보
                      Text(
                        whisky.wsCategory,
                        style: const TextStyle(
                          fontSize: 12,
                          color: OakeyTheme.primaryDeep,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        whisky.wsNameKo.isNotEmpty
                            ? whisky.wsNameKo
                            : whisky.wsName,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: OakeyTheme.textMain,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(
                            Icons.star_rounded,
                            size: 14,
                            color: OakeyTheme.accentGold,
                          ),
                          const SizedBox(width: 2),
                          Text(
                            whisky.wsRating.toString(),
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        }),
      ),
    );
  }
}
