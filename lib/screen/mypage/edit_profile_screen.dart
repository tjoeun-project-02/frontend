import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../Directory/core/theme.dart';
import '../../widgets/detail_app_bar.dart';
import '../../widgets/components.dart';
import '../../controller/user_controller.dart';

class EditProfileScreen extends StatelessWidget {
  const EditProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final nicknameController = TextEditingController(
      text: UserController.to.nickname.value,
    );
    final currentPwController = TextEditingController();
    final newPwController = TextEditingController();
    final confirmPwController = TextEditingController();

    final String currentEmail = UserController.to.email.value;
    final bool isKakaoUser = UserController.to.loginType.value == "kakao";

    return Scaffold(
      backgroundColor: OakeyTheme.backgroundMain,
      body: SafeArea(
        child: Column(
          children: [
            const OakeyDetailAppBar(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 10),
                    Text("내 정보 수정", style: OakeyTheme.textTitleL),
                    OakeyTheme.boxV_XL,

                    // 닉네임 수정 카드
                    _buildInputCard(
                      title: "NICKNAME",
                      description: "나를 표현하는 멋진 이름을 정해보세요",
                      children: [
                        OakeyTextField(
                          controller: nicknameController,
                          hintText: "닉네임 입력",
                        ),
                      ],
                    ),
                    OakeyTheme.boxV_L,

                    // 이메일 정보 카드 (수정 불가)
                    _buildInputCard(
                      title: "EMAIL",
                      description: "이메일 주소는 수정할 수 없습니다",
                      children: [
                        OakeyTextField(
                          hintText: currentEmail,
                          readOnly: true, // 읽기 전용 스타일 적용
                        ),
                      ],
                    ),
                    OakeyTheme.boxV_L,

                    // 비밀번호 수정 카드 (카카오 유저 제외)
                    if (!isKakaoUser) ...[
                      _buildInputCard(
                        title: "PASSWORD",
                        description: "안전한 서비스 이용을 위해 정기적으로 변경해 주세요",
                        children: [
                          OakeyTextField(
                            controller: currentPwController,
                            hintText: "현재 비밀번호",
                            obscureText: true,
                          ),
                          OakeyTheme.boxV_S,
                          OakeyTextField(
                            controller: newPwController,
                            hintText: "새 비밀번호",
                            obscureText: true,
                          ),
                          OakeyTheme.boxV_S,
                          OakeyTextField(
                            controller: confirmPwController,
                            hintText: "비밀번호 확인",
                            obscureText: true,
                          ),
                        ],
                      ),
                      OakeyTheme.boxV_XL,
                    ] else ...[
                      OakeyTheme.boxV_L,
                    ],

                    // 변경사항 저장 버튼
                    OakeyButton(
                      text: "변경사항 저장",
                      type: OakeyButtonType.primary,
                      size: OakeyButtonSize.large,
                      onPressed: () async {
                        try {
                          bool isNicknameChanged = false;
                          bool isPasswordChanged = false;

                          // 닉네임 변경 시도
                          if (nicknameController.text.trim() !=
                              UserController.to.nickname.value) {
                            isNicknameChanged = await UserController.to
                                .updateNickname(nicknameController.text.trim());
                          }

                          // 비밀번호 변경 시도
                          if (!isKakaoUser &&
                              currentPwController.text.isNotEmpty) {
                            isPasswordChanged = await UserController.to
                                .updatePassword(
                                  currentPwController.text,
                                  newPwController.text,
                                  confirmPwController.text,
                                );
                          }

                          // 결과 처리 및 이동
                          if (isNicknameChanged || isPasswordChanged) {
                            Get.until(
                              (route) =>
                                  Get.currentRoute == '/MainScreen' ||
                                  route.isFirst,
                            );
                            OakeyTheme.showToast("완료", "정보가 성공적으로 수정되었습니다.");
                          } else {
                            if (nicknameController.text.trim() ==
                                    UserController.to.nickname.value &&
                                currentPwController.text.isEmpty) {
                              OakeyTheme.showToast("알림", "변경사항이 없습니다.");
                            }
                          }
                        } catch (e) {
                          OakeyTheme.showToast(
                            "오류",
                            "작업 중 에러가 발생했습니다.",
                            isError: true,
                          );
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 입력 카드 위젯 빌더
  Widget _buildInputCard({
    required String title,
    required String description,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      // 테마의 카드 스타일 적용
      decoration: OakeyTheme.decoCard,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: OakeyTheme.textBodyS.copyWith(
              fontWeight: FontWeight.w600,
              color: OakeyTheme.textSub,
            ),
          ),
          const SizedBox(height: 16),
          ...children,
          const SizedBox(height: 16),
          Text(
            description,
            style: OakeyTheme.textBodyS.copyWith(color: OakeyTheme.textHint),
          ),
        ],
      ),
    );
  }
}
