import 'package:flutter/material.dart';

class PwfindScreen extends StatefulWidget {
  const PwfindScreen({super.key});

  @override
  State<PwfindScreen> createState() => _PwfindScreenState();
}

class _PwfindScreenState extends State<PwfindScreen> {
  final Color _brandColor = const Color(0xFF4E342E); // 짙은 브라운
  final Color _subColor = const Color(0xFF8D776D);   // 인증 버튼 색상
  final Color _backgroundColor = const Color(0xFFF9F5F2);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const BackButton(color: Colors.black),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '비밀번호 재설정',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.black),
            ),
            const SizedBox(height: 10),
            const SizedBox(height: 40),

            // EMAIL 섹션 (인증 버튼 포함)
            const Text('EMAIL', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _buildTextField(hint: 'oakey@email.com'),
                ),
                const SizedBox(width: 10),
                SizedBox(
                  height: 55,
                  child: ElevatedButton(
                    onPressed: () {}, // 이메일 인증 로직
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _subColor,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('인증 하기', style: TextStyle(color: Colors.white)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // PASSWORD 섹션
            _buildLabelTextField(label: 'NEW PASSWORD', hint: '비밀번호를 입력하세요', isPassword: true),
            const SizedBox(height: 20),

            // CONFIRM PASSWORD 섹션
            _buildLabelTextField(label: 'CONFIRM PASSWORD', hint: '비밀번호와 다시 입력하세요', isPassword: true),

            const SizedBox(height: 50),

            // 가입하기 버튼
            SizedBox(
              width: double.infinity,
              height: 60,
              child: ElevatedButton(
                onPressed: () {}, // 회원가입 완료 로직
                style: ElevatedButton.styleFrom(
                  backgroundColor: _brandColor,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                ),
                child: const Text(
                  '비밀번호 재설정',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  // 라벨이 포함된 텍스트 필드 빌더
  Widget _buildLabelTextField({required String label, required String hint, bool isPassword = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
        const SizedBox(height: 8),
        _buildTextField(hint: hint, isPassword: isPassword),
      ],
    );
  }

  // 공통 텍스트 필드 스타일
  Widget _buildTextField({required String hint, bool isPassword = false}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        obscureText: isPassword,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFD7CCC8)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFD7CCC8)),
          ),
        ),
      ),
    );
  }
}