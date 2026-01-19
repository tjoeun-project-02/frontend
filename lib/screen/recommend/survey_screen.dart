import 'package:flutter/material.dart';
import 'package:frontend/controller/user_controller.dart';
import 'package:get/get.dart';
import '../../controller/survey_controller.dart';

class SurveyScreen extends StatelessWidget {
  const SurveyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final SurveyController surveyCtrl = Get.find<SurveyController>();

    return Scaffold(
      backgroundColor: const Color(0xFFF9F5F2),
      body: Column(
        children: [
          // 진행바: 인트로(0)와 로딩(3)이 아닐 때만 표시
          Obx(() => (surveyCtrl.surveyStep.value > 0 && surveyCtrl.surveyStep.value < 3)
              ? LinearProgressIndicator(
            value: surveyCtrl.surveyStep.value / 2,
            backgroundColor: Colors.grey[200],
            color: const Color(0xFF4E342E),
            minHeight: 4,
          )
              : const SizedBox.shrink()),

          Expanded(
            child: Obx(() {
              switch (surveyCtrl.surveyStep.value) {
                case 0: return _buildIntroStep(context, surveyCtrl);
                case 1: return _buildStep1(surveyCtrl);
                case 2: return _buildStep2(surveyCtrl);
                default: return _buildResultLoading();
              }
            }),
          ),
        ],
      ),
    );
  }

  // [고정 레이아웃] STEP 0: 인트로 화면
  Widget _buildIntroStep(BuildContext context,SurveyController surveyCtrl) {
    return Column(
      children: [
        // 상단 갈색 박스 (화면의 약 42%)
        Container(
          width: double.infinity,
          height: MediaQuery.of(context).size.height * 0.42,
          decoration: const BoxDecoration(
            color: Color(0xFF4E342E),
            borderRadius: BorderRadius.only(bottomRight: Radius.circular(80)),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 50),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Spacer(),
              const Text("PREFERENCE TEST", style: TextStyle(color: Color(0xFFD4AF37), fontWeight: FontWeight.bold, letterSpacing: 1.2, fontSize: 12)),
              const SizedBox(height: 8),
              const Text("당신만의\n향을 찾아서", style: TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.bold, height: 1.2)),
            ],
          ),
        ),

        // 하단 텍스트 및 버튼 (Expanded로 남은 공간 활용)
        Expanded(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(35, 30, 35, 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(width: 40, height: 4, color: const Color(0xFFD4AF37)),
                const SizedBox(height: 25),
                Obx(() => Text("${UserController.to.nickname.value}님,\n어떤 위스키를 좋아하세요?",
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, height: 1.4))),
                const SizedBox(height: 15),
                const Text("간단한 질문을 통해\n가장 완벽하게 어울리는 위스키를 추천합니다.",
                    style: TextStyle(color: Colors.grey, fontSize: 13, height: 1.5)),

                const Spacer(), // 버튼을 맨 아래로 밀어냄

                SizedBox(
                  width: double.infinity,
                  height: 60,
                  child: ElevatedButton(
                    onPressed: () => surveyCtrl.nextStep(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4E342E),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    ),
                    child: const Text("테스트 시작하기", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // STEP 1: 맛 선택 (고정 레이아웃 버전)
  Widget _buildStep1(SurveyController surveyCtrl) {
    final tastes = ['달콤한', '스모키', '상큼한', '나무향', '스파이시', '고소한', '초콜릿', '견과류'];
    return Padding(
      padding: const EdgeInsets.all(30.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("STEP 01", style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          Obx(() => Text("${UserController.to.nickname.value}님이 선호하는\n위스키의 '맛'을 골라주세요.", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold))),
          const SizedBox(height: 25),

          // 태그 영역
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: tastes.map((taste) => Obx(() {
              final isSelected = surveyCtrl.selectedTastes.contains(taste);
              return GestureDetector(
                onTap: () => isSelected ? surveyCtrl.selectedTastes.remove(taste) : surveyCtrl.selectedTastes.add(taste),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFF4E342E) : Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: isSelected ? Colors.transparent : Colors.grey[300]!),
                  ),
                  child: Text(taste, style: TextStyle(color: isSelected ? Colors.white : Colors.black, fontSize: 14)),
                ),
              );
            })).toList(),
          ),

          const Spacer(), // 버튼을 맨 아래로 밀기

          Row(
            children: [
              Expanded(
                  child: OutlinedButton(
                      onPressed: () => surveyCtrl.prevStep(),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(0, 55),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      ),
                      child: const Text("처음화면")
                  )
              ),
              const SizedBox(width: 15),
              Expanded(flex: 2, child: _buildNextButton(surveyCtrl)),
            ],
          ),
        ],
      ),
    );
  }

  // STEP 2: 가격/향 선택 (생략된 디자인 참고)
  Widget _buildStep2(SurveyController surveyCtrl) {
    return Padding(
      padding: const EdgeInsets.all(30.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("STEP 02", style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          const Text("선호하는 가격대나\n추가적인 정보를 골라주세요.", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const Spacer(),
          Row(
            children: [
              Expanded(child: OutlinedButton(onPressed: () => surveyCtrl.prevStep(), child: const Text("이전"))),
              const SizedBox(width: 15),
              Expanded(flex: 2, child: _buildNextButton(surveyCtrl, isLast: true)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildResultLoading() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(color: Color(0xFF4E342E), strokeWidth: 2),
          const SizedBox(height: 40),
          Obx(() => Text("${UserController.to.nickname.value}님의 취향에 맞는\n위스키를 찾고 있어요",
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, height: 1.4))),
          const SizedBox(height: 10),
          const Text("잠시만 기다려 주세요...", style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildNextButton(SurveyController surveyCtrl, {bool isLast = false}) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF4E342E),
        minimumSize: const Size(double.infinity, 55),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      ),
      onPressed: () => surveyCtrl.nextStep(),
      child: Text(isLast ? "결과 보기" : "다음 단계로", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
    );
  }
}