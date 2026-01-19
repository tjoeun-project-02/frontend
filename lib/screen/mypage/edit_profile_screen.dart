import 'package:flutter/material.dart';
import 'package:frontend/controller/user_controller.dart';
import 'package:get/get.dart';
import '../../Directory/core/theme.dart';
import '../../widgets/oakey_detail_app_bar.dart';

class EditProfileScreen extends StatelessWidget {
  const EditProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final nicknameController = TextEditingController(text: UserController.to.nickname.value);
    // 사용자의 현재 데이터
    final String currentEmail = UserController.to.email.value;
    // 카카오 로그인 여부 (true일 경우 비밀번호 수정 비활성화)
    final bool isKakaoUser = UserController.to.loginType.value == "kakao";

    return Scaffold(
      backgroundColor: OakeyTheme.backgroundMain,
      body: SafeArea(
        child: Column(
          children: [
            // 공통 상단바 위젯 호출
            const OakeyDetailAppBar(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 10),
                    // 페이지 제목 섹션
                    _buildPageTitle(),
                    const SizedBox(height: 30),
                    // 닉네임 수정 카드 섹션
                    _buildInputCard(
                      title: "NICKNAME",
                      description: "나를 표현하는 멋진 이름을 정해보세요",
                      children: [
                        _buildCustomTextField(
                          controller: nicknameController,
                          hint: "닉네임 입력",
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    // 이메일 정보 카드 섹션 (수정 불가 - 비활성화)
                    _buildInputCard(
                      title: "EMAIL",
                      description: "이메일 주소는 수정할 수 없습니다",
                      children: [
                        _buildCustomTextField(
                          hint: currentEmail,
                          isEnabled: false,
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    // 비밀번호 수정 카드 섹션 (로그인 방식에 따라 비활성화 결정)
                    if (!isKakaoUser)
                      _buildInputCard(
                        title: "PASSWORD",
                        description: "안전한 서비스 이용을 위해 정기적으로 변경해 주세요",
                        children: [
                          _buildCustomTextField(
                            hint: "현재 비밀번호",
                            isPassword: true,
                          ),
                          const SizedBox(height: 12),
                          _buildCustomTextField(
                            hint: "새 비밀번호",
                            isPassword: true,
                          ),
                          const SizedBox(height: 12),
                          _buildCustomTextField(
                            hint: "비밀번호 확인",
                            isPassword: true,
                          ),
                        ],
                      ),
                    if (!isKakaoUser) const SizedBox(height: 40) else const SizedBox(height: 20),
                    // 변경사항 저장 버튼
                    _buildSaveButton(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 상단 페이지 제목 위젯 빌더
  Widget _buildPageTitle() {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        "내 정보 수정",
        style: TextStyle(
          fontSize: OakeyTheme.fontSizeL,
          fontWeight: FontWeight.w800,
          color: OakeyTheme.textMain,
        ),
      ),
    );
  }

  // 각 입력 항목을 감싸는 공통 카드 위젯 빌더
  Widget _buildInputCard({
    required String title,
    required String description,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: OakeyTheme.surfacePure,
        borderRadius: OakeyTheme.brCard,
        boxShadow: OakeyTheme.cardShadow,
        // border: Border.all(color: OakeyTheme.borderLine),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: OakeyTheme.fontSizeS,
              fontWeight: FontWeight.w600,
              color: OakeyTheme.textSub,
            ),
          ),
          const SizedBox(height: 16),
          ...children,
          const SizedBox(height: 16),
          Text(
            description,
            style: TextStyle(fontSize: 12, color: OakeyTheme.textHint),
          ),
        ],
      ),
    );
  }

  // 리스트 상세페이지와 통일된 디자인의 커스텀 텍스트 필드 빌더
  Widget _buildCustomTextField({
    TextEditingController? controller,
    required String hint,
    bool isPassword = false,
    bool isEnabled = true,
  }) {
    return TextField(
      controller: controller,
      enabled: isEnabled,
      obscureText: isPassword,
      style: TextStyle(
        color: isEnabled ? OakeyTheme.textMain : OakeyTheme.textHint,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: OakeyTheme.textHint),
        filled: true,
        fillColor: isEnabled
            ? OakeyTheme.surfacePure
            : OakeyTheme.surfaceMuted.withOpacity(0.5),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: OakeyTheme.borderLine),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: OakeyTheme.borderLine),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: OakeyTheme.primaryDeep,
            width: 1.5,
          ),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: OakeyTheme.borderLine.withOpacity(0.5)),
        ),
      ),
    );
  }

  // 변경사항 저장 버튼 빌더
  Widget _buildSaveButton() {
    return ElevatedButton(
      onPressed: () => Get.back(),
      style: ElevatedButton.styleFrom(
        backgroundColor: OakeyTheme.primaryDeep,
        minimumSize: const Size(double.infinity, 60),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        elevation: 0,
      ),
      child: const Text(
        "변경사항 저장",
        style: TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
