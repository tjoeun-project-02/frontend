import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:get/get.dart';

import '../../Directory/core/theme.dart';
import '../../widgets/detail_app_bar.dart';
import '../../models/whisky.dart';
import '../../services/api_service.dart';
import '../../controller/user_controller.dart';
import '../../controller/whisky_controller.dart';
import '../../controller/tasting_note_controller.dart';

class WhiskyDetailScreen extends StatefulWidget {
  final Whisky whisky;

  const WhiskyDetailScreen({super.key, required this.whisky});

  @override
  State<WhiskyDetailScreen> createState() => _WhiskyDetailScreenState();
}

class _WhiskyDetailScreenState extends State<WhiskyDetailScreen> {
  // [수정됨] Get.find 대신 Get.put 사용 (컨트롤러가 없으면 생성)
  final WhiskyController controller = Get.put(WhiskyController());

  final TextEditingController _noteController = TextEditingController();
  final FocusNode _noteFocusNode = FocusNode();

  bool _isNoteSaved = false;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    resetNoteState();
    _loadMyNote();
  }

  void resetNoteState() {
    setState(() {
      _noteController.clear();
      _isNoteSaved = false;
      _isEditing = false;
    });
  }

  // 서버 데이터 불러오기
  Future<void> _loadMyNote() async {
    int currentUserId = 0;
    try {
      currentUserId = UserController.to.userId.value;
    } catch (e) {
      currentUserId = 0;
    }

    if (currentUserId > 0) {
      var serverData = await ApiService.fetchMyNote(widget.whisky.wsId);

      if (serverData != null) {
        String serverContent = serverData['content'];
        if (mounted) {
          setState(() {
            _noteController.text = serverContent;
            _isNoteSaved = true;
            _isEditing = false;
          });
        }
      }
    }
  }

  @override
  void dispose() {
    _noteController.dispose();
    _noteFocusNode.dispose();
    super.dispose();
  }

  // 노트 버튼 액션 처리
  void _handleNoteAction() {
    if (!_isNoteSaved) {
      _saveProcess('테이스팅 노트가 등록되었습니다.');
    } else {
      if (!_isEditing) {
        setState(() => _isEditing = true);
        Future.delayed(const Duration(milliseconds: 100), () {
          _noteFocusNode.requestFocus();
        });
      } else {
        _saveProcess('수정이 완료되었습니다.');
      }
    }
  }

  // 노트 저장 및 수정 로직
  Future<void> _saveProcess(String message) async {
    final String content = _noteController.text.trim();
    if (content.isEmpty) return;

    FocusScope.of(context).unfocus();

    int currentUserId = UserController.to.userId.value;
    if (currentUserId == 0) currentUserId = 1;

    bool serverSuccess = false;

    int? existingId = await ApiService.getMyCommentId(widget.whisky.wsId);

    if (existingId != null) {
      serverSuccess = await ApiService.updateNote(
        commentId: existingId,
        content: content,
      );
    } else {
      final int? newId = await ApiService.insertNote(
        wsId: widget.whisky.wsId,
        userId: currentUserId,
        content: content,
      );
      serverSuccess = (newId != null);
    }

    if (serverSuccess) {
      await _loadMyNote(); // 저장 후 데이터 갱신

      if (mounted) {
        setState(() {
          _isNoteSaved = true;
          _isEditing = false;
        });
      }

      if (Get.isRegistered<TastingNoteController>()) {
        await Get.find<TastingNoteController>().fetchNotes();
        // fetchNotes()는 목록을 서버에서 새로 가져오는 함수 (본인 함수명에 맞게 수정)
      }

      OakeyTheme.showToast(
        _isEditing ? "수정 완료" : "등록 완료",
        message,
        isError: false,
      );
    } else {
      OakeyTheme.showToast("오류", "서버 저장 실패", isError: true);
    }
  }

  // 노트 삭제 로직
  Future<void> _handleDelete() async {
    FocusScope.of(context).unfocus();

    bool serverSuccess = false;

    int? commentId = await ApiService.getMyCommentId(widget.whisky.wsId);
    if (commentId != null) {
      serverSuccess = await ApiService.deleteNote(commentId: commentId);
    }

    if (serverSuccess) {
      if (mounted) {
        setState(() {
          _noteController.clear();
          _isNoteSaved = false;
          _isEditing = false;
        });
      }

      if (Get.isRegistered<TastingNoteController>()) {
        await Get.find<TastingNoteController>().fetchNotes();
      }

      OakeyTheme.showToast("삭제 완료", "테이스팅 노트가 삭제되었습니다.", isError: false);
    } else {
      OakeyTheme.showToast("오류", "서버 삭제 실패", isError: true);
    }
  }

  void _showTasteHelp(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: OakeyTheme.radiusL),
        backgroundColor: OakeyTheme.surfacePure,
        title: const Text('맛 가이드', style: OakeyTheme.textTitleM),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHelpItem('FRUITY', '상큼하고 달콤한 과일의 풍미'),
            _buildHelpItem('MALTY', '고소한 보리와 곡물의 풍미'),
            _buildHelpItem('PEATY', '스모키하고 흙내음이 나는 피트 향'),
            _buildHelpItem('SPICY', '후추나 향신료처럼 톡 쏘는 자극'),
            _buildHelpItem('SWEET', '꿀, 바닐라, 카라멜 같은 달콤함'),
            _buildHelpItem('WOODY', '오크통 숙성에서 오는 나무의 향'),
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
              fontSize: 16,
            ),
          ),
          Text(desc, style: OakeyTheme.textBodyS),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final whisky = widget.whisky;
    final String name = whisky.wsNameKo.isNotEmpty
        ? whisky.wsNameKo
        : 'Unknown';
    final String enName = whisky.wsName;
    final String category = whisky.wsCategory.isNotEmpty
        ? whisky.wsCategory
        : '-';
    final String distillery = whisky.wsDistillery.isNotEmpty
        ? whisky.wsDistillery
        : '-';
    final String ageText = whisky.wsAge > 0 ? '${whisky.wsAge}Y' : 'NAS';
    final String abvText = whisky.wsAbv > 0 ? '${whisky.wsAbv}%' : '-';
    final String ratingStr = whisky.wsRating.toStringAsFixed(2);
    final int voteCnt = whisky.wsVoteCnt;
    final List<String> flavors = whisky.tags;

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
                    _buildMainWhiskyInfo(
                      name,
                      enName,
                      whisky.wsImage,
                      whisky.wsId,
                    ),

                    OakeyTheme.boxV_XL,
                    const Divider(
                      color: OakeyTheme.borderLine,
                      thickness: 1,
                      indent: 20,
                      endIndent: 20,
                    ),
                    OakeyTheme.boxV_XL,

                    _buildSectionTitle(context, '품질 지표'),
                    _buildQualityCard(
                      context,
                      score: ratingStr,
                      votes: voteCnt,
                    ),

                    const SizedBox(height: 40),

                    _buildSectionTitle(context, '상세 정보'),
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

                    _buildSectionTitle(context, '대표적인 향'),
                    _buildSectionDesc(context, '위스키와 관련하여 가장 많이 언급되는 기준입니다'),
                    _buildFlavorTags(flavors),

                    const SizedBox(height: 40),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildSectionTitle(context, '맛 그래프'),
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
                    _buildTasteProfileChart(context, whisky.tasteProfile),

                    const SizedBox(height: 40),

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

  // 메인 정보 표시 영역 (좋아요 버튼 포함)
  Widget _buildMainWhiskyInfo(
    String name,
    String enName,
    String? imageUrl,
    int wsId,
  ) {
    return Center(
      child: Column(
        children: [
          SizedBox(
            width: 200,
            height: 200,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 180,
                  height: 180,
                  alignment: Alignment.center,
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  decoration: BoxDecoration(
                    color: OakeyTheme.surfaceMuted,
                    borderRadius: OakeyTheme.radiusL,
                  ),
                  child: imageUrl != null && imageUrl.isNotEmpty
                      ? ClipRRect(
                          borderRadius: OakeyTheme.radiusL,
                          child: Image.network(
                            imageUrl,
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) =>
                                const Icon(
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
                Positioned(
                  right: 0,
                  top: 0,
                  child: Obx(() {
                    final bool isLiked = controller.isLiked(wsId);
                    return GestureDetector(
                      onTap: () {
                        controller.toggleLike(wsId);
                      },
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.9),
                          shape: BoxShape.circle,
                          // boxShadow: [
                          //   BoxShadow(
                          //     color: Colors.black.withOpacity(0.1),
                          //     blurRadius: 8,
                          //     offset: const Offset(0, 2),
                          //   ),
                          // ],
                        ),
                        child: Icon(
                          isLiked ? Icons.favorite : Icons.favorite_border,
                          color: isLiked ? Colors.red : OakeyTheme.textHint,
                          size: 24,
                        ),
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),

          OakeyTheme.boxV_L,

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              name,
              textAlign: TextAlign.center,
              style: OakeyTheme.textTitleL.copyWith(height: 1.3),
            ),
          ),
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              enName,
              textAlign: TextAlign.center,
              style: OakeyTheme.textBodyS.copyWith(
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
      child: Text(title, style: OakeyTheme.textTitleM),
    );
  }

  Widget _buildSectionDesc(BuildContext context, String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 20, bottom: 16),
      child: Text(
        text,
        style: OakeyTheme.textBodyS.copyWith(color: OakeyTheme.textHint),
      ),
    );
  }

  Widget _buildQualityCard(
    BuildContext context, {
    required String score,
    required int votes,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(28),
      decoration: OakeyTheme.decoCard,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Whiskybase Score', style: OakeyTheme.textBodyS),
              const SizedBox(height: 8),
              Text(
                score,
                style: const TextStyle(
                  fontSize: 42,
                  fontWeight: FontWeight.w900,
                  color: OakeyTheme.accentGold,
                  height: 1.0,
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('Votes', style: OakeyTheme.textBodyS),
              const SizedBox(height: 8),
              Text('$votes건', style: OakeyTheme.textTitleM),
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
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: OakeyTheme.textHint,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              items[index].value,
              style: OakeyTheme.textBodyL.copyWith(
                color: OakeyTheme.primaryDeep,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFlavorTags(List<String> tags) {
    if (tags.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: Text("-", style: TextStyle(color: OakeyTheme.textHint)),
      );
    }
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
                  color: OakeyTheme.accentOrange.withOpacity(0.08),
                  borderRadius: OakeyTheme.radiusXS,
                ),
                child: Text(
                  tag,
                  style: const TextStyle(
                    fontSize: 12,
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

  Widget _buildTasteProfileChart(
    BuildContext context,
    Map<String, dynamic> profile,
  ) {
    final List<String> labels = [
      'FRUITY',
      'MALTY',
      'PEATY',
      'SPICY',
      'SWEET',
      'WOODY',
    ];

    final List<double> values = labels.map((label) {
      final String key = label.toLowerCase();
      var val = profile[key] ?? profile[label] ?? 0;
      double numVal = double.tryParse(val.toString()) ?? 0.0;
      return (numVal / 10.0).clamp(0.0, 1.0);
    }).toList();

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
          const Text('나의 테이스팅 노트', style: OakeyTheme.textTitleM),
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
      decoration: BoxDecoration(color: color, borderRadius: OakeyTheme.radiusM),
      child: Row(
        children: [
          Icon(icon, color: OakeyTheme.textWhite, size: 16),
          const SizedBox(width: 4),
          Text(
            label,
            style: OakeyTheme.textBodyS.copyWith(
              color: OakeyTheme.textWhite,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTastingNoteInputBox(BuildContext context) {
    bool isReadOnly = _isNoteSaved && !_isEditing;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isReadOnly
            ? OakeyTheme.surfaceMuted.withOpacity(0.3)
            : OakeyTheme.surfacePure,
        borderRadius: OakeyTheme.radiusL,
        border: Border.all(color: OakeyTheme.borderLine),
      ),
      child: TextField(
        controller: _noteController,
        focusNode: _noteFocusNode,
        readOnly: isReadOnly,
        minLines: 3,
        maxLines: null,
        style: OakeyTheme.textBodyM.copyWith(height: 1.5),
        decoration: InputDecoration(
          hintText: isReadOnly ? '작성된 테이스팅 노트입니다.' : '이 위스키의 맛과 향을 기록해보세요.',
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          filled: false,
          isDense: true,
          hintStyle: TextStyle(color: OakeyTheme.textHint, fontSize: 14),
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
    final double maxRadius = size.width / 2 * 0.8;
    final angleStep = (2 * math.pi) / values.length;

    final guidePaint = Paint()
      ..color = OakeyTheme.borderLine.withOpacity(0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    for (int i = 1; i <= 5; i++) {
      final tickRadius = maxRadius * (i / 5);
      final path = Path();
      for (int j = 0; j < labels.length; j++) {
        final angle = j * angleStep - math.pi / 2;
        final x = center.dx + tickRadius * math.cos(angle);
        final y = center.dy + tickRadius * math.sin(angle);
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
          center.dx + maxRadius * math.cos(angle),
          center.dy + maxRadius * math.sin(angle),
        ),
        guidePaint,
      );
    }

    if (values.isNotEmpty) {
      final dataPath = Path();
      for (int i = 0; i < values.length; i++) {
        final angle = i * angleStep - math.pi / 2;
        final x = center.dx + maxRadius * values[i] * math.cos(angle);
        final y = center.dy + maxRadius * values[i] * math.sin(angle);

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
          ..strokeWidth = 2.5,
      );

      final pointPaint = Paint()
        ..color = OakeyTheme.accentOrange
        ..style = PaintingStyle.fill;

      final whiteDotPaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.fill;

      for (int i = 0; i < values.length; i++) {
        final angle = i * angleStep - math.pi / 2;
        final x = center.dx + maxRadius * values[i] * math.cos(angle);
        final y = center.dy + maxRadius * values[i] * math.sin(angle);

        canvas.drawCircle(Offset(x, y), 4.5, pointPaint);
        canvas.drawCircle(Offset(x, y), 2.5, whiteDotPaint);
      }
    }

    for (int i = 0; i < labels.length; i++) {
      final angle = i * angleStep - math.pi / 2;
      final textOffset = Offset(
        center.dx + (maxRadius + 28) * math.cos(angle),
        center.dy + (maxRadius + 28) * math.sin(angle),
      );

      final textPainter = TextPainter(
        text: TextSpan(
          text: labels[i],
          style: const TextStyle(
            color: OakeyTheme.textSub,
            fontSize: 11,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.2,
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
  bool shouldRepaint(covariant RadarChartPainter oldDelegate) {
    return oldDelegate.values != values;
  }
}

class _InfoItem {
  final String label;
  final String value;
  const _InfoItem({required this.label, required this.value});
}
