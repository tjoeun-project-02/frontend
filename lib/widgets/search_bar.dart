import 'package:flutter/material.dart';
import '../Directory/core/theme.dart';

// 위스키 검색바 위젯
class OakeySearchBar extends StatelessWidget {
  // 검색어 제어 컨트롤러
  final TextEditingController controller;
  // 글자 입력 시 실행할 함수
  final ValueChanged<String>? onChanged;
  // 엔터키 입력 시 실행할 함수
  final ValueChanged<String>? onSubmitted;
  // 검색창 안내 문구
  final String hintText;
  // 카메라 아이콘 클릭 시 함수
  final VoidCallback? onCameraTap;

  const OakeySearchBar({
    super.key,
    required this.controller,
    this.onChanged,
    this.onSubmitted,
    this.hintText = '검색어를 입력하세요',
    this.onCameraTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          color: OakeyTheme.surfacePure,
          boxShadow: OakeyTheme.cardShadow,
          borderRadius: BorderRadius.circular(OakeyTheme.radiusM),
        ),
        child: TextField(
          controller: controller,
          onChanged: onChanged,
          onSubmitted: onSubmitted,
          textAlignVertical: TextAlignVertical.center,
          textInputAction: TextInputAction.search,
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: const TextStyle(
              color: OakeyTheme.textHint,
              fontSize: OakeyTheme.fontSizeM,
            ),
            prefixIcon: const Padding(
              padding: EdgeInsets.only(left: 12.0, right: 8.0),
              child: Icon(
                Icons.search_rounded,
                color: OakeyTheme.primarySoft,
                size: 26,
              ),
            ),
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
