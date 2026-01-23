import 'package:flutter/material.dart';
import '../Directory/core/theme.dart';

class WhiskyListCard extends StatelessWidget {
  final Map<String, dynamic> whisky;
  final VoidCallback? onTap;
  final VoidCallback? onFavoriteTap;
  final bool? isFavorite;
  final EdgeInsetsGeometry? margin;
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
    // 데이터 추출 및 타입 변환
    final String wsDistillery = (whisky['ws_distillery'] ?? '').toString();
    final String wsCategory = (whisky['ws_category'] ?? '').toString();
    final String wsNameKo = (whisky['ws_name'] ?? '이름 없음').toString(); // 한글명
    final String wsNameEn = (whisky['ws_name_en'] ?? '')
        .toString(); // 영문명 (추가됨)
    final double wsRating =
        double.tryParse(whisky['ws_rating']?.toString() ?? '0.0') ?? 0.0;
    final bool fav = isFavorite ?? (whisky['is_liked'] == true);
    final List<String> flavorTags = List<String>.from(
      whisky['flavor_tags'] ?? [],
    );

    // 테마 스타일
    final textTheme = Theme.of(context).textTheme;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        // 카드 외관 스타일
        margin: margin ?? const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: OakeyTheme.surfacePure,
          borderRadius: OakeyTheme.brCard,
          boxShadow: OakeyTheme.cardShadow,
        ),
        child: Stack(
          children: [
            // 메인 콘텐츠 레이아웃
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 좌측: 위스키 이미지/아이콘 영역
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

                  // 우측: 위스키 정보 텍스트 영역
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // 카테고리
                        Text(
                          wsCategory.isEmpty ? '-' : wsCategory,
                          style: textTheme.labelSmall?.copyWith(
                            color: OakeyTheme.textHint,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),

                        // 위스키 한글 이름
                        Text(
                          wsNameKo,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: OakeyTheme.textMain,
                          ),
                        ),

                        // [추가] 위스키 영문 이름 (작게)
                        if (wsNameEn.isNotEmpty) ...[
                          const SizedBox(height: 0),
                          Text(
                            wsNameEn,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: textTheme.bodySmall?.copyWith(
                              fontSize: OakeyTheme.fontSizeXS,
                              color: OakeyTheme.textSub,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                        const SizedBox(height: 4),

                        // 별점 표시
                        _buildRatingRow(wsRating, textTheme),
                        const SizedBox(height: 8),

                        // 맛 태그 목록
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

            // 우측 상단 찜하기 버튼
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

  // 별점 UI 빌더
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

  // 태그 UI 빌더
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
