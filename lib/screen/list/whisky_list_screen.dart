import 'package:flutter/material.dart';
import '../../Directory/core/theme.dart';
import '../../widgets/oakey_components.dart';
import '../../widgets/whisky_card.dart';
import '../../widgets/search_bar.dart';
import 'whisky_detail_screen.dart';

class WhiskyListScreen extends StatefulWidget {
  const WhiskyListScreen({super.key});

  @override
  State<WhiskyListScreen> createState() => _WhiskyListScreenState();
}

class _WhiskyListScreenState extends State<WhiskyListScreen> {
  // 검색어 입력 컨트롤러
  final TextEditingController _searchController = TextEditingController();

  // 선택된 필터 목록
  Set<String> selectedFilters = {};

  // 카테고리 필터 기준 목록
  final List<String> categoryOptions = [
    '싱글몰트',
    '블렌디드',
    '버번',
    '라이',
    '아이리시',
    '재패니즈',
    '캐나디안',
    '테네시',
  ];

  // 위스키 목록 데이터
  final List<Map<String, dynamic>> whiskies = [
    {
      'ws_id': 1,
      'ws_distillery': 'SPEYSIDE',
      'ws_name': '발베니 12년 더블우드',
      'ws_name_en': 'The Balvenie 12Y',
      'ws_category': '싱글몰트',
      'ws_rating': 4.5,
      'is_liked': false,
      'flavor_tags': ['달콤한', '바닐라', '오크향'],
    },
    {
      'ws_id': 2,
      'ws_distillery': 'HIGHLAND',
      'ws_name': '맥캘란 12년 쉐리오크',
      'ws_name_en': 'Macallan 12Y Sherry Oak',
      'ws_category': '싱글몰트',
      'ws_rating': 4.8,
      'is_liked': true,
      'flavor_tags': ['과일향', '달콤한', '스파이시'],
    },
    {
      'ws_id': 3,
      'ws_distillery': 'ISLAY',
      'ws_name': '라가불린 16년',
      'ws_name_en': 'Lagavulin 16Y',
      'ws_category': '싱글몰트',
      'ws_rating': 4.9,
      'is_liked': false,
      'flavor_tags': ['피티(Peaty)', '스모키', '오크향'],
    },
  ];

  // 검색어와 필터로 노출 목록 계산
  List<Map<String, dynamic>> get filteredWhiskies {
    final String searchText = _searchController.text.toLowerCase();

    return whiskies.where((whisky) {
      final String wsName = whisky['ws_name'].toString().toLowerCase();
      final bool matchesSearch =
          searchText.isEmpty || wsName.contains(searchText);

      final selectedCategories = selectedFilters
          .where((f) => categoryOptions.contains(f))
          .toList();
      final selectedFlavors = selectedFilters
          .where((f) => !categoryOptions.contains(f))
          .toList();

      final bool matchesCategory =
          selectedCategories.isEmpty ||
          selectedCategories.contains(whisky['ws_category']);

      final flavors = List<String>.from(whisky['flavor_tags'] ?? []);
      final bool matchesFlavor =
          selectedFlavors.isEmpty ||
          selectedFlavors.any((f) => flavors.contains(f));

      return matchesSearch && matchesCategory && matchesFlavor;
    }).toList();
  }

  // 찜 상태 토글 처리
  void _toggleFavoriteById(int id) {
    setState(() {
      final idx = whiskies.indexWhere((w) => w['ws_id'] == id);
      if (idx != -1) {
        whiskies[idx]['is_liked'] = !(whiskies[idx]['is_liked'] as bool);
      }
    });
  }

