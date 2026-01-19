import 'package:flutter/material.dart';
import 'package:frontend/controller/user_controller.dart';
import 'package:frontend/screen/mypage/edit_profile_screen.dart';
import 'package:frontend/screen/mypage/liked_whisky_screen.dart';
import 'package:frontend/screen/mypage/tasting_note_screen.dart';
import 'package:get/get.dart';
import '../../Directory/core/theme.dart'; // 전역 테마 임포트

class MyPage extends StatelessWidget {
  const MyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      // 전체 페이지 여백 설정
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
<<<<<<< Updated upstream
          const SizedBox(height: 20),
          Obx(() => Text("${UserController.to.nickname.value}님", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold))),
=======
>>>>>>> Stashed changes
          const SizedBox(height: 30),
          // 사용자 환영 문구 및 프로필 섹션
          _buildUserProfile(),
          const SizedBox(height: 32),
          // 메뉴 리스트 섹션 타이틀
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 16),
            child: Text(
              "계정 설정",
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          // 내 정보 수정 메뉴 타일
          _buildMenuTile(
            context,
            "내 정보 수정",
            null,
            Icons.person_outline_rounded,
            () => Get.to(() => const EditProfileScreen()),
          ),
          // 내가 찜한 위스키 메뉴 타일
          _buildMenuTile(
            context,
            "내가 찜한 위스키",
            24,
            Icons.favorite_border_rounded,
            () => Get.to(() => const LikedWhiskyScreen()),
          ),
          // 테이스팅 노트 메뉴 타일
          _buildMenuTile(
            context,
            "Tasting Notes",
            8,
            Icons.edit_note_rounded,
            () => Get.to(() => const TastingNoteScreen()),
          ),
          const SizedBox(height: 48),
          // 로그아웃 버튼 영역
          _buildLogoutButton(),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  // 사용자 이름 및 프로필 카드 빌더
  Widget _buildUserProfile() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: OakeyTheme.surfacePure,
        borderRadius: OakeyTheme.brCard,
        boxShadow: OakeyTheme.cardShadow,
      ),
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
              const Text(
                "황덕배 님",
                style: TextStyle(
                  fontSize: OakeyTheme.fontSizeXL,
                  fontWeight: FontWeight.bold,
                  color: OakeyTheme.primaryDeep,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                "반가워요! 오늘도 즐거운 위스키 타임 되세요.",
                style: TextStyle(
                  fontSize: OakeyTheme.fontSizeS,
                  color: OakeyTheme.textSub,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 개별 메뉴 타일 디자인 빌더
  Widget _buildMenuTile(
    BuildContext context,
    String title,
    int? count,
    IconData icon,
    VoidCallback onTap,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: OakeyTheme.brCard,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          decoration: BoxDecoration(
            color: OakeyTheme.surfacePure,
            borderRadius: OakeyTheme.brCard,
            // border: Border.all(color: OakeyTheme.borderLine),
          ),
          child: Row(
            children: [
              Icon(icon, size: 22, color: OakeyTheme.textMain),
              const SizedBox(width: 16),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: OakeyTheme.textMain,
                ),
              ),
              const SizedBox(width: 8),
              if (count != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: OakeyTheme.accentOrange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    count.toString(),
                    style: const TextStyle(
                      fontSize: OakeyTheme.fontSizeS,
                      fontWeight: FontWeight.w600,
                      color: OakeyTheme.accentOrange,
                    ),
                  ),
                ),
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

  // 로그아웃 버튼 빌더
  Widget _buildLogoutButton() {
    return Center(
      child: TextButton(
        onPressed: () {},
        style: TextButton.styleFrom(foregroundColor: OakeyTheme.textHint),
        child: const Text(
          "로그아웃",
          style: TextStyle(decoration: TextDecoration.underline, fontSize: 14),
        ),
      ),
    );
  }
}
