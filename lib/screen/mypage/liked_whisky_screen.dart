import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:convert';
import '../../Directory/core/theme.dart';
import '../../widgets/oakey_detail_app_bar.dart';
import '../list/whisky_detail_screen.dart';
import '../../models/whisky.dart';
import '../../services/api_service.dart';
import '../../controller/user_controller.dart';
import '../../controller/whisky_controller.dart';

class LikedWhiskyScreen extends StatefulWidget {
  const LikedWhiskyScreen({super.key});

  @override
  State<LikedWhiskyScreen> createState() => _LikedWhiskyScreenState();
}

class _LikedWhiskyScreenState extends State<LikedWhiskyScreen> {
  final WhiskyController controller = Get.find<WhiskyController>();

  List<Map<String, dynamic>> likedWhiskies = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchLikedWhiskies();
  }

  Future<void> _fetchLikedWhiskies() async {
    setState(() => _isLoading = true);

    int currentUserId = 0;
    try {
      currentUserId = UserController.to.userId.value;
    } catch (e) {
      currentUserId = 0;
    }

    if (currentUserId == 0) {
      setState(() => _isLoading = false);
      return;
    }

    // 서버에서 찜 목록 가져오기
    final list = await ApiService.fetchLikedWhiskies(currentUserId);

    // 컨트롤러 동기화 (앱 켜자마자 들어왔을 경우 대비)
    if (controller.whiskies.isEmpty) {
      await controller.loadData();
    }

    if (mounted) {
      setState(() {
        likedWhiskies = list.map((item) {
          // ★ [핵심 수정] ID 안전하게 파싱 (null 방지)
          final int safeId = int.tryParse(item['wsId']?.toString() ?? '0') ?? 0;

          return {
            'ws_id': safeId,
            'ws_distillery': item['wsDistillery'] ?? '',
            'ws_name': item['wsNameKo'] ?? '',
            'ws_name_en': item['wsName'] ?? '',
            'ws_category': item['wsCategory'] ?? '',
            'ws_rating': item['wsRating'] ?? 0.0,
            'is_liked': true,
            'ws_image_url': item['wsImage'] ?? '',
            'flavor_tags': item['tags'] ?? [],
          };
        }).toList();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: OakeyTheme.backgroundMain,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const OakeyDetailAppBar(),

            // 실시간 갯수 반영
            Obx(
              () => _buildHeader("내가 찜한 위스키", controller.likedWhiskyIds.length),
            ),

            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: OakeyTheme.primaryDeep,
                      ),
                    )
                  : likedWhiskies.isEmpty
                  ? _buildEmptyState("찜한 위스키가 없습니다.")
                  : RefreshIndicator(
                      onRefresh: _fetchLikedWhiskies,
                      color: OakeyTheme.primaryDeep,
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 15,
                        ),
                        itemCount: likedWhiskies.length,
                        itemBuilder: (context, index) {
                          final item = likedWhiskies[index];
                          final int wsId = item['ws_id'];

                          return Obx(() {
                            // 찜 해제 시 즉시 숨김
                            bool isStillLiked = controller.isLiked(wsId);
                            if (!isStillLiked) return const SizedBox.shrink();

                            return _buildSimpleLikedCard(
                              item: item,
                              onTap: () async {
                                // 상세 페이지 이동 로직
                                Whisky? fullData;
                                try {
                                  fullData = controller.whiskies.firstWhere(
                                    (w) => w.wsId == wsId,
                                  );
                                } catch (e) {
                                  fullData = null;
                                }

                                fullData ??= Whisky.fromDbMap({
                                  'wsId': item['ws_id'],
                                  'wsName': item['ws_name_en'],
                                  'wsNameKo': item['ws_name'],
                                  'wsCategory': item['ws_category'],
                                  'wsDistillery': item['ws_distillery'],
                                  'wsImage': item['ws_image_url'],
                                  'wsAbv': 0.0,
                                  'wsAge': 0,
                                  'wsRating': item['ws_rating'],
                                  'wsVoteCnt': 0,
                                  'tags': jsonEncode(item['flavor_tags']),
                                  'tasteProfile': jsonEncode({}),
                                });

                                await Get.to(
                                  () => WhiskyDetailScreen(whisky: fullData!),
                                );
                                _fetchLikedWhiskies();
                              },
                              onLikeTap: () async {
                                await controller.toggleLike(wsId);
                              },
                            );
                          });
                        },
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  // 심플 카드 디자인
  Widget _buildSimpleLikedCard({
    required Map<String, dynamic> item,
    required VoidCallback onTap,
    required VoidCallback onLikeTap,
  }) {
    final String wsNameKo = (item['ws_name'] ?? '이름 없음').toString();
    final String wsNameEn = (item['ws_name_en'] ?? '').toString();
    final String? imageUrl = item['ws_image_url'];

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: OakeyTheme.surfacePure,
          borderRadius: OakeyTheme.brCard,
          boxShadow: OakeyTheme.cardShadow,
        ),
        child: Row(
          children: [
            // 이미지
            Container(
              width: 70,
              height: 70,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: OakeyTheme.surfaceMuted,
                borderRadius: BorderRadius.circular(OakeyTheme.radiusS),
              ),
              child: imageUrl != null && imageUrl.isNotEmpty
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(OakeyTheme.radiusS),
                      child: Image.network(
                        imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const Icon(
                          Icons.liquor,
                          color: OakeyTheme.primarySoft,
                          size: 32,
                        ),
                      ),
                    )
                  : const Icon(
                      Icons.liquor,
                      color: OakeyTheme.primarySoft,
                      size: 32,
                    ),
            ),
            const SizedBox(width: 16),
            // 이름
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    wsNameKo,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: OakeyTheme.fontSizeL,
                      fontWeight: FontWeight.w800,
                      color: OakeyTheme.textMain,
                    ),
                  ),
                  if (wsNameEn.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      wsNameEn,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: OakeyTheme.fontSizeS,
                        color: OakeyTheme.textSub,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            // 하트 버튼
            IconButton(
              onPressed: onLikeTap,
              icon: const Icon(Icons.favorite, color: Colors.red, size: 28),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(String title, int count) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 10),
      child: Row(
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: OakeyTheme.fontSizeXL,
              fontWeight: FontWeight.w800,
              color: OakeyTheme.textMain,
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: OakeyTheme.accentOrange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              count.toString(),
              style: const TextStyle(
                fontSize: OakeyTheme.fontSizeM,
                fontWeight: FontWeight.w600,
                color: OakeyTheme.accentOrange,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.favorite_border_rounded,
            size: 64,
            color: OakeyTheme.textHint.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: OakeyTheme.textHint,
            ),
          ),
        ],
      ),
    );
  }
}
