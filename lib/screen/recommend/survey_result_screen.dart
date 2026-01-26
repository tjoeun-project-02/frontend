import 'package:flutter/material.dart';
import 'package:frontend/controller/user_controller.dart';
import 'package:frontend/screen/main/main_screen.dart';
import 'package:frontend/screen/recommend/survey_screen.dart';
import 'package:get/get.dart';

import '../../Directory/core/theme.dart';
import '../../controller/home_controller.dart';
import '../../controller/survey_controller.dart';
import '../../models/whisky.dart';
import '../list/whisky_detail_screen.dart';
class ResultScreen extends StatelessWidget {
  const ResultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // 서버에서 받은 추천 리스트 (최대 3개 가정)
    final List<dynamic> results = Get.arguments ?? [];
    final PageController pageController = PageController(viewportFraction: 0.9);

    return Scaffold(
      backgroundColor: const Color(0xFFF9F6F2), // 시안의 부드러운 배경색
      appBar: AppBar(
        title: const Text("추천 결과", style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.home, color: Colors.black),
          onPressed: () {
            // 1. 결과나 설문 데이터를 들고 있는 컨트롤러 삭제 (상태 초기화)
            Get.delete<SurveyController>();
            // Get.delete<RecommendController>(); // 추천 컨트롤러가 따로 있다면 이것도 삭제

            // 2. 화면 이동
            Get.off(() => MainScreen());
          },
        ),
      ),
      body: Column(
        children: [
          const SizedBox(height: 10),
          Text("${UserController.to.nickname.value}님을 위한 위스키를 찾았습니다!", style: OakeyTheme.textTitleL),
          const SizedBox(height: 20),

          // 1. 가로 슬라이드 영역
          Expanded(
            child: PageView.builder(
              controller: pageController,
              itemCount: results.length,
              itemBuilder: (context, index) {
                final whisky = results[index];
                return _buildWhiskyCard(whisky);
              },
            ),
          ),

          // 2. 테스트 다시하기 버튼
          TextButton(
            onPressed: () {
              // 1. 결과나 설문 데이터를 들고 있는 컨트롤러 삭제 (상태 초기화)
              Get.delete<SurveyController>();
              // Get.delete<RecommendController>(); // 추천 컨트롤러가 따로 있다면 이것도 삭제
              Get.find<HomeController>().currentIndex.value = 2;
              // 2. 화면 이동
              Get.offAll(() => MainScreen());
            },
            child: const Text(
                "테스트 다시 하기",
                style: TextStyle(decoration: TextDecoration.underline, color: Colors.grey)
            ),
          ),
        ],
      ),
    );
  }

  // 추천 카드 위젯
  Widget _buildWhiskyCard(dynamic whiskyData) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Column(
        children: [
          Expanded(
            child: Image.network(
              whiskyData['wsImage'] ?? '',
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) => const Icon(Icons.liquor, size: 80),
            ),
          ),
          const SizedBox(height: 15),
          Text(whiskyData['wsNameKo'] ?? '이름 없음', style: OakeyTheme.textTitleM),
          Text(whiskyData['wsNameEn'] ?? '', style: const TextStyle(color: Colors.grey, fontSize: 12)),

          const SizedBox(height: 15),
          _buildReasonSection(whiskyData),

          const SizedBox(height: 20),
          // 카드 내부에 개별 버튼 배치 (results[0] 고정 문제 해결!)
          SizedBox(
            width: double.infinity,
            child: _buildDetailButton(whiskyData),
          ),
        ],
      ),
    );
  }

  Widget _buildReasonSection(dynamic whisky) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F3F0),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("이런 점이 딱 맞아요!", style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          // 태그 (서버에서 받은 tags 활용)
          Wrap(
            spacing: 8,
            children: (whisky['tags'] as List? ?? ["#달콤한_꿀", "#부드러운"]).map((tag) =>
                Chip(label: Text(tag, style: const TextStyle(fontSize: 12, color: Colors.brown)), backgroundColor: Colors.white)).toList(),
          ),
          const SizedBox(height: 10),
          Text(
            "취향 일치도 ${whisky['matchPercent']}%",
            style: const TextStyle(fontSize: 13, color: Colors.black54),
          ),
        ],
      ),
    );
  }

  // 상세 페이지 이동 버튼
  Widget _buildDetailButton(dynamic whiskyData) {
    return ElevatedButton(
      onPressed: () {
        try {
          // 설문조사 결과 데이터를 일반 위스키 데이터로 변환
          final Map<String, dynamic> normalizedData = {
            'wsId': whiskyData['wsId'] ?? 0,
            'wsName': whiskyData['wsNameEn'] ?? whiskyData['wsName'] ?? '',
            'wsNameKo': whiskyData['wsNameKo'] ?? '',
            'wsCategory': whiskyData['wsCategory'] ?? '',
            'wsDistillery': whiskyData['distillery'] ?? '정보 없음',
            'wsImage': whiskyData['wsImage'],
            'wsAbv': (whiskyData['wsAbv'] as num?)?.toDouble() ?? 0.0,
            'wsAge': whiskyData['wsAge'] ?? 0,
            'wsRating': (whiskyData['wsRating'] as num?)?.toDouble() ?? 0.0,
            'wsVoteCnt': whiskyData['votes'] ?? 0,
            'tags': List<String>.from(whiskyData['tags'] ?? []),

            // 핵심: tasteProfile이 null이거나 Map이 아닐 경우 처리
            'tasteProfile': whiskyData['tasteProfile'] is Map
                ? whiskyData['tasteProfile']
                : {},
          };

          final whiskyObject = Whisky.fromJson(normalizedData);

          // 2. 객체를 직접 전달하며 이동
          Get.to(() => WhiskyDetailScreen(whisky: whiskyObject));
        } catch (e) {
          print("객체 변환 에러 발생: $e");
          print("원본 서버 데이터 구조: $whiskyData");
        }
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF4A3A33),
        padding: const EdgeInsets.symmetric(vertical: 20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      child: const Text("상세 정보 보러가기", style: TextStyle(color: Colors.white)),
    );
  }
}