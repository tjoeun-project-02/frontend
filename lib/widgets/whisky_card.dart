import 'package:flutter/material.dart';
import '../Directory/core/theme.dart';

class WhiskyListCard extends StatelessWidget {
  // 위스키 데이터
  final Map<String, dynamic> whisky;

  // 카드 전체 클릭 이벤트
  final VoidCallback? onTap;

  // 찜 버튼 클릭 이벤트
  final VoidCallback? onFavoriteTap;

  // 찜 상태 값
  final bool? isFavorite;

  // 카드 외부 여백
  final EdgeInsetsGeometry? margin;

  // 선택된 필터 목록
  final Set<String> highlightFilters;

  const WhiskyListCard({
    super.key,
    required this.whisky,
    this.onTap,
    this.onFavoriteTap,
    this.isFavorite,
    this.margin,
    this.highlightFilters = const {},
  });

  @override
  Widget build(BuildContext context) {
    // 위스키 기본 정보 추출
    final String wsDistillery = (whisky['ws_distillery'] ?? '').toString();
    final String wsName = (whisky['ws_name'] ?? '이름 없음').toString();
    final double wsRating =
        double.tryParse(whisky['ws_rating']?.toString() ?? '0.0') ?? 0.0;
    final bool fav = isFavorite ?? (whisky['is_liked'] == true);
    final List<String> flavorTags = List<String>.from(
      whisky['flavor_tags'] ?? [],
    );

    // 현재 테마 텍스트 스타일 참조
    final textTheme = Theme.of(context).textTheme;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        // 카드 전체 스타일
        margin: margin ?? const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: OakeyTheme.surfacePure,
          borderRadius: OakeyTheme.brCard,
          boxShadow: OakeyTheme.cardShadow,
        ),
        child: Stack(
          children: [
            // 카드 메인 콘텐츠 영역
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 위스키 이미지 영역
                  Container(
                    width: 90,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: OakeyTheme.surfaceMuted,
                      borderRadius: BorderRadius.circular(OakeyTheme.radiusS),
                    ),
                    child: const Icon(
                      Icons.liquor,
                      color: OakeyTheme.primarySoft,
                      size: 40,
                    ),
                  ),
                  const SizedBox(width: 16),

                  // 위스키 정보 텍스트 영역
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // 증류소 이름 표시
                        Text(
                          wsDistillery.isEmpty ? '-' : wsDistillery,
                          style: textTheme.labelSmall?.copyWith(
                            color: OakeyTheme.textHint,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),

                        // 위스키 이름 표시
                        Text(
                          wsName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: OakeyTheme.textMain,
                          ),
                        ),
                        const SizedBox(height: 4),

                        // 별점 표시 영역
                        _buildRatingRow(wsRating, textTheme),
                        const SizedBox(height: 8),

                        // 맛 태그 목록 영역
                        Wrap(
                          spacing: 6,
                          runSpacing: 4,
                          children: flavorTags.map((tag) {
                            final bool isHighlighted = highlightFilters
                                .contains(tag);
                            return _buildTag(tag, isHighlighted, textTheme);
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // 찜하기 버튼 오른쪽 상단 고정
            Positioned(
              top: -2,
              right: 0,
              child: IconButton(
                onPressed: onFavoriteTap,
                icon: Icon(
                  fav ? Icons.favorite : Icons.favorite_border,
                  color: fav ? Colors.red : OakeyTheme.textHint,
                  size: 26,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 별점 표시 위젯
  Widget _buildRatingRow(double rating, TextTheme textTheme) {
    return Row(
      children: [
        const Icon(
          Icons.star,
          color: OakeyTheme.accentGold,
          size: OakeyTheme.fontSizeM,
        ),
        const SizedBox(width: 4),
        Text(
          rating.toString(),
          style: textTheme.labelLarge?.copyWith(
            color: OakeyTheme.textMain,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  // 맛 태그 표시 위젯
  Widget _buildTag(String label, bool isHighlighted, TextTheme textTheme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isHighlighted
            ? OakeyTheme.accentOrange
            : OakeyTheme.accentOrange.withOpacity(0.1),
        borderRadius: OakeyTheme.brTag,
      ),
      child: Text(
        label,
        style: textTheme.labelSmall?.copyWith(
          fontSize: OakeyTheme.fontSizeXS,
          color: isHighlighted ? Colors.white : OakeyTheme.accentOrange,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