  @override
  void dispose() {
    // 검색 컨트롤러 해제
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 현재 테마 텍스트 스타일 참조
    final textTheme = Theme.of(context).textTheme;

    // 현재 조건에 맞는 리스트만 노출
    final displayList = filteredWhiskies;

    return Scaffold(
      backgroundColor: OakeyTheme.backgroundMain,
      appBar: null,
      body: SafeArea(
        child: Column(
          children: [
            // 검색창 영역
            OakeySearchBar(
              controller: _searchController,
              onChanged: (_) => setState(() {}),
            ),

            // 선택된 필터 표시 영역
            _buildFixedFilterArea(),

            // 위스키 카드 리스트 영역
            Expanded(
              child: displayList.isEmpty
                  ? _buildEmptyState(textTheme)
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: displayList.length,
                      itemBuilder: (context, index) {
                        final whisky = displayList[index];
                        return WhiskyListCard(
                          whisky: whisky,
                          highlightFilters: selectedFilters,
                          onFavoriteTap: () =>
                              _toggleFavoriteById(whisky['ws_id'] as int),
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  WhiskyDetailScreen(whiskyData: whisky),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  // 검색 결과가 없을 때 표시 화면
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
  Widget _buildFixedFilterArea() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 10, 0, 20),
      child: Row(
        children: [
          // 필터 모달 열기 버튼
          _buildFilterTrigger(),
          const SizedBox(width: 16),

          // 선택된 필터 칩 스크롤 영역
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: selectedFilters
                    .map((filter) => _buildSelectedChip(filter))
                    .toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 필터 선택 모달 표시
  void _showFilterModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.8,
              decoration: BoxDecoration(
                color: OakeyTheme.surfacePure,
                borderRadius: OakeyTheme.brPanel,
              ),
              child: Column(
                children: [
                  const SizedBox(height: 12),

                  // 모달 상단 핸들바
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: OakeyTheme.borderLine,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),

                  // 모달 필터 옵션 리스트
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.all(20),
                      children: [
                        // 카테고리 단일 선택 섹션
                        _buildModalSection(
                          'CATEGORY',
                          categoryOptions,
                          setModalState,
                          isSingleSelect: true,
                        ),

                        // 맛 태그 다중 선택 섹션
                        _buildModalSection('FLAVOR', [
                          '달콤한',
                          '스모키',
                          '피티(Peaty)',
                          '과일향',
                          '바닐라',
                          '스파이시',
                        ], setModalState),
                      ],
                    ),
                  ),

                  // 모달 하단 액션 버튼 영역
                  _buildModalActionButtons(setModalState),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // 필터 모달 내 옵션 섹션
  Widget _buildModalSection(
    String title,
    List<String> options,
    Function setModalState, {
    bool isSingleSelect = false,
  }) {
    // 카테고리 선택 여부 확인
    final bool hasCategorySelected = selectedFilters.any(
      (f) => categoryOptions.contains(f),
    );

    // 현재 테마 텍스트 스타일 참조
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 섹션 타이틀 텍스트
        Text(
          title,
          style: textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: OakeyTheme.primarySoft,
          ),
        ),
        const SizedBox(height: 16),

        // 옵션 버튼 래핑 영역
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: options.map((option) {
            final isSelected = selectedFilters.contains(option);
            final bool isDisabled =
                isSingleSelect && hasCategorySelected && !isSelected;

            return GestureDetector(
              onTap: () {
                setState(() {
                  if (isSingleSelect) {
                    if (isSelected) {
                      selectedFilters.remove(option);
                    } else {
                      selectedFilters.removeWhere((f) => options.contains(f));
                      selectedFilters.add(option);
                    }
                  } else {
                    isSelected
                        ? selectedFilters.remove(option)
                        : selectedFilters.add(option);
                  }
                });
                setModalState(() {});
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
                    width: 1,
                  ),
                  boxShadow: isSelected
                      ? null
                      : [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.02),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                ),
                child: Text(
                  option,
                  style: textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: isSelected
                        ? Colors.white
                        : (isDisabled ? Colors.grey[400] : OakeyTheme.textMain),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 32),
      ],
    );
  }

  // 필터 모달 하단 버튼 영역
  Widget _buildModalActionButtons(Function setModalState) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 48),
      child: Row(
        children: [
          // 필터 초기화 버튼
          Expanded(
            flex: 2,
            child: OakeyButton(
              onPressed: () {
                setState(() => selectedFilters.clear());
                setModalState(() {});
              },
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

          // 필터 적용 버튼
          Expanded(
            flex: 3,
            child: OakeyButton(
              onPressed: () => Navigator.pop(context),
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

  // 필터 모달 열기 버튼
  Widget _buildFilterTrigger() {
    final int count = selectedFilters.length;

    return GestureDetector(
      onTap: _showFilterModal,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // 필터 버튼 본문
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

          // 선택 개수 배지
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

  // 선택된 필터 칩 위젯
  Widget _buildSelectedChip(String label) {
    // 현재 테마 텍스트 스타일 참조
    final textTheme = Theme.of(context).textTheme;

    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: OakeyTheme.surfaceMuted,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Text(
            label,
            style: textTheme.labelMedium?.copyWith(
              color: OakeyTheme.textSub,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: () => setState(() => selectedFilters.remove(label)),
            child: const Icon(
              Icons.close,
              size: 16,
              color: OakeyTheme.textHint,
            ),
          ),
        ],
      ),
    );
  }
}
