import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../Directory/core/theme.dart';
import '../../widgets/components.dart'; // OakeyButton 등이 포함된 파일
import '../../controller/survey_controller.dart';
import '../../controller/user_controller.dart';

class SurveyScreen extends StatelessWidget {
  const SurveyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final SurveyController surveyCtrl = Get.put(SurveyController());

    return Scaffold(
      backgroundColor: OakeyTheme.backgroundMain,
      body: SafeArea(
        child: Obx(() {
          switch (surveyCtrl.surveyStep.value) {
            case 0:
              return _buildIntroStep(context, surveyCtrl);
            case 1:
              return _buildStep1(surveyCtrl);
            default:
              return _buildResultLoading();
          }
        }),
      ),
    );
  }

  // STEP 0: 인트로 화면
  Widget _buildIntroStep(BuildContext context, SurveyController surveyCtrl) {
    return Column(
      children: [
        // 상단 디자인 영역
        Expanded(
          flex: 4,
          child: Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              color: OakeyTheme.primaryDeep,
              borderRadius: BorderRadius.only(bottomRight: Radius.circular(80)),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 50),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Spacer(),
                Text(
                  "PREFERENCE TEST",
                  style: OakeyTheme.textBodyS.copyWith(
                    color: OakeyTheme.accentGold,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "당신만의\n취향을 찾아서",
                  style: OakeyTheme.textTitleXL.copyWith(
                    color: OakeyTheme.textWhite,
                    height: 1.2,
                    fontSize: 32,
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),

        // 하단 설명 및 버튼 영역
        Expanded(
          flex: 5,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 35, vertical: 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(width: 40, height: 4, color: OakeyTheme.accentGold),
                const SizedBox(height: 30),
                Obx(
                  () => Text(
                    "${UserController.to.nickname.value}님,\n어떤 위스키를 좋아하세요?",
                    style: OakeyTheme.textTitleM.copyWith(height: 1.4),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  "몇 가지 간단한 질문을 통해\n가장 완벽하게 어울리는 위스키를 추천해 드릴게요.",
                  style: OakeyTheme.textBodyM.copyWith(
                    color: OakeyTheme.textHint,
                    height: 1.6,
                  ),
                ),

                const Spacer(),

                // 시작 버튼
                SizedBox(
                  width: double.infinity,
                  child: OakeyButton(
                    text: "테스트 시작하기",
                    size: OakeyButtonSize.large,
                    type: OakeyButtonType.primary,
                    onPressed: () => surveyCtrl.nextStep(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // STEP 1: 질문 화면
  Widget _buildStep1(SurveyController surveyCtrl) {
    return Obx(() {
      final question =
          surveyCtrl.questions[surveyCtrl.currentQuestionIndex.value];
      final totalQuestions = surveyCtrl.questions.length;
      final currentIdx = surveyCtrl.currentQuestionIndex.value;
      final progress = (currentIdx + 1) / totalQuestions;

      final int? selectedOptionIndex = surveyCtrl.selectedHistory[currentIdx];

      return Column(
        children: [
          // 1. 상단 진행바
          LinearProgressIndicator(
            value: progress,
            backgroundColor: OakeyTheme.borderLine.withOpacity(0.3),
            color: OakeyTheme.accentOrange,
            minHeight: 6,
          ),

          // 2. 질문 및 답변 영역
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center, // 세로 중앙 정렬
                children: [
                  const Spacer(flex: 1),

                  // 질문 번호
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: OakeyTheme.accentOrange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      "Q ${currentIdx + 1} / $totalQuestions",
                      style: OakeyTheme.textBodyS.copyWith(
                        color: OakeyTheme.accentOrange,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // 질문 텍스트 (가운데 정렬)
                  Text(
                    question['question'],
                    style: OakeyTheme.textTitleL.copyWith(
                      height: 1.4,
                      fontSize: 24,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const Spacer(flex: 1),

                  // 답변 옵션 버튼들 (가운데 정렬 및 너비 조정)
                  ...(question['options'] as List).asMap().entries.map((entry) {
                    int idx = entry.key;
                    var opt = entry.value;

                    bool isSelected = selectedOptionIndex == idx;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: SizedBox(
                        width: double.infinity, // 버튼 가로 꽉 채우기
                        child: OakeyButton(
                          text: opt['text'],
                          type: isSelected
                              ? OakeyButtonType.primary
                              : OakeyButtonType.outline,
                          size: OakeyButtonSize.large,
                          onPressed: () =>
                              surveyCtrl.selectOption(idx, opt['scores']),
                        ),
                      ),
                    );
                  }).toList(),

                  const Spacer(flex: 2),

                  // 이전 질문 버튼
                  if (currentIdx > 0)
                    TextButton.icon(
                      onPressed: () => surveyCtrl.prevQuestion(),
                      icon: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        size: 14,
                        color: OakeyTheme.textHint,
                      ),
                      label: Text(
                        "이전 질문으로",
                        style: OakeyTheme.textBodyM.copyWith(
                          color: OakeyTheme.textHint,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        overlayColor: OakeyTheme.textHint.withOpacity(0.1),
                      ),
                    )
                  else
                    const SizedBox(height: 48), // 첫 질문일 때 공간 확보

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      );
    });
  }

  // 로딩 화면
  Widget _buildResultLoading() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 로딩 인디케이터 디자인 강화
          Stack(
            alignment: Alignment.center,
            children: [
              const SizedBox(
                width: 80,
                height: 80,
                child: CircularProgressIndicator(
                  color: OakeyTheme.accentGold,
                  strokeWidth: 3,
                ),
              ),
              Icon(
                Icons.search_rounded,
                size: 32,
                color: OakeyTheme.accentGold.withOpacity(0.8),
              ),
            ],
          ),
          const SizedBox(height: 40),
          Obx(
            () => Text(
              "${UserController.to.nickname.value}님에게 딱 맞는\n위스키를 찾고 있어요",
              textAlign: TextAlign.center,
              style: OakeyTheme.textTitleM.copyWith(height: 1.5),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            "잠시만 기다려 주세요...",
            style: OakeyTheme.textBodyM.copyWith(color: OakeyTheme.textHint),
          ),
        ],
      ),
    );
  }
}
