import 'package:flutter/material.dart';
import 'package:frontend/controller/user_controller.dart';
import 'package:frontend/screen/mypage/edit_profile_screen.dart';
import 'package:frontend/screen/mypage/liked_whisky_screen.dart';
import 'package:frontend/screen/mypage/tasting_note_screen.dart';
import 'package:get/get.dart';

class MyPage extends StatelessWidget {
  const MyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 25),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          Obx(() => Text("${UserController.to.nickname.value}님", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold))),
          const SizedBox(height: 30),

          // 메뉴 리스트
          _buildMenuTile("내 정보 수정", null, () => Get.to(() => const EditProfileScreen())),
          _buildMenuTile("내가 찜한 위스키", 24, () => Get.to(()=> const LikedWhiskyScreen())),
          _buildMenuTile("Tasting Notes", 8, () => Get.to(() => TastingNoteScreen())),

          const SizedBox(height: 40),
          Center(
            child: TextButton(
              onPressed: () {},
              child: const Text("로그아웃", style: TextStyle(color: Colors.grey, decoration: TextDecoration.underline)),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildMenuTile(String title, int? count, VoidCallback onTap) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10)],
          ),
          child: Row(
            children: [
              Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              const SizedBox(width: 8),
              if (count != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                  decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(10)),
                  child: Text(count.toString(), style: const TextStyle(fontSize: 12, color: Colors.grey)),
                ),
              const Spacer(),
              const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}