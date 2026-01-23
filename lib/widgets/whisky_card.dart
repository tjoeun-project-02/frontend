import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../Directory/core/theme.dart';
import '../controller/user_controller.dart';
import '../controller/whisky_controller.dart'; // ★ 컨트롤러 임포트 필수

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
    // 초기 좋아요 상태 설정
    _isLiked = widget.isFavorite ?? (widget.whisky['is_liked'] == true);
  }

  // ★ [핵심] 부모(리스트 화면)의 Obx가 감지해서 값을 바꾸면
  // 카드 내부 상태(_isLiked)도 강제로 동기화시키는 함수
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

  // 하트 클릭 로직
  Future<void> _onLikeTap() async {
    // 1. 로그인 체크
    int currentUserId = 0;
    try {
      currentUserId = UserController.to.userId.value;
    } catch (e) {
      currentUserId = 0;
    }

    if (currentUserId == 0) {
      Get.snackbar(
        "알림",
        "로그인이 필요한 기능입니다.",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: OakeyTheme.primaryDeep.withOpacity(0.8),
        colorText: Colors.white,
        margin: const EdgeInsets.all(20),
        duration: const Duration(seconds: 2),
      );
      return;
    }

    // 2. UI 낙관적 업데이트 (누르자마자 색깔 바꿈)
    setState(() {
      _isLiked = !_isLiked;
    });

    // 3. 위스키 ID 파싱 (ws_id 혹은 wsId 둘 다 대응)
    final int wsId =
        int.tryParse(
          widget.whisky['ws_id']?.toString() ??
              widget.whisky['wsId']?.toString() ??
              '0',
        ) ??
        0;

    if (wsId != 0) {
      // ★ [핵심] ApiService를 직접 부르지 않고 컨트롤러를 시킴
      // 그래야 '리스트 화면'의 Obx가 반응해서 다른 카드들의 상태도 관리함
      final controller = Get.find<WhiskyController>();
      await controller.toggleLike(wsId);
    }
  }

  @override
  Widget build(BuildContext context) {
    // 데이터 추출
    final String wsCategory = (widget.whisky['ws_category'] ?? '').toString();
    final String wsNameKo = (widget.whisky['ws_name'] ?? '이름 없음').toString();
    final String wsNameEn = (widget.whisky['ws_name_en'] ?? '').toString();
    final double wsRating =
        double.tryParse(widget.whisky['ws_rating']?.toString() ?? '0.0') ?? 0.0;

    final List<String> flavorTags = List<String>.from(
      widget.whisky['flavor_tags'] ?? [],
    );

    final textTheme = Theme.of(context).textTheme;

    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        margin: widget.margin ?? const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: OakeyTheme.surfacePure,
          borderRadius: OakeyTheme.brCard,
          boxShadow: OakeyTheme.cardShadow,
        ),
        child: Stack(
          children: [
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 좌측 이미지 영역
                  Container(
                    width: 90,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: OakeyTheme.surfaceMuted,
                      borderRadius: BorderRadius.circular(OakeyTheme.radiusS),
                    ),
                    child:
                        widget.whisky['ws_image_url'] != null &&
                            widget.whisky['ws_image_url'].toString().isNotEmpty
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(
                              OakeyTheme.radiusS,
                            ),
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
                  const SizedBox(width: 16),

                  // 우측 정보 영역
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          wsCategory.isEmpty ? '-' : wsCategory,
                          style: textTheme.labelSmall?.copyWith(
                            color: OakeyTheme.textHint,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          wsNameKo,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: OakeyTheme.textMain,
                          ),
                        ),
                        if (wsNameEn.isNotEmpty) ...[
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
                        _buildRatingRow(wsRating, textTheme),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 6,
                          runSpacing: 4,
                          children: flavorTags.map((tag) {
                            final bool isHighlighted = widget.highlightFilters
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
