import 'package:flutter/material.dart';
import '../Directory/core/theme.dart';

class OakeyDetailAppBar extends StatelessWidget {
  const OakeyDetailAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      // 상단바 배경 및 그림자 설정
      width: double.infinity,
      decoration: BoxDecoration(
        color: OakeyTheme.backgroundMain,
        // boxShadow: OakeyTheme.cardShadow,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // 뒤로가기 버튼 정렬
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
              onPressed: () => Navigator.pop(context),
            ),
          ),
          // 중앙 로고 스타일 설정
          Text(
            'Oakey',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: OakeyTheme.primaryDeep,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}
