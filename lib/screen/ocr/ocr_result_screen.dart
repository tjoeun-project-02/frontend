import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../Directory/core/theme.dart';
import '../list/whisky_detail_screen.dart';
import '../../models/whisky.dart';

class OcrResultScreen extends StatelessWidget {
  final List<dynamic> results; // FastAPI에서 받은 spring_top3 데이터

  const OcrResultScreen({super.key, required this.results});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: OakeyTheme.backgroundMain,
      appBar: AppBar(title: const Text("인식 결과", style: OakeyTheme.textTitleM), centerTitle: true),
      body: results.isEmpty
          ? const Center(child: Text("인식된 위스키 정보가 없습니다."))
          : ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: results.length,
        itemBuilder: (context, index) {
          final data = results[index];
          // Whisky 모델로 변환 (JSON 구조에 맞게 조정 필요)
          final whisky = Whisky.fromJson(data);

          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            shape: RoundedRectangleBorder(borderRadius: OakeyTheme.radiusM),
            child: ListTile(
              contentPadding: const EdgeInsets.all(12),
              leading: Image.network(whisky.wsImage ?? '', width: 50, errorBuilder: (_, __, ___) => const Icon(Icons.liquor)),
              title: Text(whisky.wsNameKo, style: OakeyTheme.textBodyM.copyWith(fontWeight: FontWeight.bold)),
              subtitle: Text(whisky.wsName, style: OakeyTheme.textBodyS),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Get.to(() => WhiskyDetailScreen(whisky: whisky)),
            ),
          );
        },
      ),
    );
  }
}