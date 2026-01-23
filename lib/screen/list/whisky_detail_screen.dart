import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:get/get.dart';
import '../../Directory/core/theme.dart';
import '../../widgets/oakey_detail_app_bar.dart';
import '../../models/whisky.dart';
import '../../services/db_helper.dart';
import '../../services/api_service.dart';
import '../../controller/user_controller.dart';

class WhiskyDetailScreen extends StatefulWidget {
  final Whisky whisky;

  const WhiskyDetailScreen({super.key, required this.whisky});

  @override
  State<WhiskyDetailScreen> createState() => _WhiskyDetailScreenState();
}

class _WhiskyDetailScreenState extends State<WhiskyDetailScreen> {
  final TextEditingController _noteController = TextEditingController();
  final FocusNode _noteFocusNode = FocusNode();
  final DBHelper _dbHelper = DBHelper();

  bool _isNoteSaved = false;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _loadMyNote(); // 화면 켜질 때 데이터 불러오기
  }

  // 로컬 + 서버 데이터 불러오기 (동기화)
  Future<void> _loadMyNote() async {
    // 1. 로컬 DB에서 먼저 불러오기 (빠른 로딩)
    final localData = await _dbHelper.getNote(widget.whisky.wsId);
    if (localData != null) {
      setState(() {
        _noteController.text = localData['comment_body'];
        _isNoteSaved = true;
        _isEditing = false;
      });
    }

    // 2. 로그인 상태면 서버 데이터도 확인 (최신 데이터 동기화)
    int currentUserId = 0;
    try {
      currentUserId = UserController.to.userId.value;
    } catch (e) {
      currentUserId = 0;
    }

    if (currentUserId > 0) {
      // 서버에서 내 노트 가져오기
      var serverData = await ApiService.fetchMyNote(widget.whisky.wsId);

      if (serverData != null) {
        String serverContent = serverData['content'];

        // 로컬과 내용이 다르면 서버 내용으로 덮어쓰기
        if (localData == null || localData['comment_body'] != serverContent) {
          setState(() {
            _noteController.text = serverContent;
            _isNoteSaved = true;
            _isEditing = false;
          });
          // 로컬 DB도 업데이트
          await _dbHelper.saveNote(
            widget.whisky.wsId,
            serverContent,
            currentUserId,
          );
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

  // 노트 버튼 액션 (등록/수정 모드 전환)
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

  // 저장 로직 (로컬 + 서버)
  Future<void> _saveProcess(String message) async {
    final String content = _noteController.text.trim();
    if (content.isEmpty) return;

    FocusScope.of(context).unfocus();

    int currentUserId = UserController.to.userId.value;
    if (currentUserId == 0) currentUserId = 1;

    await _dbHelper.saveNote(widget.whisky.wsId, content, currentUserId);

    bool serverSuccess = false;

    // 1. 기존 댓글 ID 조회
    int? existingId = await ApiService.getMyCommentId(widget.whisky.wsId);

    if (existingId != null) {
      // 2-A. 수정 로직
      serverSuccess = await ApiService.updateNote(
        commentId: existingId, // 이 부분을 이름과 함께 넣어주세요
      content: content,
    );
    } else {
      // 2-B. 등록 로직 (타입 불일치 해결)
      final int? newId = await ApiService.insertNote(
        wsId: widget.whisky.wsId, // Named parameter 사용
        userId: currentUserId,
        content: content,
      );
      serverSuccess = (newId != null); // ID가 있으면 성공으로 판단
    }

    setState(() => _isNoteSaved = true);

    Get.snackbar(
      _isEditing ? "수정 완료" : "등록 완료",
      serverSuccess ? "$message (서버 반영됨)" : "$message (서버 실패: 로컬 저장됨)",
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: OakeyTheme.primaryDeep.withOpacity(0.8),
      colorText: Colors.white,
      margin: const EdgeInsets.all(20),
      duration: const Duration(seconds: 2),
    );
  }

  // 삭제 로직 (로컬 + 서버)
  Future<void> _handleDelete() async {
    FocusScope.of(context).unfocus();

    bool serverSuccess = false;

    // 1. 서버 데이터 삭제 시도
    int? commentId = await ApiService.getMyCommentId(widget.whisky.wsId);
    if (commentId != null) {
      serverSuccess = await ApiService.deleteNote(commentId: commentId);
    }

    // 2. 로컬 DB 삭제
    await _dbHelper.deleteNote(widget.whisky.wsId);

    setState(() {
      _noteController.clear();
      _isNoteSaved = false;
      _isEditing = false;
    });

    Get.snackbar(
      "삭제 완료",
      serverSuccess ? "테이스팅 노트가 삭제되었습니다." : "내 폰에서 삭제됨 (서버 삭제 실패)",
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: OakeyTheme.primaryDeep.withOpacity(0.8),
      colorText: Colors.white,
      margin: const EdgeInsets.all(20),
      duration: const Duration(seconds: 2),
    );
  }

  // 맛 가이드 팝업
  void _showTasteHelp(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(OakeyTheme.radiusM),
        ),
        backgroundColor: OakeyTheme.surfacePure,
        title: Text('맛 가이드', style: Theme.of(context).textTheme.titleMedium),
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
    // 위스키 객체 데이터
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
                    _buildMainWhiskyInfo(name, enName, whisky.wsImage),

                    const SizedBox(height: 32),
                    const Divider(
                      color: Color(0xFFE0E0E0),
                      thickness: 1,
                      indent: 20,
                      endIndent: 20,
                    ),
                    const SizedBox(height: 32),

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

  Widget _buildMainWhiskyInfo(String name, String enName, String? imageUrl) {
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
          fontSize: OakeyTheme.fontSizeL,
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
                  color: OakeyTheme.accentGold,
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
    final List<double> values = labels.map((key) {
      var val =
          profile[key] ??
          profile[key.toUpperCase()] ??
          profile[key.toLowerCase()] ??
          0;
      double numVal = double.tryParse(val.toString()) ?? 0.0;
      return (numVal / 5.0).clamp(0.0, 1.0);
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
          const Text(
            '나의 테이스팅 노트',
            style: TextStyle(
              fontSize: OakeyTheme.fontSizeL,
              fontWeight: FontWeight.w800,
            ),
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

  Widget _buildTastingNoteInputBox(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: OakeyTheme.borderLine),
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
        center.dx + (radius + 25) * math.cos(angle),
        center.dy + (radius + 25) * math.sin(angle),
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
