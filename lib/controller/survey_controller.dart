import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../screen/recommend/survey_result_screen.dart';
class SurveyController extends GetxController {
  var surveyStep = 0.obs; // 0: 인트로, 1: 맛, 2: 가격, 3: 로딩
  var selectedTastes = <String>[].obs;

  @override
  void onInit() {
    super.onInit();
  }

  void nextStep() {
    if (surveyStep.value == 2) {
      // 마지막 질문(Step 2)에서 클릭 시 로딩 및 결과창으로 이동
      submitSurvey();
    } else {
      surveyStep.value++;
    }
  }

  void prevStep() {
    if (surveyStep.value > 0) {
      surveyStep.value--; // 단순히 인덱스만 하나 줄임
    }
  }

  void resetSurvey() {
    surveyStep.value = 0;
    selectedTastes.clear();
  }

  Future<void> submitSurvey() async {
    surveyStep.value = 3; // 로딩 화면(default 케이스) 표시

    await Future.delayed(const Duration(seconds: 2));

    // 결과창으로 이동 (이때 surveyStep은 여전히 3인 상태)
    Get.to(() => const SurveyResultScreen(
      whiskyName: "발베니 14년 캐리비안 캐스크",
      englishName: "Balvenie 14Y Caribbean Cask",
      rating: 87.42,
      description: "선택하신 달콤함과 나무향 노트를 98% 보유하고 있는 위스키입니다.",
    ));
  }
}