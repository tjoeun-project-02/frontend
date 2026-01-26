import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../Directory/core/theme.dart';
import '../../widgets/components.dart';
import '../../controller/survey_controller.dart';
import '../../controller/user_controller.dart';

class SurveyScreen extends StatelessWidget {
  const SurveyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final SurveyController surveyCtrl = Get.put(SurveyController());

    return Scaffold(
      backgroundColor: OakeyTheme.backgroundMain,
      body: Column(
        children: [
          Expanded(
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
        ],
      ),
    );
  }

  // STEP 0: 인트로 화면
  Widget _buildIntroStep(BuildContext context, SurveyController surveyCtrl) {
    return Column(
      children: [
        // 상단 디자인 영역
        Container(
          width: double.infinity,
          height: MediaQuery.of(context).size.height * 0.42,
          decoration: const BoxDecoration(
            color: OakeyTheme.primaryDeep,
            // 인트로 특유의 디자인을 위해 커스텀 둥글기 유지 (테마 변수 활용 가능 시 교체)
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
                "당신만의\n향을 찾아서",
                style: OakeyTheme.textTitleXL.copyWith(
                  color: OakeyTheme.textWhite,
                  height: 1.2,
                  fontSize: 30, // 강조를 위해 약간 키움
                ),
              ),
            ],
          ),
        ),

        // 하단 설명 및 버튼 영역
        Expanded(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(35, 30, 35, 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(width: 40, height: 4, color: OakeyTheme.accentGold),
                const SizedBox(height: 25),
                Obx(
                  () => Text(
                    "${UserController.to.nickname.value}님,\n어떤 위스키를 좋아하세요?",
                    style: OakeyTheme.textTitleM.copyWith(height: 1.4),
                  ),
                ),
                const SizedBox(height: 15),
                Text(
                  "간단한 질문을 통해\n가장 완벽하게 어울리는 위스키를 추천합니다.",
                  style: OakeyTheme.textBodyM.copyWith(
                    color: OakeyTheme.textHint,
                    height: 1.5,
                  ),
                ),

                const Spacer(),

                OakeyButton(
                  text: "테스트 시작하기",
                  size: OakeyButtonSize.large,
                  type: OakeyButtonType.primary,
                  onPressed: () => surveyCtrl.nextStep(),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStep1(SurveyController surveyCtrl) {
    return Obx(() {
      final question = surveyCtrl.questions[surveyCtrl.currentQuestionIndex.value];
      final progress = (surveyCtrl.currentQuestionIndex.value + 1) / surveyCtrl.questions.length;

      return Column(
        children: [
          // 상단에 질문별 진행바 추가
          LinearProgressIndicator(
            value: progress,
            backgroundColor: OakeyTheme.borderLine,
            color: OakeyTheme.accentOrange,
            minHeight: 4,
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(30.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "QUESTION 0${surveyCtrl.currentQuestionIndex.value + 1}",
                    style: OakeyTheme.textBodyS.copyWith(color: OakeyTheme.accentOrange, fontWeight: FontWeight.bold),
                  ),
                  OakeyTheme.boxV_S,
                  Text(
                    question['question'],
                    style: OakeyTheme.textTitleL.copyWith(height: 1.3),
                  ),
                  const SizedBox(height: 40),

                  // 답변 옵션 버튼들
                  ... (question['options'] as List).map((opt) => Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: OakeyButton(
                      text: opt['text'],
                      type: OakeyButtonType.outline,
                      size: OakeyButtonSize.large,
                      onPressed: () => surveyCtrl.selectOption(opt['scores']),
                    ),
                  )).toList(),

                  const Spacer(),

                  // 하단 컨트롤 버튼
                  Row(
                    children: [
                      IconButton(
                        onPressed: () => surveyCtrl.prevQuestion(),
                        icon: const Icon(Icons.arrow_back_ios),
                        color: OakeyTheme.textHint,
                      ),
                      const Text("이전 질문", style: TextStyle(color: OakeyTheme.textHint)),
                    ],
                  ),
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
          const CircularProgressIndicator(
            color: OakeyTheme.primaryDeep,
            strokeWidth: 2,
          ),
          const SizedBox(height: 40),
          Obx(
            () => Text(
              "${UserController.to.nickname.value}님의 취향에 맞는\n위스키를 찾고 있어요",
              textAlign: TextAlign.center,
              style: OakeyTheme.textTitleM.copyWith(height: 1.4),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            "잠시만 기다려 주세요...",
            style: OakeyTheme.textBodyM.copyWith(color: OakeyTheme.textHint),
          ),
        ],
      ),
    );
  }
}
