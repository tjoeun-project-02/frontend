import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../Directory/core/theme.dart';
import '../../controller/survey_controller.dart';
import '../../controller/user_controller.dart';

class SurveyResultScreen extends StatelessWidget {
  final String whiskyName;
  final String englishName;
  final double rating;
  final String description;

  const SurveyResultScreen({
    super.key,
    required this.whiskyName,
    required this.englishName,
    required this.rating,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          final surveyCtrl = Get.find<SurveyController>();
          surveyCtrl.surveyStep.value = 0;
          surveyCtrl.selectedTastes.clear();
        }
      },
      child: Scaffold(
        backgroundColor: OakeyTheme.backgroundMain,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: OakeyTheme.textMain,
              size: 20,
            ),
            onPressed: () => Get.back(),
          ),
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
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            children: [
              const SizedBox(height: 10),
              Obx(
                () => Text(
                  "${UserController.to.nickname.value}님을 위한 위스키를 찾았습니다!",
                  style: OakeyTheme.textTitleM,
                ),
              ),
              OakeyTheme.boxV_L,

              // 메인 결과 카드
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(25),
                // 테마의 카드 스타일 적용
                decoration: OakeyTheme.decoCard.copyWith(
                  borderRadius: OakeyTheme.radiusXL,
                ),
                child: Column(
                  children: [
                    // 위스키 이미지 영역
                    Container(
                      width: 140,
                      height: 180,
                      decoration: BoxDecoration(
                        color: OakeyTheme.surfaceMuted,
                        borderRadius: OakeyTheme.radiusL,
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.liquor_rounded,
                          size: 50,
                          color: OakeyTheme.accentOrange,
                        ),
                      ),
                    ),
                    OakeyTheme.boxV_L,

                    // 위스키 이름 정보
                    Text(
                      whiskyName,
                      style: OakeyTheme.textTitleL,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 5),
                    Text(
                      englishName,
                      style: OakeyTheme.textBodyS.copyWith(
                        color: OakeyTheme.textHint,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 15),

                    // 별점 정보
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.star_rounded,
                          color: OakeyTheme.accentGold,
                          size: 24,
                        ),
                        const SizedBox(width: 8),
                        Text(rating.toString(), style: OakeyTheme.textTitleM),
                        const SizedBox(width: 5),
                        Text(
                          "(Whiskybase)",
                          style: OakeyTheme.textBodyS.copyWith(
                            color: OakeyTheme.textHint,
                          ),
                        ),
                      ],
                    ),
                    OakeyTheme.boxV_L,

                    // 하단 설명 박스
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: OakeyTheme.backgroundMain,
                        borderRadius: OakeyTheme.radiusL,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "이런 점이 딱 맞아요!",
                            style: OakeyTheme.textBodyL.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 8,
                            children: const [
                              _Tag(label: "#황홀한_맛"),
                              _Tag(label: "#열대과일"),
                              _Tag(label: "#부드러운_넘김"),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            description,
                            style: OakeyTheme.textBodyS.copyWith(
                              color: OakeyTheme.textHint,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // 다시하기 버튼
              TextButton(
                onPressed: () => Get.back(),
                child: Text(
                  "테스트 다시 하기",
                  style: OakeyTheme.textBodyS.copyWith(
                    color: OakeyTheme.textHint,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),

              const Spacer(),

              // 하단 액션 버튼
              Row(
                children: [
                  // 찜하기 버튼
                  Container(
                    width: 65,
                    height: 65,
                    decoration: BoxDecoration(
                      color: OakeyTheme.surfaceMuted,
                      borderRadius: OakeyTheme.radiusL,
                    ),
                    child: const Icon(
                      Icons.favorite_border_rounded,
                      color: OakeyTheme.primaryDeep,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 15),

                  // 상세 정보 버튼
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: OakeyTheme.primaryDeep,
                        minimumSize: const Size(double.infinity, 65),
                        shape: RoundedRectangleBorder(
                          borderRadius: OakeyTheme.radiusL,
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        "상세 정보 보러가기",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

// 태그 위젯
class _Tag extends StatelessWidget {
  final String label;
  const _Tag({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: OakeyTheme
            .surfaceMuted, // 살짝 어두운 배경색으로 변경하거나 accentOrange.withOpacity 사용 가능
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        label,
        style: OakeyTheme.textBodyS.copyWith(
          color: OakeyTheme.primarySoft,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
