import 'package:flutter/material.dart';
import 'package:frontend/controller/survey_controller.dart';
import 'package:frontend/controller/user_controller.dart';
import 'package:frontend/screen/mypage/mypage_screen.dart';
import 'package:frontend/screen/recommend/survey_screen.dart';
import 'package:frontend/screen/list/whisky_list_screen.dart';
import 'package:get/get.dart';
import '../../Directory/core/theme.dart';
import '../../controller/home_controller.dart';
import '../../widgets/oakey_bottom_bar.dart';
import 'guide_screen.dart';

class MainScreen extends StatelessWidget {
  MainScreen({super.key});

  final HomeController controller = Get.put(HomeController());
  final SurveyController navController = Get.put(SurveyController());

  @override
  Widget build(BuildContext context) {
    // 보여줄 페이지 리스트
    final List<Widget> pages = [
      _buildHomeBody(),         // 인덱스 0: 홈 (기존 UI)
      const WhiskyListScreen(), // 인덱스 1
      const SurveyScreen(),      // 인덱스 2: 설문조사 (추천)
      const MyPage(),   // 인덱스 3
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF9F5F2),
      appBar: AppBar(
        title: const Text('Oakey', style: TextStyle(color: Color(0xFF4E342E), fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,

      ),
      // Obx로 감싸서 인덱스에 따라 페이지 전환
      body: Obx(() => IndexedStack(
        index: controller.currentIndex.value,
        children: pages,
      )),
      bottomNavigationBar: Obx(() {
        if (navController.surveyStep.value != 0) {
          return const SizedBox.shrink();
        }

        return OakeyBottomBar(
          currentIndex: controller.currentIndex.value,
          onTap: controller.changeTabIndex,
        );
      }),
    );
  }

  Widget _buildHomeBody() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Obx(() => Text('안녕하세요 ${UserController.to.nickname.value}님\n어떤 위스키를 찾아볼까요?',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold))),
          const SizedBox(height: 20),
          _buildSearchBar(),
          const SizedBox(height: 25),
          const Text('최근 검색어', style: TextStyle(fontSize: 16, color: Colors.grey)),
          const SizedBox(height: 12),
          _buildRecentSearches(),
          const SizedBox(height: 30),
          _buildGuideBanner(),
          const SizedBox(height: 35),
          const Text('오늘의 추천 위스키', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 15),
          _buildRecommendationList(),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: TextField(
        decoration: InputDecoration(
          hintText: '검색어를 입력하세요',
          prefixIcon: const Icon(Icons.search, color: Colors.grey),
          suffixIcon: IconButton(
            icon: const Icon(Icons.camera_alt_outlined, color: Color(0xFF8D776D)),
            onPressed: () => controller.logoutAndGoToLogin(),
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 15),
        ),
      ),
    );
  }

  Widget _buildRecentSearches() {
    return Obx(() => Wrap(
      spacing: 10,
      children: controller.recentSearches.map((tag) => ActionChip(
        label: Text(tag, style: const TextStyle(color: Colors.grey)),
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10), side: const BorderSide(color: Color(0xFFE0E0E0))),
        onPressed: () {},
      )).toList(),
    ));
  }

  Widget _buildGuideBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(color: OakeyTheme.primaryDeep, borderRadius: BorderRadius.circular(20)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('GUIDE FOR BEGINNER',
              style: TextStyle(color: Color(0xFFD4AF37), fontWeight: FontWeight.bold, fontSize: 12)),
          const SizedBox(height: 10),
          const Text('"위스키, 어떻게 시작해야 할까요?"\n초보자를 위한 친절한 안내서',
              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold, height: 1.4)),
          const SizedBox(height: 15),
          const Text('양주와의 차이점부터 나에게 맞는 시음법까지...', style: TextStyle(fontSize: 15, color: Colors.white)),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => Get.to(() => WhiskyGuideScreen()), // Get.to 사용
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFDCC084),
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('가이드 확인하기', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendationList() {
    return Padding(
        padding: const EdgeInsets.only(bottom: 30),
        child: SizedBox(
          height: 200,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: 3,
            separatorBuilder: (_, __) => const SizedBox(width: 15),
            itemBuilder: (context, index) {
              return Container(
                width: 150,
                decoration: BoxDecoration(color: const Color(0xFFEFEBE9), borderRadius: BorderRadius.circular(15)),
              );
            },
          ),
        )
    );
  }
}