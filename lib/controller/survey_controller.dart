import 'package:frontend/screen/recommend/survey_result_screen.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class SurveyController extends GetxController {
  var surveyStep = 0.obs;
  var currentQuestionIndex = 0.obs;

  // DB 컬럼 구조에 맞춘 유저 선호도 벡터
  var userVector = {
    'FRUITY': 0.0,
    'MALTY': 0.0,
    'PEATY': 0.0,
    'SPICY': 0.0,
    'SWEET': 0.0,
    'WOODY': 0.0,
  }.obs;

  // 질문 데이터 리스트
  final List<Map<String, dynamic>> questions = [
    {
      "question": "평소 즐겨 먹는 디저트나 간식 취향은?",
      "options": [
        {"text": "상큼한 과일 타르트나 레몬 사탕", "scores": {"FRUITY": 5.0}},
        {"text": "달콤한 초콜릿 케이크나 바닐라 아이스크림", "scores": {"SWEET": 5.0}},
        {"text": "고소한 견과류나 담백한 곡물 빵", "scores": {"MALTY": 5.0}},
      ]
    },
    {
      "question": "캠핑장에서 맡는 '모닥불 연기 냄새'를 좋아하시나요?",
      "options": [
        {"text": "너무 좋다. 불멍 연기 냄새를 즐긴다", "scores": {"PEATY": 8.0}},
        {"text": "은은한 건 괜찮지만, 진한 건 부담스럽다", "scores": {"PEATY": 3.0}},
        {"text": "싫다. 연기 없는 깔끔한 향이 좋다", "scores": {"PEATY": 0.0, "FRUITY": 1.0}},
      ]
    },
    {
      "question": "평소 선호하는 커피나 차(Tea)의 스타일은?",
      "options": [
        {"text": "깔끔하고 가벼운 아메리카노나 녹차", "scores": {"FRUITY": 1.0}}, // Light Body
        {"text": "부드럽고 고소한 카페라떼나 밀크티", "scores": {"MALTY": 2.0, "SWEET": 1.0}},
        {"text": "진하고 묵직한 에스프레소나 한방차", "scores": {"WOODY": 2.0, "SPICY": 1.0}}, // Heavy Body
      ]
    },
    {
      "question": "위스키에서 과일 향이 난다면 어떤 느낌이 좋은가요?",
      "options": [
        {"text": "갓 딴 사과나 파인애플 같은 신선함", "scores": {"FRUITY": 4.0}},
        {"text": "말린 자두나 건포도 같은 진하고 묵직한 달콤함", "scores": {"SWEET": 3.0, "FRUITY": 2.0}},
      ]
    },
    {
      "question": "향신료의 알싸한 '스파이시'함은 어땠으면 하나요?",
      "options": [
        {"text": "후추나 생강처럼 톡 쏘는 자극이 있으면 좋겠다", "scores": {"SPICY": 5.0}},
        {"text": "나무 냄새나 가죽처럼 묵직하고 차분했으면 좋겠다", "scores": {"WOODY": 5.0}},
        {"text": "자극 없이 부드럽고 화사하게 넘어가길 원한다", "scores": {"SWEET": 2.0, "FRUITY": 1.0}},
      ]
    },
    {
      "question": "마신 뒤 입안에 남는 여운(Finish)은 어떤가요?",
      "options": [
        {"text": "꿀이나 캬라멜 같은 달콤함이 길게 남는 것", "scores": {"SWEET": 4.0}},
        {"text": "깔끔하고 드라이하게 딱 끊기는 것", "scores": {"SPICY": 2.0, "WOODY": 1.0}},
      ]
    },
  ];

  void selectOption(Map<String, double> optionScores) {
    optionScores.forEach((key, value) {
      userVector[key] = (userVector[key] ?? 0.0) + value;
    });

    if (currentQuestionIndex.value < questions.length - 1) {
      currentQuestionIndex.value++;
    } else {
      submitSurvey();
    }
  }

  void prevQuestion() {
    if (currentQuestionIndex.value > 0) {
      currentQuestionIndex.value--;
    } else {
      surveyStep.value = 0; // 인트로로 이동
    }
  }

  Future<void> submitSurvey() async {
    surveyStep.value = 3; // 로딩 화면 전환

    try {
      // 1. 서버 주소 설정 (본인 서버 IP 확인)
      final url = Uri.parse('http://10.0.2.2:8080/api/recommend');

      // 2. POST 요청 전송
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(userVector), // 유저 점수 데이터
      );

      if (response.statusCode == 200) {
        // 3. 받은 JSON 데이터를 List<WhiskyResponseDTO> 형태로 파싱
        List<dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));

        // 결과 화면으로 이동하며 데이터 전달
        Get.off(ResultScreen(), arguments: data);
      } else {
        Get.snackbar("에러", "추천 데이터를 가져오지 못했습니다.");
        surveyStep.value = 1; // 다시 설문으로 이동
      }
    } catch (e) {
      print("통신 에러: $e");
      surveyStep.value = 1;
    }
  }

  void nextStep() => surveyStep.value++;
}