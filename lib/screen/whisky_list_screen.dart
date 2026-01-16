import 'package:flutter/material.dart';
import '../Directory/core/theme.dart'; // [테마]: 전역 스타일 경로
import '../widgets/oakey_components.dart';
import '../widgets/oakey_bottom_bar.dart';

class WhiskyListScreen extends StatefulWidget {
  const WhiskyListScreen({super.key});

  @override
  State<WhiskyListScreen> createState() => _WhiskyListScreenState();
}

class _WhiskyListScreenState extends State<WhiskyListScreen> {
  int _currentIndex = 1; // [상태]: 리스트 탭 활성화
  Set<String> selectedFilters = {}; // [상태]: 선택된 필터 저장소

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
          _buildSearchBar(), // [상단]: 검색창 영역
          _buildFixedFilterArea(), // [중단]: 고정 필터 버튼 + 스크롤 태그 영역
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: 5,
              itemBuilder: (context, index) =>
                  const _WhiskyListCard(), // [하단]: 상세 카드 리스트
            ),
          ),
        ],
      ),
      bottomNavigationBar: OakeyBottomBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
      ),
    );
  }

  // [레이아웃]: 필터 버튼은 고정하고 태그만 스크롤되는 영역
  Widget _buildFixedFilterArea() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        20,
        10,
        0,
        20,
      ), // 우측 패딩은 0으로 설정 (스크롤 밀착)
      child: Row(
        children: [
          _buildFilterTrigger(), // [고정]: 필터 버튼은 Row의 첫 번째 자식으로 고정
          const SizedBox(width: 10),
          Expanded(
            // [스크롤]: 나머지 공간에서 태그들만 가로 스크롤
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

  // [부품]: 필터 모달을 여는 갈색 버튼
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

  // [부품]: 선택된 필터 태그 (X 버튼 포함)
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

  // [기능]: 필터 모달 (디자인 코드 포함)
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

  // [모달부품]: 섹션 타이틀 및 칩 나열
  // [수정된 모달 섹션]: 필터 선택 칩 스타일 변경
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
            color: OakeyTheme.textSub, // 섹션 타이틀 색상
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
                setModalState(() {}); // 모달 내부 UI 즉시 갱신
              },
              child: Container(
                // [크기]: 버튼 Medium 사이즈 느낌을 위해 패딩 설정
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  // [배경색]: 선택 안됐을 때 #f5f5f5, 선택 시 딥브라운
                  color: isSelected
                      ? OakeyTheme.primaryDeep
                      : const Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.circular(12), // 둥근 모서리
                ),
                child: Text(
                  option,
                  style: TextStyle(
                    fontSize: 14, // Medium 사이즈 폰트
                    fontWeight: FontWeight.w600,
                    // [글자색]: 선택 안됐을 때 textSub, 선택 시 화이트
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

  // [수정된 모달 하단 버튼]: 초기화 버튼 스타일 변경
  // [수정된 모달 하단 버튼]: 우리가 만든 OakeyButton 전역 스타일 적용
  Widget _buildModalActionButtons(Function setModalState) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 40),
      child: Row(
        children: [
          // 1. 초기화 버튼: 연베이지 배경 + 브라운 글씨 스타일
          Expanded(
            flex: 1,
            child: OakeyButton(
              text: '초기화',
              type: OakeyButtonType.secondary, // 우리가 정의한 연베이지 스타일
              size: OakeyButtonSize.large, // 높이 58px 대형 사이즈
              onPressed: () {
                setState(() => selectedFilters.clear());
                setModalState(() {});
              },
            ),
          ),
          const SizedBox(width: 12),
          // 2. 찾아 보기 버튼: 딥브라운 배경 + 화이트 글씨 스타일
          Expanded(
            flex: 2,
            child: OakeyButton(
              text: '검색',
              type: OakeyButtonType.primary, // 우리가 정의한 딥브라운 스타일
              size: OakeyButtonSize.large, // 동일한 높이 58px
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ],
      ),
    );
  }

  // [부품]: 상단 검색바
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

// [위젯]: 위스키 상세 카드
class _WhiskyListCard extends StatelessWidget {
  const _WhiskyListCard();
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
          Container(
            width: 90,
            height: 90,
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
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'SPEYSIDE',
                      style: TextStyle(
                        color: OakeyTheme.textHint,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Icon(
                      Icons.favorite_border,
                      color: OakeyTheme.textHint,
                      size: 22,
                    ),
                  ],
                ),
                const Text(
                  '발베니 12년 더블우드',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: OakeyTheme.textMain,
                  ),
                ),
                const Text(
                  'The Balvenie 12Y',
                  style: TextStyle(fontSize: 12, color: OakeyTheme.textHint),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    _buildSmallTag('Honey'),
                    const SizedBox(width: 6),
                    _buildSmallTag('Vanilla'),
                    const SizedBox(width: 6),
                    _buildSmallTag('Sweet'),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSmallTag(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFF9F1E9),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 12,
          color: OakeyTheme.accentOrange,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
