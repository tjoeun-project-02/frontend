import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../Directory/core/theme.dart';
import '../../widgets/oakey_detail_app_bar.dart';
import '../../widgets/whisky_card.dart';
import '../list/whisky_detail_screen.dart';

class LikedWhiskyScreen extends StatefulWidget {
  const LikedWhiskyScreen({super.key});

  @override
  State<LikedWhiskyScreen> createState() => _LikedWhiskyScreenState();
}

class _LikedWhiskyScreenState extends State<LikedWhiskyScreen> {
  // 백엔드 연동 전 사용할 찜 목록 목업 데이터
  List<Map<String, dynamic>> likedWhiskies = [
    {
      'ws_id': 1,
      'ws_distillery': 'SPEYSIDE',
      'ws_name': '발베니 12년 더블우드',
      'ws_name_en': 'The Balvenie 12Y',
      'ws_category': '싱글몰트',
      'ws_rating': 4.5,
      'is_liked': true,
      'flavor_tags': ['달콤한', '바닐라', '오크향'],
    },
    {
      'ws_id': 2,
      'ws_distillery': 'HIGHLAND',
      'ws_name': '맥캘란 12년 쉐리오크',
      'ws_name_en': 'Macallan 12Y Sherry Oak',
      'ws_category': '싱글몰트',
      'ws_rating': 4.8,
      'is_liked': true,
      'flavor_tags': ['과일향', '달콤한', '스파이시'],
    },
  ];

  // 찜 취소 시 목록에서 데이터를 제거하는 함수
  void _toggleFavoriteById(int id) {
    setState(() => likedWhiskies.removeWhere((w) => w['ws_id'] == id));
    Get.snackbar(
      "찜 해제",
      "목록에서 삭제되었습니다.",
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: OakeyTheme.primaryDeep.withOpacity(0.8),
      colorText: Colors.white,
      duration: const Duration(seconds: 1),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: OakeyTheme.backgroundMain,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const OakeyDetailAppBar(), // 공통 상단바 위젯
            _buildHeader("내가 찜한 위스키", likedWhiskies.length), // 페이지 타이틀 및 개수 배지
            Expanded(
              child: likedWhiskies.isEmpty
                  ? _buildEmptyState("찜한 위스키가 없습니다.") // 데이터가 없을 때의 화면
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 15,
                      ),
                      itemCount: likedWhiskies.length,
                      itemBuilder: (context, index) => WhiskyListCard(
                        whisky: likedWhiskies[index],
                        highlightFilters: const {},
                        onFavoriteTap: () =>
                            _toggleFavoriteById(likedWhiskies[index]['ws_id']),
                        onTap: () => Get.to(
                          () => WhiskyDetailScreen(
                            whiskyData: likedWhiskies[index],
                          ),
                        ),
                      ),
                    ),
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

  // 목록이 비어있을 때 표시할 공통 빈 화면 빌더
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
}
