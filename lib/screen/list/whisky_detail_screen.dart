import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:get/get.dart'; // GetX 임포트 확인
import '../../Directory/core/theme.dart';
import '../../widgets/oakey_detail_app_bar.dart';

class WhiskyDetailScreen extends StatefulWidget {
  final Map<String, dynamic> whiskyData;

  const WhiskyDetailScreen({super.key, required this.whiskyData});

  @override
  State<WhiskyDetailScreen> createState() => _WhiskyDetailScreenState();
}

class _WhiskyDetailScreenState extends State<WhiskyDetailScreen> {
  // 테이스팅 노트 입력을 위한 컨트롤러 및 포커스 노드
  final TextEditingController _noteController = TextEditingController();
  final FocusNode _noteFocusNode = FocusNode();

  // 저장 상태 및 수정 모드 활성화 여부 변수
  bool _isNoteSaved = false;
  bool _isEditing = false;

  @override
  void dispose() {
    _noteController.dispose();
    _noteFocusNode.dispose();
    super.dispose();
  }

  // 등록 및 수정 상태에 따른 버튼 동작 핸들러
  void _handleNoteAction() {
    if (!_isNoteSaved) {
      _saveProcess('등록되었습니다.');
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

  // 텍스트 저장 처리 및 마이페이지와 동일한 스낵바 알림 로직
  void _saveProcess(String message) {
    if (_noteController.text.trim().isEmpty) return;
    FocusScope.of(context).unfocus();
    setState(() => _isNoteSaved = true);

    // 마이페이지 삭제 알림과 디자인 통일
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

  // 작성된 테이스팅 노트 초기화 및 삭제 알림 로직
  void _handleDelete() {
    FocusScope.of(context).unfocus();
    setState(() {
      _noteController.clear();
      _isNoteSaved = false;
      _isEditing = false;
    });

    // 마이페이지 삭제 알림과 디자인 통일
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

  // 입문자를 위한 맛 지표 도움말 팝업 노출
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

  // 도움말 상세 항목 레이아웃 빌더
  Widget _buildHelpItem(String title, String desc) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: OakeyTheme.accentOrange,
              fontSize: 13,
            ),
          ),
          Text(
            desc,
            style: const TextStyle(color: OakeyTheme.textSub, fontSize: 12),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final String name = (widget.whiskyData['ws_name'] ?? 'Unknown').toString();
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
        int.tryParse(widget.whiskyData['ws_vote_cnt']?.toString() ?? '1245') ??
        1245;
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    _buildMainWhiskyCard(name),
                    const SizedBox(height: 24),
                    _buildSectionTitle(context, 'Quality Metrics'),
                    _buildQualityCard(
                      context,
                      score: rating.toStringAsFixed(2),
                      votes: voteCnt,
                    ),
                    const SizedBox(height: 24),
                    _buildSectionTitle(context, 'Information'),
                    _buildInfoGrid(
                      context,
                      items: [
                        _InfoItem(label: 'AGE (숙성 연수)', value: ageText),
                        _InfoItem(label: 'DISTILLERY (증류소)', value: distillery),
                        _InfoItem(label: 'CATEGORY (카테고리)', value: category),
                        _InfoItem(label: 'ABV (도수)', value: abvText),
                      ],
                    ),
                    const SizedBox(height: 24),
                    _buildSectionTitle(context, 'Flavor Tags'),
                    _buildSectionDesc(
                      context,
                      '위스키와 관련하여 가장 많이 언급되는 기준으로 선정되었습니다',
                    ),
                    _buildFlavorTags(flavors),
                    const SizedBox(height: 24),
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
                              size: 20,
                            ),
                          ),
                        ),
                      ],
                    ),
                    _buildTasteProfileCard(context),
                    const SizedBox(height: 24),
                    _buildTastingNoteHeader(context),
                    _buildTastingNoteInputBox(context),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainWhiskyCard(String name) {
    final String? imageUrl = widget.whiskyData['ws_image_url'];
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.symmetric(vertical: 32),
      decoration: BoxDecoration(
        color: OakeyTheme.surfacePure,
        borderRadius: OakeyTheme.brCard,
        boxShadow: OakeyTheme.cardShadow,
        border: Border.all(color: OakeyTheme.borderLine),
      ),
      child: Column(
        children: [
          Container(
            width: 160,
            height: 160,
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
                        size: 80,
                        color: OakeyTheme.primarySoft,
                      ),
                    ),
                  )
                : const Icon(
                    Icons.liquor_rounded,
                    size: 80,
                    color: OakeyTheme.primarySoft,
                  ),
          ),
          const SizedBox(height: 20),
          Text(
            name,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 20, bottom: 8),
      child: Text(title, style: Theme.of(context).textTheme.titleMedium),
    );
  }

  Widget _buildSectionDesc(BuildContext context, String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 20, bottom: 12),
      child: Text(text, style: Theme.of(context).textTheme.labelMedium),
    );
  }

  Widget _buildQualityCard(
    BuildContext context, {
    required String score,
    required int votes,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: OakeyTheme.surfacePure,
        borderRadius: OakeyTheme.brCard,
        border: Border.all(color: OakeyTheme.borderLine),
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
                style: Theme.of(context).textTheme.labelMedium,
              ),
              const SizedBox(height: 8),
              Text(
                score,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontSize: 36,
                  color: OakeyTheme.accentOrange,
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('Votes', style: Theme.of(context).textTheme.labelMedium),
              const SizedBox(height: 12),
              Text('$votes건', style: Theme.of(context).textTheme.titleMedium),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoGrid(
    BuildContext context, {
    required List<_InfoItem> items,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: OakeyTheme.surfacePure,
        borderRadius: OakeyTheme.brCard,
        border: Border.all(color: OakeyTheme.borderLine),
        boxShadow: OakeyTheme.cardShadow,
      ),
      child: GridView.builder(
        shrinkWrap: true,
        padding: EdgeInsets.zero,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 2.5,
          mainAxisSpacing: 12,
        ),
        itemCount: items.length,
        itemBuilder: (context, index) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              items[index].label,
              style: Theme.of(context).textTheme.labelSmall,
            ),
            const SizedBox(height: 6),
            Text(
              items[index].value,
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(color: OakeyTheme.primaryDeep),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFlavorTags(List<String> tags) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: tags
            .map(
              (tag) => Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: OakeyTheme.accentOrange.withOpacity(0.08),
                  borderRadius: OakeyTheme.brTag,
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

  Widget _buildTasteProfileCard(BuildContext context) {
    final List<double> values = [0.2, 0.6, 0.4, 0.7, 0.3];
    final List<String> labels = ['Sweet', 'Fruit', 'Spicy', 'Woody', 'Smoky'];
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.symmetric(vertical: 30),
      decoration: BoxDecoration(
        color: OakeyTheme.surfacePure,
        borderRadius: OakeyTheme.brCard,
        border: Border.all(color: OakeyTheme.borderLine),
        boxShadow: OakeyTheme.cardShadow,
      ),
      child: Center(
        child: CustomPaint(
          size: const Size(220, 220),
          painter: RadarChartPainter(values: values, labels: labels),
        ),
      ),
    );
  }

  Widget _buildTastingNoteHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('Tasting Note', style: Theme.of(context).textTheme.titleMedium),
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
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(OakeyTheme.radiusXS),
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

  Widget _buildTastingNoteInputBox(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: OakeyTheme.surfacePure,
        borderRadius: OakeyTheme.brCard,
        border: Border.all(color: OakeyTheme.borderLine),
        boxShadow: OakeyTheme.cardShadow,
      ),
      child: TextField(
        controller: _noteController,
        focusNode: _noteFocusNode,
        minLines: 3,
        maxLines: null,
        decoration: const InputDecoration(
          hintText: '나만의 테이스팅 노트를 작성하세요.',
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          filled: false,
          isDense: true,
        ),
      ),
    );
  }
}

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
        center.dx + (radius + 15) * math.cos(angle),
        center.dy + (radius + 15) * math.sin(angle),
      );
      final textPainter = TextPainter(
        text: TextSpan(
          text: labels[i],
          style: const TextStyle(
            color: OakeyTheme.textSub,
            fontSize: 11,
            fontWeight: FontWeight.bold,
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
