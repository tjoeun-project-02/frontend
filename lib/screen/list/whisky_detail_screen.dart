import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:get/get.dart';
import '../../Directory/core/theme.dart';
import '../../widgets/oakey_detail_app_bar.dart';

class WhiskyDetailScreen extends StatefulWidget {
  final Map<String, dynamic> whiskyData;

  const WhiskyDetailScreen({super.key, required this.whiskyData});

  @override
  State<WhiskyDetailScreen> createState() => _WhiskyDetailScreenState();
}

class _WhiskyDetailScreenState extends State<WhiskyDetailScreen> {
  final TextEditingController _noteController = TextEditingController();
  final FocusNode _noteFocusNode = FocusNode();

  bool _isNoteSaved = false;
  bool _isEditing = false;

  @override
  void dispose() {
    _noteController.dispose();
    _noteFocusNode.dispose();
    super.dispose();
  }

  void _handleNoteAction() {
    if (!_isNoteSaved) {
      _saveProcess('테이스팅 노트가 등록되었습니다.');
    } else {
      if (!_isEditing) {
        setState(() => _isEditing = true);
        _noteFocusNode.requestFocus();
      } else {
        _saveProcess('수정이 완료되었습니다.');
        setState(() => _isEditing = false);
      }
    }
  }

  void _saveProcess(String message) {
    if (_noteController.text.trim().isEmpty) return;
    FocusScope.of(context).unfocus();
    setState(() => _isNoteSaved = true);

    Get.snackbar(
      _isEditing ? "수정 완료" : "등록 완료",
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: OakeyTheme.primaryDeep.withOpacity(0.8),
      colorText: Colors.white,
      margin: const EdgeInsets.all(20),
      duration: const Duration(seconds: 1),
    );
  }

  void _handleDelete() {
    FocusScope.of(context).unfocus();
    setState(() {
      _noteController.clear();
      _isNoteSaved = false;
      _isEditing = false;
    });

    Get.snackbar(
      "삭제 완료",
      "테이스팅 노트가 삭제되었습니다.",
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: OakeyTheme.primaryDeep.withOpacity(0.8),
      colorText: Colors.white,
      margin: const EdgeInsets.all(20),
      duration: const Duration(seconds: 1),
    );
  }

