import 'package:flutter/material.dart';
import '../../Directory/core/theme.dart';
import '../../widgets/oakey_components.dart';

class WhiskyListScreen extends StatefulWidget {
  const WhiskyListScreen({super.key});

  @override
  State<WhiskyListScreen> createState() => _WhiskyListScreenState();
}

class _WhiskyListScreenState extends State<WhiskyListScreen> {
  int _currentIndex = 1; // 하단 바 활성화 상태
  Set<String> selectedFilters = {}; // 선택 필터 저장소

  // 목업 데이터 (isFavorite 상태 포함)
  final List<Map<String, dynamic>> whiskies = [
    {
      'id': '1',
      'region': 'SPEYSIDE',
      'name': '발베니 12년 더블우드',
      'engName': 'The Balvenie 12Y',
      'isFavorite': false,
      'tags': ['Honey', 'Vanilla', 'Sweet'],
    },
    {
      'id': '2',
      'region': 'HIGHLAND',
      'name': '맥캘란 12년 쉐리오크',
      'engName': 'Macallan 12Y Sherry Oak',
      'isFavorite': true,
      'tags': ['Dried Fruit', 'Spice'],
    },
  ];

  // ID 기반 좋아요 토글 함수
  void _toggleFavoriteById(String id) {
    setState(() {
      final idx = whiskies.indexWhere((w) => w['id'] == id);
      if (idx != -1) {
        whiskies[idx]['isFavorite'] = !(whiskies[idx]['isFavorite'] as bool);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: OakeyTheme.backgroundMain,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Oakey'),
        centerTitle: false,
      ),
      body: Column(
        children: [
          _buildSearchBar(), // 검색창 호출
          _buildFixedFilterArea(), // 필터 영역 호출
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: whiskies.length,
              itemBuilder: (context, index) {
                final whisky = whiskies[index];
                return _WhiskyListCard(
                  data: whisky,
                  onFavoriteTap: () => _toggleFavoriteById(whisky['id']),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // 필터 버튼 고정 및 태그 스크롤 영역
  Widget _buildFixedFilterArea() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 0, 20),
      child: Row(
        children: [
          _buildFilterTrigger(),
          const SizedBox(width: 10),
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

  // 필터 모달 창 호출
  void _showFilterModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.7,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 12),
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.all(24),
                      children: [
                        _buildModalSection('CATEGORY', [
                          '싱글몰트',
                          '블렌디드',
                          '버번',
                          '라이',
                        ], setModalState),
                        _buildModalSection('PRICE', [
                          '~ 5만',
                          '5~10만',
                          '10~20만',
                          '20~30만',
                        ], setModalState),
                        _buildModalSection('FLAVOR', [
                          '달달한',
                          '스모키',
                          '과일향',
                          '바닐라',
                        ], setModalState),
                      ],
                    ),
                  ),
                  _buildModalActionButtons(setModalState),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // 모달 내부 필터 선택 섹션
  Widget _buildModalSection(
    String title,
    List<String> options,
    Function setModalState,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: OakeyTheme.textSub,
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: options.map((option) {
            final isSelected = selectedFilters.contains(option);
            return GestureDetector(
              onTap: () {
                setState(() {
                  isSelected
                      ? selectedFilters.remove(option)
                      : selectedFilters.add(option);
                });
                setModalState(() {});
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? OakeyTheme.primaryDeep
                      : const Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  option,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isSelected ? Colors.white : OakeyTheme.textSub,
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

  // 모달 하단 버튼 영역
  Widget _buildModalActionButtons(Function setModalState) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 40),
      child: Row(
        children: [
          Expanded(
            flex: 1,
            child: OakeyButton(
              text: '초기화',
              type: OakeyButtonType.secondary,
              size: OakeyButtonSize.large,
              onPressed: () {
                setState(() => selectedFilters.clear());
                setModalState(() {});
              },
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: OakeyButton(
              text: '검색',
              type: OakeyButtonType.primary,
              size: OakeyButtonSize.large,
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ],
      ),
    );
  }

  // 필터 실행 버튼
  Widget _buildFilterTrigger() {
    return GestureDetector(
      onTap: _showFilterModal,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: OakeyTheme.primaryDeep,
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Row(
          children: [
            Icon(Icons.tune, color: Colors.white, size: 16),
            SizedBox(width: 6),
            Text(
              '필터',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 선택된 필터 태그
  Widget _buildSelectedChip(String label) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFE5DCD3),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 13, color: OakeyTheme.textMain),
          ),
          const SizedBox(width: 6),
          GestureDetector(
            onTap: () => setState(() => selectedFilters.remove(label)),
            child: const Icon(Icons.close, size: 14, color: OakeyTheme.textSub),
          ),
        ],
      ),
    );
  }

  // 검색바 영역
  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Container(
        decoration: BoxDecoration(boxShadow: OakeyTheme.cardShadow),
        child: TextField(
          decoration: InputDecoration(
            hintText: '검색어를 입력하세요',
            prefixIcon: const Icon(Icons.search, color: OakeyTheme.textHint),
            suffixIcon: Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFE5DCD3),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.camera_alt,
                color: OakeyTheme.primarySoft,
                size: 20,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// 개별 위스키 정보 표시 카드 (최적화 버전)
class _WhiskyListCard extends StatelessWidget {
  final Map<String, dynamic> data;
  final VoidCallback onFavoriteTap;

  const _WhiskyListCard({required this.data, required this.onFavoriteTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: OakeyTheme.surfacePure,
        borderRadius: BorderRadius.circular(24),
        boxShadow: OakeyTheme.cardShadow,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 이미지 영역 (정중앙 배치 추가)
          Container(
            width: 90,
            height: 90,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: const Color(0xFFF1EAE4),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.liquor,
              size: 40,
              color: OakeyTheme.primarySoft,
            ),
          ),
          const SizedBox(width: 16),
          // 정보 영역 (오버플로우 방지)
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      data['region'],
                      style: const TextStyle(
                        color: OakeyTheme.textHint,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    // 터치 영역 및 정렬 최적화
                    IconButton(
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      visualDensity: VisualDensity.compact,
                      onPressed: onFavoriteTap,
                      icon: Icon(
                        data['isFavorite']
                            ? Icons.favorite
                            : Icons.favorite_border,
                        color: data['isFavorite']
                            ? Colors.red
                            : OakeyTheme.textHint,
                        size: 22,
                      ),
                    ),
                  ],
                ),
                // 이름 말줄임표 처리 필수
                Text(
                  data['name'],
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: OakeyTheme.textMain,
                  ),
                ),
                Text(
                  data['engName'],
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    color: OakeyTheme.textHint,
                  ),
                ),
                const SizedBox(height: 10),
                // 태그 줄바꿈 자동 처리
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: (data['tags'] as List)
                      .map((tag) => _buildSmallTag(tag.toString()))
                      .toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 소형 태그 위젯 (디자인 시안 최적화)
  Widget _buildSmallTag(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: OakeyTheme.accentOrange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 11,
          color: OakeyTheme.accentOrange,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
