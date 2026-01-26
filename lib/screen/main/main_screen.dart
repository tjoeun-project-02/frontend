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
import '../list/whisky_detail_screen.dart';
import '../mypage/mypage_screen.dart';
import '../recommend/survey_screen.dart';
import 'guide_screen.dart';
// import '../../models/whisky.dart';

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

  // 홈 탭 메인 화면 구성
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
              homeController.changeTabIndex(1);
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

          // 오늘의 추천 위스키 영역
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

          const SizedBox(height: 40),
        ],
      ),
    );
  }

  // 최근 검색어 리스트 빌더
  Widget _buildRecentSearches() {
    return Obx(() {
      // 최근 검색어가 없을 경우 처리
      if (homeController.recentSearches.isEmpty) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Text(
            "최근 검색어가 없습니다.",
            style: OakeyTheme.textBodyS.copyWith(color: OakeyTheme.textSub),
          ),
        );
      }

      // 가로 스크롤 가능한 리스트
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal, // 가로 스크롤 활성화
        child: Row(
          children: homeController.recentSearches.map((tag) {
            return Padding(
              padding: const EdgeInsets.only(right: 8.0), // 태그 간격 좁게 (8.0)
              child: ActionChip(
                label: Text(
                  tag,
                  style: OakeyTheme.textBodyS.copyWith(
                    color: OakeyTheme.textMain, // 텍스트 색상 조금 더 진하게
                    fontSize: 13,
                  ),
                ),
                //
                backgroundColor: OakeyTheme.textHint.withOpacity(0.2),
                elevation: 0,
                side: BorderSide.none, // 테두리 제거
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ), // 내부 여백 축소
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8), // 덜 둥글게 (Radius 8)
                ),
                onPressed: () {
                  // 칩 클릭 시 재검색 로직 (기존 동일)
                  whiskyController.searchController.text = tag;
                  homeController.addRecentSearch(tag);
                  whiskyController.loadData();
                  homeController.changeTabIndex(1);
                },
              ),
            );
          }).toList(),
        ),
      );
    });
  }

  // 가이드 배너 빌더
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

  // 추천 위스키 리스트 빌더
  Widget _buildRecommendationList() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 30),
      child: SizedBox(
        height: 220,
        child: Obx(() {
          if (whiskyController.recommendedWhiskies.isEmpty) {
            return const Center(child: Text("데이터를 불러오는 중입니다..."));
          }

          return ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: whiskyController.recommendedWhiskies.length,
            separatorBuilder: (_, __) => const SizedBox(width: 16),
            itemBuilder: (context, index) {
              final whisky = whiskyController.recommendedWhiskies[index];

              // 카드 클릭 시 상세 페이지 이동
              return GestureDetector(
                onTap: () {
                  // WhiskyDetailScreen으로 데이터 전달하며 이동
                  Get.to(() => WhiskyDetailScreen(whisky: whisky));
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
                      // 이미지 영역
                      Expanded(
                        child: Center(
                          child:
                              whisky.wsImage != null &&
                                  whisky.wsImage!.isNotEmpty
                              ? Image.network(
                                  whisky.wsImage!,
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
                      // 카테고리
                      Text(
                        whisky.wsCategory,
                        style: const TextStyle(
                          fontSize: 12,
                          color: OakeyTheme.primaryDeep,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      // 위스키 이름
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
                      // 별점
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
