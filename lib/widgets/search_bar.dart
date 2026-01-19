import 'package:flutter/material.dart';
import '../Directory/core/theme.dart';

class OakeySearchBar extends StatelessWidget {
  // 검색어 입력 컨트롤러
  final TextEditingController controller;

  // 검색어 변경 콜백
  final ValueChanged<String>? onChanged;

  // 검색창 안내 문구
  final String hintText;

  // 카메라 버튼 클릭 콜백
  final VoidCallback? onCameraTap;

  const OakeySearchBar({
    super.key,
    required this.controller,
    this.onChanged,
    this.hintText = '검색어를 입력하세요',
    this.onCameraTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      // 검색창 외부 여백
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Container(
        // 검색창 전체 스타일
        height: 56,
        decoration: BoxDecoration(
          color: OakeyTheme.surfacePure,
          boxShadow: OakeyTheme.cardShadow,
          borderRadius: BorderRadius.circular(OakeyTheme.radiusM),
        ),
        child: TextField(
          // 검색어 입력 필드
          controller: controller,
          onChanged: onChanged,
          textAlignVertical: TextAlignVertical.center,
          decoration: InputDecoration(
            // 안내 문구 설정
            hintText: hintText,
            hintStyle: const TextStyle(
              color: OakeyTheme.textHint,
              fontSize: OakeyTheme.fontSizeM,
            ),

            // 왼쪽 검색 아이콘
            prefixIcon: const Padding(
              padding: EdgeInsets.only(left: 12.0, right: 8.0),
              child: Icon(
                Icons.search_rounded,
                color: OakeyTheme.primarySoft,
                size: 26,
              ),
            ),

            // 오른쪽 카메라 버튼
            suffixIcon: Padding(
              padding: const EdgeInsets.all(8.0),
              child: GestureDetector(
                onTap: onCameraTap,
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: OakeyTheme.surfaceMuted,
                    borderRadius: BorderRadius.circular(OakeyTheme.radiusS),
                  ),
                  child: const Icon(
                    Icons.camera_alt,
                    color: OakeyTheme.primarySoft,
                    size: 22,
                  ),
                ),
              ),
            ),

            // 기본 입력 테두리 제거
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 0,
            ),
          ),
        ),
      ),
    );
  }
}
