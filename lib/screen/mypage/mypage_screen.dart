import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../Directory/core/theme.dart';
import '../../controller/user_controller.dart';
import '../../controller/whisky_controller.dart';
import '../../controller/tasting_note_controller.dart';

import 'edit_profile_screen.dart';
import 'liked_whisky_screen.dart';
import 'tasting_note_screen.dart';

class MyPage extends StatelessWidget {
  const MyPage({super.key});

  @override
  Widget build(BuildContext context) {
    // 컨트롤러 주입 (데이터 갯수 확인용)
    // putOrFind: 이미 메모리에 있으면 찾고, 없으면 생성
    final whiskyController = Get.put(WhiskyController());
    final noteController = Get.put(TastingNoteController());

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 30),

          // 사용자 프로필 카드
          _buildUserProfile(),
          OakeyTheme.boxV_XL,

          // 메뉴 섹션 타이틀
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 16),
            child: Text("계정 설정", style: OakeyTheme.textTitleM),
          ),

          // 1. 내 정보 수정 (뱃지 없음)
          _buildMenuTile(
            title: "내 정보 수정",
            icon: Icons.person_outline_rounded,
            onTap: () => Get.to(() => const EditProfileScreen()),
          ),

          // 2. 내가 찜한 위스키 (실시간 갯수 연동)
          _buildMenuTile(
            title: "내가 찜한 위스키",
            icon: Icons.favorite_border_rounded,
            onTap: () => Get.to(() => const LikedWhiskyScreen()),
            // Obx로 감싸서 찜 목록 갯수가 변하면 자동 갱신
            badge: Obx(
              () => _buildCountBadge(whiskyController.likedWhiskyIds.length),
            ),
          ),

          // 3. 테이스팅 노트 (실시간 갯수 연동)
          _buildMenuTile(
            title: "Tasting Notes",
            icon: Icons.edit_note_rounded,
            onTap: () => Get.to(() => const TastingNoteScreen()),
            // Obx로 감싸서 노트 갯수가 변하면 자동 갱신
            badge: Obx(() => _buildCountBadge(noteController.notes.length)),
          ),

          const SizedBox(height: 48),

          // 로그아웃 버튼
          _buildLogoutButton(),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  // 사용자 프로필 카드 빌더
  Widget _buildUserProfile() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      // 테마 카드 스타일 적용
      decoration: OakeyTheme.decoCard,
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: OakeyTheme.surfaceMuted,
            child: const Icon(
              Icons.person,
              size: 35,
              color: OakeyTheme.primarySoft,
            ),
          ),
          const SizedBox(width: 20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Obx(
                () => Text(
                  "${UserController.to.nickname.value} 님",
                  style: OakeyTheme.textTitleL,
                ),
              ),
              const SizedBox(height: 4),
              Text("반가워요! 오늘도 즐거운 위스키 타임 되세요.", style: OakeyTheme.textBodyS),
            ],
          ),
        ],
      ),
    );
  }

  // 메뉴 타일 빌더 (badge 위젯을 선택적으로 받음)
  Widget _buildMenuTile({
    required String title,
    required IconData icon,
    required VoidCallback onTap,
    Widget? badge, // 갯수 표시용 위젯 (선택사항)
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: OakeyTheme.radiusL,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          decoration: OakeyTheme.decoCard,
          child: Row(
            children: [
              Icon(icon, size: 22, color: OakeyTheme.textMain),
              const SizedBox(width: 16),
              Text(title, style: OakeyTheme.textBodyL),
              const SizedBox(width: 8),

              // 뱃지가 있으면 표시
              if (badge != null) badge,

              const Spacer(),
              const Icon(
                Icons.arrow_forward_ios_rounded,
                size: 14,
                color: OakeyTheme.textHint,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 갯수 표시 뱃지 디자인 (Obx 내부에서 호출됨)
  Widget _buildCountBadge(int count) {
    // 0개여도 표시하거나, 숨기고 싶으면 if (count == 0) return SizedBox.shrink(); 추가
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: OakeyTheme.accentOrange.withOpacity(0.1),
        borderRadius: OakeyTheme.radiusM,
      ),
      child: Text(
        count.toString(),
        style: OakeyTheme.textBodyS.copyWith(
          fontWeight: FontWeight.w600,
          color: OakeyTheme.accentOrange,
        ),
      ),
    );
  }

  // 로그아웃 버튼 빌더
  Widget _buildLogoutButton() {
    return Center(
      child: TextButton(
        onPressed: () {
          UserController.to.logout();
        },
        style: TextButton.styleFrom(foregroundColor: OakeyTheme.textHint),
        child: Text(
          "로그아웃",
          style: OakeyTheme.textBodyM.copyWith(
            color: OakeyTheme.textHint,
            decoration: TextDecoration.underline,
          ),
        ),
      ),
    );
  }
}
