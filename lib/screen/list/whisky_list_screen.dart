import 'package:flutter/material.dart';
import '../../Directory/core/theme.dart';
import '../../widgets/oakey_components.dart';
// ✅ 1. 반드시 이 import가 있어야 WhiskyListCard를 인식합니다.
import '../../widgets/whisky_card.dart';
import 'whisky_detail_screen.dart';

class WhiskyListScreen extends StatefulWidget {
  const WhiskyListScreen({super.key});

  @override
  State<WhiskyListScreen> createState() => _WhiskyListScreenState();
}

class _WhiskyListScreenState extends State<WhiskyListScreen> {
  Set<String> selectedFilters = {};

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
          _buildSearchBar(),
          _buildFixedFilterArea(),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: whiskies.length,
              itemBuilder: (context, index) {
                final whisky = whiskies[index];

                return WhiskyListCard(
                  whisky: whisky,
                  onFavoriteTap: () =>
                      _toggleFavoriteById(whisky['id'] as String),
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
    );
  }

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
}
