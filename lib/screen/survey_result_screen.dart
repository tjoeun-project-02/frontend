import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controller/survey_controller.dart';

class SurveyResultScreen extends StatelessWidget {
  final String whiskyName;
  final String englishName; // 영어 이름 추가
  final double rating;      // 별점 점수 추가
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
      // 물리 뒤로가기나 제스처가 발생할 때 실행될 콜백
        onPopInvokedWithResult: (didPop, result) {
          if (didPop) {
            // 뒤로가기가 성공적으로 실행된 후, 컨트롤러 상태를 인트로(0)로 리셋
            final surveyCtrl = Get.find<SurveyController>();
            surveyCtrl.surveyStep.value = 0;
            surveyCtrl.selectedTastes.clear();
          }
        },
      child: Scaffold(
        backgroundColor: const Color(0xFFF9F6F4), // 배경색
        appBar: AppBar(
          automaticallyImplyLeading: false, // 기본 버튼은 숨기고
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF4E342E), size: 20),
            onPressed: () {
              Get.back();
            },
          ),
          title: const Text('Oakey', style: TextStyle(color: Color(0xFF4E342E), fontWeight: FontWeight.bold)),
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            children: [
              const SizedBox(height: 10),
              const Text(
                "황용배님을 위한 위스키를 찾았습니다!",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 25),

              // 메인 결과 카드
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(25),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(40),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 20)],
                ),
                child: Column(
                  children: [
                    // 위스키 이미지 영역 (목업)
                    Container(
                      width: 140,
                      height: 180,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1EDE9),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Center(
                        child: Icon(Icons.liquor, size: 50, color: Colors.orangeAccent),
                      ),
                    ),
                    const SizedBox(height: 25),

                    // 위스키 한글/영어 이름
                    Text(whiskyName, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 5),
                    Text(englishName, style: const TextStyle(fontSize: 14, color: Colors.grey)),
                    const SizedBox(height: 15),

                    // 별점 정보
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.star, color: Color(0xFFD4AF37), size: 24),
                        const SizedBox(width: 8),
                        Text(rating.toString(), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                        const SizedBox(width: 5),
                        const Text("(Whiskybase)", style: TextStyle(fontSize: 12, color: Colors.grey)),
                      ],
                    ),
                    const SizedBox(height: 25),

                    // 하단 설명 박스
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF9F6F4),
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("이런 점이 딱 맞아요!", style: TextStyle(fontWeight: FontWeight.bold)),
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
                          Text(description, style: const TextStyle(color: Colors.grey, height: 1.5, fontSize: 13)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),
              TextButton(
                onPressed: () => Get.back(),
                child: const Text("테스트 다시 하기", style: TextStyle(color: Colors.grey, decoration: TextDecoration.underline)),
              ),

              const Spacer(),

              // 하단 버튼 레이아웃
              Row(
                children: [
                  // 찜하기 버튼
                  Container(
                    width: 65,
                    height: 65,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1EDE9),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(Icons.favorite_border, color: Color(0xFF4E342E), size: 28),
                  ),
                  const SizedBox(width: 15),
                  // 상세 정보 버튼
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF42342E),
                        minimumSize: const Size(double.infinity, 65),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      ),
                      child: const Text("상세 정보 보러가기", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      )
    );
  }
}

// 태그용 위젯
class _Tag extends StatelessWidget {
  final String label;
  const _Tag({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFEFE6DD),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(label, style: const TextStyle(fontSize: 12, color: Color(0xFF8D776D))),
    );
  }
}