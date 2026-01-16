import 'package:flutter/material.dart';
import '../../Directory/core/theme.dart';
import '../../widgets/oakey_components.dart';
import '../../widgets/oakey_bottom_bar.dart';

class WhiskyDetailScreen extends StatefulWidget {
  final Map<String, dynamic> whiskyData;

  const WhiskyDetailScreen({super.key, required this.whiskyData});

  @override
  State<WhiskyDetailScreen> createState() => _WhiskyDetailScreenState();
}

class _WhiskyDetailScreenState extends State<WhiskyDetailScreen> {
  final TextEditingController _noteController = TextEditingController();

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: OakeyTheme.backgroundMain,
      // [수정]: AppBar를 제거하고 body에서 직접 상단 UI를 구현합니다.
      body: SafeArea(
        // 기기 상단 노치 영역을 보호합니다.
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // [추가]: 앱바 대신 커스텀 상단 헤더 영역 (흰색 배경 유지)
              Container(
                color: Colors.white,
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(
                  20,
                  10,
                  20,
                  40,
                ), // 좌우상하 패딩 적용
                child: Column(
                  children: [
                    // 커스텀 상단 바 (뒤로가기 버튼 + 로고)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          icon: const Icon(
                            Icons.arrow_back_ios_new,
                            color: OakeyTheme.primaryDeep,
                            size: 20,
                          ),
                          onPressed: () => Navigator.pop(context),
                        ),
                        Text(
                          'Oakey',
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(width: 20), // 우측 균형을 위한 더미 공간
                      ],
                    ),
                    const SizedBox(height: 30),
                    _buildProductImage(widget.whiskyData['imageUrl']), // 제품 이미지
                    const SizedBox(height: 32),
                    _buildProductTitle(
                      context,
                      widget.whiskyData['name'],
                      widget.whiskyData['engName'],
                    ), // 제품명
                  ],
                ),
              ),
              const SizedBox(height: 30),

              // 품질 지표 영역부터 회색 배경 시작
              _buildSectionTitle(context, '품질 지표'),
              _buildQualityCard(
                context,
                widget.whiskyData['score']?.toString() ?? '87.42',
                widget.whiskyData['votes']?.toString() ?? '1,245',
              ),
              const SizedBox(height: 32),

              _buildInfoGrid(context, widget.whiskyData),
              const SizedBox(height: 16),

              _buildSectionTitle(context, 'Flavor Tags'),
              _buildFlavorDescription(context),
              _buildFlavorTags(
                widget.whiskyData['flavorTags'] as List? ??
                    ['Honey 50%', 'Vanilla 20%', 'Oak 13%'],
              ),
              const SizedBox(height: 48),

              _buildTastingNoteHeader(context),
              _buildTastingNoteInputBox(), // 실시간 입력 박스
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
      bottomNavigationBar: OakeyBottomBar(
        currentIndex: 1,
        onTap: (index) {
          if (index != 1) Navigator.pop(context);
        },
      ),
    );
  }

  // 테이스팅 노트 입력 박스 위젯
  Widget _buildTastingNoteInputBox() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: OakeyTheme.surfacePure,
        borderRadius: BorderRadius.circular(20),
        boxShadow: OakeyTheme.cardShadow,
      ),
      child: TextField(
        controller: _noteController,
        maxLines: 4,
        decoration: InputDecoration(
          hintText: '나만의 테이스팅 노트를 작성하세요.',
          hintStyle: TextStyle(color: OakeyTheme.textHint, fontSize: 14),
          border: InputBorder.none,
        ),
      ),
    );
  }

  // 이미지 섹션 위젯
  Widget _buildProductImage(String? imageUrl) {
    return Container(
      width: 220,
      height: 220,
      decoration: BoxDecoration(
        color: OakeyTheme.surfaceMuted,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Center(
        child: imageUrl != null
            ? Image.network(
                imageUrl,
                width: 100,
                errorBuilder: (c, e, s) => const Icon(
                  Icons.liquor,
                  size: 80,
                  color: OakeyTheme.primarySoft,
                ),
              )
            : const Icon(Icons.liquor, size: 80, color: OakeyTheme.primarySoft),
      ),
    );
  }

  // 제품 타이틀 위젯
  Widget _buildProductTitle(BuildContext context, String name, String engName) {
    return Column(
      children: [
        Text(
          name,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.w900,
            color: OakeyTheme.textMain,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          engName,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: OakeyTheme.textHint),
        ),
      ],
    );
  }

  // 품질 카드 위젯
  Widget _buildQualityCard(BuildContext context, String score, String votes) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: OakeyTheme.surfacePure,
        borderRadius: BorderRadius.circular(24),
        boxShadow: OakeyTheme.cardShadow,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Whiskybase Score',
                style: Theme.of(
                  context,
                ).textTheme.labelSmall?.copyWith(color: OakeyTheme.textHint),
              ),
              const SizedBox(height: 4),
              Text(
                score,
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: OakeyTheme.accentOrange.withOpacity(0.9),
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'Votes',
                style: Theme.of(
                  context,
                ).textTheme.labelSmall?.copyWith(color: OakeyTheme.textHint),
              ),
              const SizedBox(height: 8),
              Text(
                '$votes건',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: OakeyTheme.textMain,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 상세 명세 그리드
  Widget _buildInfoGrid(BuildContext context, Map<String, dynamic> data) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
      child: GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 2,
        childAspectRatio: 2.2,
        children: [
          _buildInfoItem(context, 'AGE', data['age'] ?? '-'),
          _buildInfoItem(context, 'DISTILLERY', data['distillery'] ?? '-'),
          _buildInfoItem(
            context,
            'PRICE',
            data['price'] != null ? '${data['price']}원' : '-',
          ),
          _buildInfoItem(context, 'REGION', data['region'] ?? '-'),
        ],
      ),
    );
  }

  Widget _buildInfoItem(BuildContext context, String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: OakeyTheme.textHint,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: OakeyTheme.primaryDeep,
          ),
        ),
      ],
    );
  }

  // 맛 태그 섹션
  Widget _buildFlavorTags(List tags) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Wrap(
        spacing: 10,
        runSpacing: 10,
        children: tags
            .map(
              (tag) => Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: OakeyTheme.accentOrange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  tag.toString(),
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: OakeyTheme.accentOrange,
                  ),
                ),
              ),
            )
            .toList(),
      ),
    );
  }

  // 공통 타이틀 섹션
  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w800,
          color: OakeyTheme.textMain,
        ),
      ),
    );
  }

  Widget _buildFlavorDescription(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      child: Text(
        '위스키와 관련하여 가장 많이 언급되는 기준으로 선정되었습니다',
        style: Theme.of(
          context,
        ).textTheme.bodySmall?.copyWith(color: OakeyTheme.textHint),
      ),
    );
  }

  // 등록 헤더
  Widget _buildTastingNoteHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Tasting Notes',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w800,
              color: OakeyTheme.textMain,
            ),
          ),
          OakeyButton(
            text: '등록하기',
            type: OakeyButtonType.primary,
            size: OakeyButtonSize.medium,
            width: 100,
            onPressed: () {
              print('등록: ${_noteController.text}');
              _noteController.clear();
            },
          ),
        ],
      ),
    );
  }
}
