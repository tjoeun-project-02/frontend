import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../Directory/core/theme.dart';
import '../controller/user_controller.dart';
import '../controller/whisky_controller.dart';

class WhiskyListCard extends StatefulWidget {
  final Map<String, dynamic> whisky;
  final VoidCallback? onTap;
  final bool? isFavorite;
  final EdgeInsetsGeometry? margin;
  final Set<String> highlightFilters;

  const WhiskyListCard({
    super.key,
    required this.whisky,
    this.onTap,
    this.isFavorite,
    this.margin,
    this.highlightFilters = const {},
  });

  @override
  State<WhiskyListCard> createState() => _WhiskyListCardState();
}

class _WhiskyListCardState extends State<WhiskyListCard> {
  bool _isLiked = false;

  @override
  void initState() {
    super.initState();
    _isLiked = widget.isFavorite ?? (widget.whisky['is_liked'] == true);
  }

  // 부모 위젯 업데이트 시 상태 동기화
  @override
  void didUpdateWidget(covariant WhiskyListCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isFavorite != oldWidget.isFavorite) {
      if (widget.isFavorite != null) {
        setState(() {
          _isLiked = widget.isFavorite!;
        });
      }
    }
  }

  // 좋아요 버튼 클릭 시 동작
  Future<void> _onLikeTap() async {
    int currentUserId = 0;
    try {
      currentUserId = UserController.to.userId.value;
    } catch (e) {
      currentUserId = 0;
    }

    if (currentUserId == 0) {
      OakeyTheme.showToast("알림", "로그인이 필요한 기능입니다.", isError: true);
      return;
    }

    setState(() {
      _isLiked = !_isLiked;
    });

    final int wsId =
        int.tryParse(
          widget.whisky['ws_id']?.toString() ??
              widget.whisky['wsId']?.toString() ??
              '0',
        ) ??
        0;

    if (wsId != 0) {
      final controller = Get.find<WhiskyController>();
      await controller.toggleLike(wsId);
    }
  }

  @override
  Widget build(BuildContext context) {
    final String wsCategory = (widget.whisky['ws_category'] ?? '').toString();
    final String wsNameKo = (widget.whisky['ws_name'] ?? '이름 없음').toString();
    final String wsNameEn = (widget.whisky['ws_name_en'] ?? '').toString();
    final double wsRating =
        double.tryParse(widget.whisky['ws_rating']?.toString() ?? '0.0') ?? 0.0;

    final List<String> flavorTags = List<String>.from(
      widget.whisky['flavor_tags'] ?? [],
    );

    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        margin:
            widget.margin ?? const EdgeInsets.only(bottom: OakeyTheme.spacingM),
        padding: const EdgeInsets.all(OakeyTheme.spacingM),

        // 카드 스타일 테마 적용
        decoration: OakeyTheme.decoCard,

        child: Stack(
          children: [
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 위스키 이미지 영역
                  Container(
                    width: 90,
                    alignment: Alignment.center,
                    decoration: OakeyTheme.decoTag.copyWith(
                      borderRadius: OakeyTheme.radiusS,
                    ),
                    child:
                        widget.whisky['ws_image_url'] != null &&
                            widget.whisky['ws_image_url'].toString().isNotEmpty
                        ? ClipRRect(
                            borderRadius: OakeyTheme.radiusS,
                            child: Image.network(
                              widget.whisky['ws_image_url'],
                              fit: BoxFit.cover,
                              errorBuilder: (ctx, err, st) => const Icon(
                                Icons.liquor,
                                color: OakeyTheme.primarySoft,
                                size: 40,
                              ),
                            ),
                          )
                        : const Icon(
                            Icons.liquor,
                            color: OakeyTheme.primarySoft,
                            size: 40,
                          ),
                  ),
                  OakeyTheme.boxH_M,

                  // 위스키 정보 텍스트 영역
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          wsCategory.isEmpty ? '-' : wsCategory,
                          style: OakeyTheme.textBodyS.copyWith(
                            color: OakeyTheme.textHint,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          wsNameKo,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: OakeyTheme.textBodyL.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        if (wsNameEn.isNotEmpty) ...[
                          Text(
                            wsNameEn,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: OakeyTheme.textBodyM,
                          ),
                        ],
                        const SizedBox(height: 4),
                        _buildRatingRow(wsRating),
                        const SizedBox(height: 8),

                        // 플레이버 태그 목록
                        Wrap(
                          spacing: 6,
                          runSpacing: 4,
                          children: flavorTags.map((tag) {
                            final bool isHighlighted = widget.highlightFilters
                                .contains(tag);
                            return _buildTag(tag, isHighlighted);
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // 우측 상단 찜하기 아이콘
            Positioned(
              top: -2,
              right: 0,
              child: GestureDetector(
                onTap: _onLikeTap,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Icon(
                    _isLiked ? Icons.favorite : Icons.favorite_border,
                    color: _isLiked ? Colors.red : OakeyTheme.textHint,
                    size: 26,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 별점 표시 행
  Widget _buildRatingRow(double rating) {
    return Row(
      children: [
        const Icon(Icons.star, color: OakeyTheme.accentGold, size: 16),
        const SizedBox(width: 4),
        Text(
          rating.toString(),
          style: OakeyTheme.textBodyM.copyWith(fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  // 태그 스타일 빌더
  Widget _buildTag(String label, bool isHighlighted) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isHighlighted
            ? OakeyTheme.accentOrange
            : OakeyTheme.accentOrange.withOpacity(0.1),
        borderRadius: OakeyTheme.radiusXS,
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: isHighlighted ? Colors.white : OakeyTheme.accentOrange,
        ),
      ),
    );
  }
}