  void _showTasteHelp(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(OakeyTheme.radiusM),
        ),
        backgroundColor: OakeyTheme.surfacePure,
        title: Text(
          'Taste Guide',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHelpItem('Sweet', '설탕이나 꿀, 카라멜 같은 달콤한 풍미'),
            _buildHelpItem('Fruit', '사과나 건포도 같은 상큼달콤한 과일 향'),
            _buildHelpItem('Spicy', '시나몬이나 후추처럼 톡 쏘는 자극'),
            _buildHelpItem('Woody', '숙성된 나무통에서 배어 나온 묵직한 향'),
            _buildHelpItem('Smoky', '장작 타는 냄새나 훈제 요리의 스모키함'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              '확인',
              style: TextStyle(
                color: OakeyTheme.primaryDeep,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHelpItem(String title, String desc) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: OakeyTheme.accentOrange,
              fontSize: OakeyTheme.fontSizeM,
            ),
          ),
          Text(
            desc,
            style: const TextStyle(
              color: OakeyTheme.textSub,
              fontSize: OakeyTheme.fontSizeS,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final String name = (widget.whiskyData['ws_name'] ?? 'Unknown').toString();
    final String enName = (widget.whiskyData['ws_name_en'] ?? '').toString();
    final String category = (widget.whiskyData['ws_category'] ?? '-')
        .toString();
    final String distillery = (widget.whiskyData['ws_distillery'] ?? '-')
        .toString();
    final String ageText = widget.whiskyData['ws_age'] == null
        ? '-'
        : '${widget.whiskyData['ws_age']}Y';
    final String abvText = widget.whiskyData['ws_abv'] == null
        ? '-'
        : '${widget.whiskyData['ws_abv']}%';
    final double rating =
        double.tryParse(widget.whiskyData['ws_rating']?.toString() ?? '0.0') ??
        0.0;
    final int voteCnt =
        int.tryParse(widget.whiskyData['ws_vote_cnt']?.toString() ?? '0') ?? 0;
    final List<String> flavors = List<String>.from(
      widget.whiskyData['flavor_tags'] ?? [],
    );

    return Scaffold(
      backgroundColor: OakeyTheme.backgroundMain,
      body: SafeArea(
        child: Column(
          children: [
            const OakeyDetailAppBar(),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    // 1. 메인 정보 (카드 제거, 배경에 직접 배치)
                    _buildMainWhiskyInfo(name, enName),

                    const SizedBox(height: 32),

                    // 구분선 하나 싹 그어주고
                    const Divider(
                      color: Color(0xFFE0E0E0),
                      thickness: 1,
                      indent: 20,
                      endIndent: 20,
                    ),

                    const SizedBox(height: 32),

                    // 2. 품질 지표 (★이것만 카드로 유지★)
                    _buildSectionTitle(context, 'Quality Metrics'),
                    _buildQualityCard(
                      context,
                      score: rating.toStringAsFixed(2),
                      votes: voteCnt,
                    ),

                    const SizedBox(height: 40),

                    // 3. 상세 정보 (카드 제거, 투명 그리드)
                    _buildSectionTitle(context, 'Information'),
                    _buildInfoGrid(
                      context,
                      items: [
                        _InfoItem(label: 'AGE (숙성 연수)', value: ageText),
                        _InfoItem(label: 'DISTILLERY (증류소)', value: distillery),
                        _InfoItem(label: 'CATEGORY (종류)', value: category),
                        _InfoItem(label: 'ABV (도수)', value: abvText),
                      ],
                    ),

                    const SizedBox(height: 40),

                    // 4. 플레이버 태그 (카드 제거)
                    _buildSectionTitle(context, 'Flavor Tags'),
                    _buildSectionDesc(context, '위스키와 관련하여 가장 많이 언급되는 기준입니다'),
                    _buildFlavorTags(flavors),

                    const SizedBox(height: 40),

                    // 5. 맛 그래프 (카드 제거, 차트만 덜렁)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildSectionTitle(context, 'Taste Profile'),
                        Padding(
                          padding: const EdgeInsets.only(right: 20, bottom: 8),
                          child: GestureDetector(
                            onTap: () => _showTasteHelp(context),
                            child: const Icon(
                              Icons.help_outline_rounded,
                              color: OakeyTheme.textHint,
                              size: 24,
                            ),
                          ),
                        ),
                      ],
                    ),
                    _buildTasteProfileChart(context),

                    const SizedBox(height: 40),

                    // 6. 테이스팅 노트 입력 (카드 제거, 입력창만 남김)
                    _buildTastingNoteHeader(context),
                    _buildTastingNoteInputBox(context),

                    const SizedBox(height: 50),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 메인 정보: 카드 껍데기 벗기고 텍스트만 깔끔하게 중앙 정렬
  Widget _buildMainWhiskyInfo(String name, String enName) {
    final String? imageUrl = widget.whiskyData['ws_image_url'];
    return Center(
      child: Column(
        children: [
          Container(
            width: 180,
            height: 180,
            decoration: BoxDecoration(
              color: OakeyTheme.surfaceMuted,
              borderRadius: BorderRadius.circular(OakeyTheme.radiusL),
            ),
            child: imageUrl != null && imageUrl.isNotEmpty
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(OakeyTheme.radiusL),
                    child: Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => const Icon(
                        Icons.liquor_rounded,
                        size: 90,
                        color: OakeyTheme.primarySoft,
                      ),
                    ),
                  )
                : const Icon(
                    Icons.liquor_rounded,
                    size: 90,
                    color: OakeyTheme.primarySoft,
                  ),
          ),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              name,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: OakeyTheme.fontSizeL,
                fontWeight: FontWeight.w800,
                color: OakeyTheme.textMain,
                height: 1.3,
              ),
            ),
          ),
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              enName,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: OakeyTheme.fontSizeS,
                color: OakeyTheme.textHint,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 20, bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: OakeyTheme.fontSizeM,
          fontWeight: FontWeight.w800,
          color: OakeyTheme.textMain,
        ),
      ),
    );
  }

