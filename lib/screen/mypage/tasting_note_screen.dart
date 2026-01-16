import 'package:flutter/material.dart';
import 'package:get/get.dart';
class TastingNoteScreen extends StatelessWidget {
  const TastingNoteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F5F2),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF4E342E), size: 20),
          onPressed: () => Get.back(),
        ),
        title: const Text('Tasting Notes', style: TextStyle(color: Color(0xFF4E342E), fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(25),
        itemCount: 3,
        separatorBuilder: (_, __) => const SizedBox(height: 15),
        itemBuilder: (context, index) => _buildNoteCard(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: const Color(0xFF4E342E),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildNoteCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text("2024.01.15", style: TextStyle(color: Colors.grey, fontSize: 12)),
              Icon(Icons.more_horiz, color: Colors.grey),
            ],
          ),
          const SizedBox(height: 10),
          const Text("멕켈란 18년 셰리 캐스크", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
          const SizedBox(height: 8),
          const Text("정말 부드러운 목넘김과 풍부한 과일향이 인상적이었다. 특별한 날에 다시 마시고 싶은 맛.",
              style: TextStyle(color: Colors.grey, fontSize: 14, height: 1.5)),
          const SizedBox(height: 15),
          Wrap(
            spacing: 8,
            children: ["#달콤한", "#과일향"].map((tag) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(color: const Color(0xFFF1EDE9), borderRadius: BorderRadius.circular(8)),
              child: Text(tag, style: const TextStyle(fontSize: 11, color: Color(0xFF8D776D))),
            )).toList(),
          )
        ],
      ),
    );
  }
}