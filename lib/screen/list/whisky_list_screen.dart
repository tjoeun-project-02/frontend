import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../Directory/core/theme.dart';
import '../../widgets/oakey_components.dart';
import '../../widgets/whisky_card.dart';
import '../../widgets/search_bar.dart';
import 'whisky_detail_screen.dart';
import '../../controller/whisky_controller.dart';

class WhiskyListScreen extends StatelessWidget {
  WhiskyListScreen({super.key});

  // 컨트롤러 주입
  final WhiskyController controller = Get.put(WhiskyController());

  // 필터 옵션들
  final List<String> categoryOptions = [
    'Single Malt',
    'Blended',
    'Bourbon',
    'Japanese',
    'Rye',
    'Irish',
  ];

  final List<String> flavorFilterOptions = [
    'Honey',
    'Vanilla',
    'Peat Smoke',
    'Sherry',
    'Smoky',
    'Spicy',
    'Fruit',
    'Medicinal',
  ];

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: OakeyTheme.backgroundMain,
      appBar: null,
      body: SafeArea(
        child: Column(
          children: [
            // 검색바 영역
            OakeySearchBar(
              controller: controller.searchController,
              onSubmitted: (_) => controller.loadData(),
              onChanged: (val) {
                if (val.isEmpty) controller.loadData();
              },
            ),

            // 선택된 필터 표시 영역
            Obx(() => _buildFixedFilterArea(context)),

            // 위스키 카드 리스트 영역
            Expanded(
              child: Obx(() {
                // 로딩 중이고 데이터가 없으면 스피너 표시
                if (controller.isLoading.value && controller.whiskies.isEmpty) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: OakeyTheme.primaryDeep,
                    ),
                  );
                }

                // 데이터가 아예 없으면 텅 빈 화면 표시
                if (controller.whiskies.isEmpty) {
                  return _buildEmptyState(textTheme);
                }

                return RefreshIndicator(
                  onRefresh: () => controller.loadData(),
                  color: OakeyTheme.primaryDeep,
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: controller.whiskies.length,
                    itemBuilder: (context, index) {
                      final item = controller.whiskies[index];

                      // Obx로 감싸서 좋아요 상태 실시간 반영
                      return Obx(() {
                        // 컨트롤러의 찜 목록에 이 위스키 ID가 있는지 확인
                        final isLiked = controller.isLiked(item.wsId);

                        return WhiskyListCard(
                          // 모델 데이터를 카드 위젯 Map 형식으로 변환
                          whisky: {
                            'ws_id': item.wsId,
                            'ws_distillery': item.wsDistillery,
                            'ws_name': item.wsNameKo,
                            'ws_name_en': item.wsName,
                            'ws_category': item.wsCategory,
                            'ws_rating': item.wsRating,
                            'is_liked': isLiked,
                            'ws_image_url': item.wsImage,
                            'flavor_tags': item.tags.take(3).toList(),
                          },
                          highlightFilters: controller.selectedFilters,
                          // 부모(컨트롤러)의 상태를 카드에 전달
                          isFavorite: isLiked,
                          onTap: () =>
                              Get.to(() => WhiskyDetailScreen(whisky: item)),
                        );
                      });
                    },
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  // 검색 결과 없음 화면
  Widget _buildEmptyState(TextTheme textTheme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.sentiment_dissatisfied_rounded,
            size: 64,
            color: OakeyTheme.textHint.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            '찾으시는 위스키가 없습니다.',
            style: textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w600,
              color: OakeyTheme.textHint,
            ),
          ),
        ],
      ),
    );
  }

  // 필터 버튼과 선택된 칩 영역
  Widget _buildFixedFilterArea(BuildContext context) {
    final sortedFilters = controller.selectedFilters.toList()
      ..sort((a, b) {
        bool isACat = categoryOptions.contains(a);
        bool isBCat = categoryOptions.contains(b);
        if (isACat && !isBCat) return -1;
        if (!isACat && isBCat) return 1;
        return 0;
      });

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 10, 0, 20),
      child: Row(
        children: [
          _buildFilterTrigger(context),
          const SizedBox(width: 16),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: sortedFilters.map((filter) {
                  final isCategory = categoryOptions.contains(filter);
                  return _buildSelectedChip(filter, isCategory);
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 필터 모달 열기 버튼
  Widget _buildFilterTrigger(BuildContext context) {
    final int count = controller.selectedFilters.length;
    return GestureDetector(
      onTap: () => _showFilterModal(context),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: OakeyTheme.primaryDeep,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Row(
              children: [
                Icon(Icons.tune, color: Colors.white, size: 16),
                SizedBox(width: 4),
                Text(
                  '필터',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: OakeyTheme.fontSizeS,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          if (count > 0)
            Positioned(
              top: -10,
              right: -12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: OakeyTheme.accentOrange,
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: OakeyTheme.surfacePure, width: 2),
                ),
                child: Text(
                  count.toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // 선택된 필터 칩
  Widget _buildSelectedChip(String label, bool isCategory) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isCategory
            ? OakeyTheme.accentOrange.withOpacity(0.1)
            : OakeyTheme.surfaceMuted,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Text(
            label,
            style: TextStyle(
              color: isCategory ? OakeyTheme.primaryDeep : OakeyTheme.textSub,
              fontWeight: FontWeight.w800,
              fontSize: 13,
            ),
          ),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: () {
              controller.selectedFilters.remove(label);
              controller.loadData();
            },
            child: Icon(
              Icons.close,
              size: 16,
              color: isCategory ? OakeyTheme.accentOrange : OakeyTheme.textHint,
            ),
          ),
        ],
      ),
    );
  }

  void _showFilterModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: BoxDecoration(
          color: OakeyTheme.surfacePure,
          borderRadius: OakeyTheme.brPanel,
        ),
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: OakeyTheme.borderLine,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  _buildModalSection(
                    context,
                    'CATEGORY',
                    categoryOptions,
                    isSingleSelect: true,
                  ),
                  _buildModalSection(context, 'FLAVOR', flavorFilterOptions),
                ],
              ),
            ),
            _buildModalActionButtons(context),
          ],
        ),
      ),
    );
  }

  Widget _buildModalSection(
    BuildContext context,
    String title,
    List<String> options, {
    bool isSingleSelect = false,
  }) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: OakeyTheme.primarySoft,
          ),
        ),
        const SizedBox(height: 16),
        Obx(() {
          final bool hasAnySelected = options.any(
            (opt) => controller.selectedFilters.contains(opt),
          );

          return Wrap(
            spacing: 12,
            runSpacing: 12,
            children: options.map((option) {
              final isSelected = controller.selectedFilters.contains(option);
              final bool isDisabled =
                  isSingleSelect && hasAnySelected && !isSelected;

              return GestureDetector(
                onTap: () {
                  if (isDisabled) return;
                  controller.toggleFilter(
                    option,
                    isSingleSelect: isSingleSelect,
                    options: options,
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? OakeyTheme.primaryDeep
                        : (isDisabled ? Colors.grey[100] : Colors.white),
                    borderRadius: BorderRadius.circular(OakeyTheme.radiusS),
                    border: Border.all(
                      color: isSelected
                          ? OakeyTheme.primaryDeep
                          : (isDisabled
                                ? Colors.grey[300]!
                                : OakeyTheme.borderLine.withOpacity(0.6)),
                    ),
                  ),
                  child: Text(
                    option,
                    style: textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: isSelected
                          ? Colors.white
                          : (isDisabled
                                ? Colors.grey[400]
                                : OakeyTheme.textMain),
                    ),
                  ),
                ),
              );
            }).toList(),
          );
        }),
        const SizedBox(height: 32),
      ],
    );
  }

  Widget _buildModalActionButtons(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 48),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: OakeyButton(
              onPressed: () => controller.selectedFilters.clear(),
              type: OakeyButtonType.secondary,
              size: OakeyButtonSize.large,
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.refresh_rounded, size: 20),
                  SizedBox(width: 4),
                  Text('초기화', style: TextStyle(fontWeight: FontWeight.w800)),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 3,
            child: OakeyButton(
              onPressed: () {
                Get.back();
                controller.loadData();
              },
              type: OakeyButtonType.primary,
              size: OakeyButtonSize.large,
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.search_rounded, size: 20),
                  SizedBox(width: 4),
                  Text('검색하기', style: TextStyle(fontWeight: FontWeight.w800)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
