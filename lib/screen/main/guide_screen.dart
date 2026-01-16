import 'package:flutter/material.dart';
import 'package:get/get.dart'; // GetX 임포트 추가

class WhiskyGuideScreen extends StatefulWidget {
  const WhiskyGuideScreen({super.key});

  @override
  _WhiskyGuideScreenState createState() => _WhiskyGuideScreenState();
}

class _WhiskyGuideScreenState extends State<WhiskyGuideScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F2EE),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF4E342E), size: 20),
          onPressed: () => Get.back(),
        ),
        title: const Text('Oakey', style: TextStyle(color: Color(0xFF4E342E), fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeaderBanner(),
            _buildSectionTitle("CHAPTER 01", "위스키, 너는 누구니?"),
            _buildExpansionTile("위스키와 양주, 무엇이 다른가요?",
                "양주는 서양 술을 통틀어 부르는 말이에요. 위스키, 보드카, 진 등이 모두 양주에 속하죠. 하지만 위스키는 그 중 보리나 옥수수 같은 곡물을 써서 증류하고 오크통에 숙성한 특정 술만을 말합니다."),
            _buildExpansionTile("위스키의 유통기한은 어떻게 되나요?", "위스키는 도수가 높아 유통기한이 따로 없습니다."),
            _buildSectionTitle("CHAPTER 02", "위스키, 어떻게 마실까?"),
            _buildExpansionTile("초보자에게 추천하는 마시는 법은?", "처음에는 향을 즐기기 위해 니트(Neat)로 조금 마셔보고, 이후 하이볼로 즐기는 것을 추천합니다."),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // --- 위젯 빌더 부분은 기존과 동일하되 context 에러 방지를 위해 유지 ---

  Widget _buildHeaderBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Color(0xFF4E342E),
        borderRadius: BorderRadius.only(bottomRight: Radius.circular(80)),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("GUIDE FOR BEGINNER", style: TextStyle(color: Color(0xFFD4AF37), fontWeight: FontWeight.bold, fontSize: 14)),
          SizedBox(height: 8),
          Text("“위스키, 어떻게 시작해야 할까요?”\n초보자를 위한 친절한 안내서",
              style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold, height: 1.4)),
          SizedBox(height: 12),
          Text("가장 기초적인 정의부터 전문가처럼\n즐기는 법까지,\nOakey와 함께 차근차근 알아볼까요?",
              style: TextStyle(color: Colors.white70, fontSize: 14, height: 1.5)),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String chapter, String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 20, right: 20, top: 32, bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(chapter, style: const TextStyle(color: Color(0xFFB08968), fontWeight: FontWeight.bold, fontSize: 12)),
          const SizedBox(height: 4),
          Text(title, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18)),
        ],
      ),
    );
  }

  Widget _buildExpansionTile(String question, String answer) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: const Color(0xFFD7CCC8)),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          title: Text("Q  $question", style: const TextStyle(color: Color(0xFF5D4037), fontWeight: FontWeight.w600, fontSize: 15)),
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
              child: Text(answer, style: const TextStyle(color: Colors.black87, fontSize: 14, height: 1.6)),
            ),
          ],
        ),
      ),
    );
  }
}