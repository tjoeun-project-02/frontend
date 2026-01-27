import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../Directory/core/theme.dart';

class OakeyDetailAppBar extends StatelessWidget {
  const OakeyDetailAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      // 상단바 배경 스타일 설정
      width: double.infinity,
      decoration: const BoxDecoration(color: OakeyTheme.backgroundMain),
      padding: const EdgeInsets.symmetric(
        horizontal: OakeyTheme.spacingS,
        vertical: 10,
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // 뒤로가기 버튼
          Align(
            alignment: Alignment.centerLeft,
            child: IconButton(
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              icon: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: OakeyTheme.primarySoft,
                size: 24,
              ),
              // onPressed: () => Navigator.pop(context),
              onPressed: () => Get.back(),
            ),
          ),
          // 중앙 로고 텍스트
          Text(
            'Oakey',
            style: OakeyTheme.textTitleM.copyWith(
              color: OakeyTheme.primaryDeep,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}