  Widget _buildSectionDesc(BuildContext context, String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 20, bottom: 16),
      child: Text(
        text,
        style: const TextStyle(fontSize: 13, color: OakeyTheme.textHint),
      ),
    );
  }

  // ★ 유일하게 살아남은 카드 (품질 지표) ★
  Widget _buildQualityCard(
    BuildContext context, {
    required String score,
    required int votes,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: OakeyTheme.surfacePure,
        borderRadius: OakeyTheme.brCard,
        border: Border.all(color: OakeyTheme.borderLine.withOpacity(0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Whiskybase Score',
                style: Theme.of(
                  context,
                ).textTheme.labelMedium?.copyWith(fontSize: 12),
              ),
              const SizedBox(height: 8),
              Text(
                score,
                style: const TextStyle(
                  fontSize: 42,
                  fontWeight: FontWeight.w900,
                  color: OakeyTheme.accentGold, // 골드/오렌지 포인트
                  height: 1.0,
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
                ).textTheme.labelMedium?.copyWith(fontSize: 12),
              ),
              const SizedBox(height: 8),
              Text(
                '$votes건',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 정보 그리드: 카드 제거, 깔끔한 텍스트 배치
  Widget _buildInfoGrid(
    BuildContext context, {
    required List<_InfoItem> items,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GridView.builder(
        shrinkWrap: true,
        padding: EdgeInsets.zero,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 2.8,
          mainAxisSpacing: 20,
          crossAxisSpacing: 10,
        ),
        itemCount: items.length,
        itemBuilder: (context, index) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              items[index].label,
              style: const TextStyle(
                fontSize: OakeyTheme.fontSizeXS,
                fontWeight: FontWeight.w600,
                color: OakeyTheme.textHint,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              items[index].value,
              style: const TextStyle(
                fontSize: OakeyTheme.fontSizeM,
                fontWeight: FontWeight.w800,
                color: OakeyTheme.primaryDeep,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 플레이버 태그: 배경에 바로 칩 배치
  Widget _buildFlavorTags(List<String> tags) {
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
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: OakeyTheme.accentOrange.withOpacity(
                    0.08,
                  ), // 배경색이랑 어울리는 옅은 베이지
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  tag,
                  style: const TextStyle(
                    fontSize: OakeyTheme.fontSizeS,
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

  // 맛 차트: 카드 제거, 차트만 덩그러니 (네가 원한 대로)
  Widget _buildTasteProfileChart(BuildContext context) {
    final List<double> values = [0.2, 0.6, 0.4, 0.7, 0.9];
    final List<String> labels = ['Sweet', 'Fruit', 'Spicy', 'Woody', 'Smoky'];
    return Center(
      child: CustomPaint(
        size: const Size(220, 220),
        painter: RadarChartPainter(values: values, labels: labels),
      ),
    );
  }

  Widget _buildTastingNoteHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Tasting Note',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
          ),
          Row(
            children: [
              if (_isNoteSaved) ...[
                GestureDetector(
                  onTap: _handleDelete,
                  child: _buildActionButton(
                    Icons.delete_outline_rounded,
                    '삭제',
                    Colors.grey[400]!,
                  ),
                ),
                const SizedBox(width: 8),
              ],
              GestureDetector(
                onTap: _handleNoteAction,
                child: _buildActionButton(
                  !_isNoteSaved
                      ? Icons.add_rounded
                      : (_isEditing
                            ? Icons.check_rounded
                            : Icons.edit_outlined),
                  !_isNoteSaved ? '등록하기' : (_isEditing ? '수정완료' : '수정하기'),
                  OakeyTheme.primaryDeep,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white, size: 16),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  // 입력창: 입력 필드 자체의 박스 디자인은 유지 (안 그러면 글쓰기 힘드니까)
  Widget _buildTastingNoteInputBox(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white, // 입력창은 흰색 유지
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: OakeyTheme.borderLine),
        // 그림자 살짝 빼서 카드 느낌 줄임
      ),
      child: TextField(
        controller: _noteController,
        focusNode: _noteFocusNode,
        minLines: 3,
        maxLines: null,
        style: const TextStyle(height: 1.5),
        decoration: const InputDecoration(
          hintText: '이 위스키의 맛과 향을 기록해보세요.',
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          filled: false,
          isDense: true,
          hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
        ),
      ),
    );
  }
}

// 레이더 차트 페인터랑 정보 모델 클래스는 그대로 유지
class RadarChartPainter extends CustomPainter {
  final List<double> values;
  final List<String> labels;
  RadarChartPainter({required this.values, required this.labels});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 * 0.7;
    final angleStep = (2 * math.pi) / values.length;
    final guidePaint = Paint()
      ..color = OakeyTheme.borderLine
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    for (int i = 1; i <= 4; i++) {
      final currentRadius = radius * (i / 4);
      final path = Path();
      for (int j = 0; j < values.length; j++) {
        final angle = j * angleStep - math.pi / 2;
        final x = center.dx + currentRadius * math.cos(angle);
        final y = center.dy + currentRadius * math.sin(angle);
        if (j == 0)
          path.moveTo(x, y);
        else
          path.lineTo(x, y);
      }
      path.close();
      canvas.drawPath(path, guidePaint);
    }

    for (int j = 0; j < values.length; j++) {
      final angle = j * angleStep - math.pi / 2;
      canvas.drawLine(
        center,
        Offset(
          center.dx + radius * math.cos(angle),
          center.dy + radius * math.sin(angle),
        ),
        guidePaint,
      );
    }

    final dataPath = Path();
    for (int i = 0; i < values.length; i++) {
      final angle = i * angleStep - math.pi / 2;
      final x = center.dx + radius * values[i] * math.cos(angle);
      final y = center.dy + radius * values[i] * math.sin(angle);
      if (i == 0)
        dataPath.moveTo(x, y);
      else
        dataPath.lineTo(x, y);
    }
    dataPath.close();

    canvas.drawPath(
      dataPath,
      Paint()
        ..color = OakeyTheme.accentOrange.withOpacity(0.3)
        ..style = PaintingStyle.fill,
    );
    canvas.drawPath(
      dataPath,
      Paint()
        ..color = OakeyTheme.accentOrange
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0,
    );

    for (int i = 0; i < labels.length; i++) {
      final angle = i * angleStep - math.pi / 2;
      final textOffset = Offset(
        center.dx + (radius + 20) * math.cos(angle), // 텍스트 간격 살짝 넓힘
        center.dy + (radius + 20) * math.sin(angle),
      );
      final textPainter = TextPainter(
        text: TextSpan(
          text: labels[i],
          style: const TextStyle(
            color: OakeyTheme.textSub,
            fontSize: OakeyTheme.fontSizeS,
            fontWeight: FontWeight.w600,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      textPainter.paint(
        canvas,
        Offset(
          textOffset.dx - textPainter.width / 2,
          textOffset.dy - textPainter.height / 2,
        ),
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class _InfoItem {
  final String label;
  final String value;
  const _InfoItem({required this.label, required this.value});
}
