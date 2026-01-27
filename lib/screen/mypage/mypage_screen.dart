import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../Directory/core/theme.dart';
import '../../controller/user_controller.dart';
import '../../controller/whisky_controller.dart';
import '../../controller/tasting_note_controller.dart';

import 'edit_profile_screen.dart';
import 'liked_whisky_screen.dart';
import 'tasting_note_screen.dart';

// 1. StatefulWidget으로 변경하여 생명주기(initState)를 사용합니다.
class MyPage extends StatefulWidget {
  const MyPage({super.key});

  @override
  State<MyPage> createState() => _MyPageState();
}

class _MyPageState extends State<MyPage> {
  // 2. 컨트롤러를 클래스 멤버로 선언
  final whiskyController = Get.put(WhiskyController());
  final noteController = Get.put(TastingNoteController());

  @override
  void initState() {
    super.initState();
    // 3. 마이페이지에 들어올 때마다 데이터를 새로고침하도록 명령합니다.
    // (GetX는 컨트롤러가 이미 살아있으면 onInit을 다시 실행하지 않기 때문에 수동으로 호출해야 합니다)

    // 테이스팅 노트 갯수 갱신
    if (Get.isRegistered<TastingNoteController>()) {
      noteController.fetchNotes();
    }

    // 찜한 위스키 갯수 갱신 (WhiskyController에 해당 함수가 있다면 호출하세요)
    // 예: whiskyController.fetchLikedWhiskies();
    // 만약 WhiskyController가 실시간형(Stream)이 아니라면 여기서 업데이트해주는 게 좋습니다.
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: OakeyTheme.backgroundMain,
      body: SingleChildScrollView(
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

            // 1. 내 정보 수정
            _buildMenuTile(
              title: "내 정보 수정",
              icon: Icons.person_outline_rounded,
              onTap: () => Get.to(() => const EditProfileScreen()),
            ),

            // 2. 내가 찜한 위스키
            _buildMenuTile(
              title: "내가 찜한 위스키",
              icon: Icons.favorite_border_rounded,
              onTap: () => Get.to(() => const LikedWhiskyScreen()),
              badge: Obx(
                () => _buildCountBadge(whiskyController.likedWhiskyIds.length),
              ),
            ),

            // 3. 테이스팅 노트
            _buildMenuTile(
              title: "Tasting Notes",
              icon: Icons.edit_note_rounded,
              onTap: () async {
                // 상세 화면으로 갔다가 돌아올 때도 갱신하고 싶다면 await 사용
                await Get.to(() => const TastingNoteScreen());
                noteController.fetchNotes();
              },
              badge: Obx(() => _buildCountBadge(noteController.notes.length)),
            ),

            const SizedBox(height: 48),

            // 로그아웃 버튼
            _buildLogoutButton(),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // 프로필 카드
  Widget _buildUserProfile() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: OakeyTheme.decoCard,
      child: Row(
        children: [
          // 프로필 이미지 영역
          Container(
            width: 80,
            height: 80,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: OakeyTheme.surfaceMuted.withOpacity(0.5),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(
              Icons.person_rounded,
              size: 40,
              color: OakeyTheme.primarySoft,
            ),
          ),

          const SizedBox(width: 20),

          // 텍스트 정보 영역
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Obx(
                  () => Text(
                    "${UserController.to.nickname.value} 님",
                    style: OakeyTheme.textTitleL,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  "반가워요! 오늘도 즐거운\n위스키 타임 되세요.",
                  style: OakeyTheme.textBodyS.copyWith(
                    color: OakeyTheme.textHint,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 메뉴 타일 빌더
  Widget _buildMenuTile({
    required String title,
    required IconData icon,
    required VoidCallback onTap,
    Widget? badge,
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
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: OakeyTheme.backgroundMain,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 22, color: OakeyTheme.textMain),
              ),
              const SizedBox(width: 16),

              Text(title, style: OakeyTheme.textBodyL),
              const SizedBox(width: 8),

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

  // 갯수 뱃지
  Widget _buildCountBadge(int count) {
    if (count == 0) return const SizedBox.shrink();

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

  // 로그아웃 버튼
  Widget _buildLogoutButton() {
    return Center(
      child: TextButton(
        onPressed: () {
          UserController.to.logout();
        },
        style: TextButton.styleFrom(
          foregroundColor: OakeyTheme.textHint,
          overlayColor: OakeyTheme.textHint.withOpacity(0.1),
        ),
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
