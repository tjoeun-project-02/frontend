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
    final SurveyController surveyCtrl = Get.find<SurveyController>();

    return Scaffold(
      backgroundColor: OakeyTheme.backgroundMain,
      body: Column(
        children: [
          // 상단 진행바 (인트로와 결과 화면 제외)
          Obx(
            () =>
                (surveyCtrl.surveyStep.value > 0 &&
                    surveyCtrl.surveyStep.value < 3)
                ? LinearProgressIndicator(
                    value: surveyCtrl.surveyStep.value / 2,
                    backgroundColor: OakeyTheme.borderLine,
                    color: OakeyTheme.primaryDeep,
                    minHeight: 4,
                  )
                : const SizedBox.shrink(),
          ),

          Expanded(
            child: Obx(() {
              switch (surveyCtrl.surveyStep.value) {
                case 0:
                  return _buildIntroStep(context, surveyCtrl);
                case 1:
                  return _buildStep1(surveyCtrl);
                case 2:
                  return _buildStep2(surveyCtrl);
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

  // STEP 1: 맛 선택 화면
  Widget _buildStep1(SurveyController surveyCtrl) {
    final tastes = ['달콤한', '스모키', '상큼한', '나무향', '스파이시', '고소한', '초콜릿', '견과류'];

    return Padding(
      padding: const EdgeInsets.all(30.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "STEP 01",
            style: OakeyTheme.textBodyS.copyWith(
              color: OakeyTheme.accentOrange,
              fontWeight: FontWeight.bold,
            ),
          ),
          OakeyTheme.boxV_S,
          Obx(
            () => Text(
              "${UserController.to.nickname.value}님이 선호하는\n위스키의 '맛'을 골라주세요.",
              style: OakeyTheme.textTitleL,
            ),
          ),
          const SizedBox(height: 25),

          // 맛 선택 태그 영역
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: tastes
                .map(
                  (taste) => Obx(() {
                    final isSelected = surveyCtrl.selectedTastes.contains(
                      taste,
                    );
                    return OakeyTag(
                      label: taste,
                      isSelected: isSelected,
                      onTap: () => isSelected
                          ? surveyCtrl.selectedTastes.remove(taste)
                          : surveyCtrl.selectedTastes.add(taste),
                    );
                  }),
                )
                .toList(),
          ),

          const Spacer(),

          // 하단 버튼 영역
          Row(
            children: [
              Expanded(
                child: OakeyButton(
                  text: "처음화면",
                  type: OakeyButtonType.outline, // 아웃라인 버튼 사용
                  onPressed: () => surveyCtrl.prevStep(),
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                flex: 2,
                child: OakeyButton(
                  text: "다음 단계로",
                  type: OakeyButtonType.primary,
                  onPressed: () => surveyCtrl.nextStep(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // STEP 2: 가격/향 선택 화면
  Widget _buildStep2(SurveyController surveyCtrl) {
    return Padding(
      padding: const EdgeInsets.all(30.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "STEP 02",
            style: OakeyTheme.textBodyS.copyWith(
              color: OakeyTheme.accentOrange,
              fontWeight: FontWeight.bold,
            ),
          ),
          OakeyTheme.boxV_S,
          Text("선호하는 가격대나\n추가적인 정보를 골라주세요.", style: OakeyTheme.textTitleL),

          const Spacer(),

          Row(
            children: [
              Expanded(
                child: OakeyButton(
                  text: "이전",
                  type: OakeyButtonType.outline,
                  onPressed: () => surveyCtrl.prevStep(),
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                flex: 2,
                child: OakeyButton(
                  text: "결과 보기",
                  type: OakeyButtonType.primary,
                  onPressed: () => surveyCtrl.nextStep(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
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
