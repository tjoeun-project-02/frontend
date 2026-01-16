import 'package:flutter/material.dart';
import '../Directory/core/theme.dart';

class WhiskyListCard extends StatelessWidget {
  final Map<String, dynamic>
  whisky; // 위스키 데이터 (id, name, engName, region, tags 등)
  final VoidCallback? onTap; // 카드 클릭 시 상세 이동
  final VoidCallback? onFavoriteTap; // 찜 버튼 클릭
  final bool? isFavorite; // 찜 상태 강제 지정용
  final EdgeInsetsGeometry? margin; // 하단 여백 조절

  const WhiskyListCard({
    super.key,
    required this.whisky,
    this.onTap,
    this.onFavoriteTap,
    this.isFavorite,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    // 데이터 안전하게 추출
    final String region = (whisky['region'] ?? '').toString();
    final String name = (whisky['name'] ?? '').toString();
    final String engName = (whisky['engName'] ?? '').toString();
    final List<String> tags = ((whisky['tags'] as List?) ?? [])
        .map((e) => e.toString())
        .toList();
    final bool fav = isFavorite ?? (whisky['isFavorite'] == true);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: margin ?? const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: OakeyTheme.surfacePure,
          borderRadius: BorderRadius.circular(
            25,
          ), // LikedWhiskyScreen에서 썼던 둥근 모서리
          boxShadow: OakeyTheme.cardShadow,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. 이미지 영역 (베이지 배경 박스)
            Container(
              width: 80,
              height: 80,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: OakeyTheme.surfaceMuted,
                borderRadius: BorderRadius.circular(15),
              ),
              child: const Icon(
                Icons.liquor,
                color: OakeyTheme.primarySoft,
                size: 40,
              ),
            ),

            const SizedBox(width: 15),

            // 2. 정보 영역 (텍스트 + 태그)
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    region.isEmpty ? '-' : region,
                    style: const TextStyle(
                      color: OakeyTheme.textHint,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    name.isEmpty ? '이름 없음' : name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: OakeyTheme.textMain,
                    ),
                  ),
                  Text(
                    engName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: OakeyTheme.textHint,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // 원래 스타일의 주황색 태그 영역
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: tags.map((t) => _buildTag(t)).toList(),
                  ),
                ],
              ),
            ),

            // 3. 찜 버튼 (하트 아이콘)
            IconButton(
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              visualDensity: VisualDensity.compact,
              onPressed: onFavoriteTap,
              icon: Icon(
                fav ? Icons.favorite : Icons.favorite_border,
                color: fav ? Colors.red : OakeyTheme.textHint, // 빨간색으로 포인트
                size: 30,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ✨ 황덕배님이 원하셨던 원래 주황색 태그 스타일
  Widget _buildTag(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: const Color(0xFFFDEFE1), // 원래 쓰던 연한 주황색 배경
        borderRadius: BorderRadius.circular(5),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 10,
          color: Colors.orange, // 원래 쓰던 주황색 텍스트
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
