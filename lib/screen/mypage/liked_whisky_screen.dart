import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LikedWhiskyScreen extends StatelessWidget {
  const LikedWhiskyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F5F2),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF4E342E), size: 20),
          onPressed: () => Get.back(),
        ),
        title: const Text('내가 찜한 위스키', style: TextStyle(color: Color(0xFF4E342E), fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(25),
        itemCount: 5, // 예시 데이터 개수
        separatorBuilder: (_, __) => const SizedBox(height: 15),
        itemBuilder: (context, index) => _buildWhiskyCard(),
      ),
    );
  }

  Widget _buildWhiskyCard() {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 8)],
      ),
      child: Row(
        children: [
          Container(
            width: 80, height: 80,
            decoration: BoxDecoration(color: const Color(0xFFF1EDE9), borderRadius: BorderRadius.circular(15)),
            child: const Icon(Icons.liquor, color: Color(0xFF8D776D)),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("SPEYSIDE", style: TextStyle(color: Colors.grey, fontSize: 10)),
                const Text("발베니 12년 더블우드", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                const Text("The Balvenie 12Y", style: TextStyle(color: Colors.grey, fontSize: 12)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 5,
                  children: ["Honey", "Vanilla"].map((tag) => _buildTag(tag)).toList(),
                )
              ],
            ),
          ),
          const Icon(Icons.favorite, color: Colors.brown, size: 20),
        ],
      ),
    );
  }
  Widget _buildTag(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(color: const Color(0xFFFDEFE1), borderRadius: BorderRadius.circular(5)),
      child: Text(label, style: const TextStyle(fontSize: 10, color: Colors.orange)),
    );
  }
}