import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../Directory/core/theme.dart';
import '../../widgets/oakey_detail_app_bar.dart';
import '../list/whisky_detail_screen.dart';
import '../../models/whisky.dart';

class TastingNoteScreen extends StatefulWidget {
  const TastingNoteScreen({super.key});

  @override
  State<TastingNoteScreen> createState() => _TastingNoteScreenState();
}

class _TastingNoteScreenState extends State<TastingNoteScreen> {
  // 백엔드 연동 전 사용할 테이스팅 노트 목업 데이터
  List<Map<String, dynamic>> notes = [
    {
      'ws_id': 101,
      'ws_name': '발베니 14년 캐리비안 캐스크',
      'ws_name_en': 'Balvenie 14Y Caribbean Cask',
      'note_content':
          '럼 캐스크 숙성 특유의 달콤한 열대과일 향이 돋보입니다. 끝맛이 부드러워서 입문용으로 정말 좋네요...',
      'ws_distillery': 'SPEYSIDE',
      'ws_category': '싱글몰트',
      'ws_rating': 4.3,
      'flavor_tags': ['달콤한', '열대과일', '부드러움'],
    },
    {
      'ws_id': 102,
      'ws_name': '와일드 터키 101',
      'ws_name_en': 'Wild Turkey 101',
      'note_content':
          '강렬한 타격감과 바닐라 향이 일품입니다. 하이볼로 마셔도 향이 죽지 않아서 자주 찾게 될 것 같아요.',
      'ws_distillery': 'KENTUCKY',
      'ws_category': '버번',
      'ws_rating': 4.1,
      'flavor_tags': ['강렬함', '바닐라', '스파이시'],
    },
  ];

  // 테이스팅 노트를 목록에서 제거하는 함수
  void _deleteNote(int index) {
    setState(() => notes.removeAt(index));
    Get.snackbar(
      "삭제 완료",
      "노트가 삭제되었습니다.",
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: OakeyTheme.primaryDeep.withOpacity(0.8),
      colorText: Colors.white,
      duration: const Duration(seconds: 1),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: OakeyTheme.backgroundMain,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const OakeyDetailAppBar(), // 공통 상단바 위젯
            _buildHeader("Tasting Notes", notes.length), // 페이지 타이틀 및 개수 배지
            Expanded(
              child: notes.isEmpty
                  ? _buildEmptyState("작성된 노트가 없습니다.") // 데이터가 없을 때의 화면
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 15,
                      ),
                      itemCount: notes.length,
                      itemBuilder: (context, index) =>
                          _buildNoteCard(index, notes[index]),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  // 상단 타이틀과 개수 배지를 생성하는 공통 헤더 빌더
  Widget _buildHeader(String title, int count) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 10),
      child: Row(
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: OakeyTheme.fontSizeL,
              fontWeight: FontWeight.w800,
              color: OakeyTheme.textMain,
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: OakeyTheme.accentOrange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              count.toString(),
              style: const TextStyle(
                fontSize: OakeyTheme.fontSizeM,
                fontWeight: FontWeight.w600,
                color: OakeyTheme.accentOrange,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 테이스팅 노트 전용 카드 위젯 빌더
  Widget _buildNoteCard(int index, Map<String, dynamic> data) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: OakeyTheme.surfacePure,
        borderRadius: OakeyTheme.brCard,
        boxShadow: OakeyTheme.cardShadow,
        border: Border.all(color: OakeyTheme.borderLine),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: OakeyTheme.surfaceMuted,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.local_drink_rounded,
                  color: OakeyTheme.primarySoft,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      data['ws_name'],
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      data['ws_name_en'],
                      style: TextStyle(
                        color: OakeyTheme.textHint,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              // 디자인이 가미된 팝업 메뉴 버튼
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_horiz, color: OakeyTheme.textHint),
                offset: const Offset(0, 40), // 버튼 아래쪽으로 살짝 내려서 표시
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ), // 팝업창 모서리 라운드
                elevation: 4, // 그림자 깊이
                onSelected: (value) {
                  if (value == 'view') {
                    Get.to(
                      () => WhiskyDetailScreen(whisky: Whisky.fromDbMap(data)),
                    );
                  }
                  if (value == 'delete') _deleteNote(index);
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'view',
                    child: Row(
                      children: [
                        Icon(
                          Icons.visibility_outlined,
                          size: 18,
                          color: OakeyTheme.primaryDeep,
                        ),
                        SizedBox(width: 10),
                        Text('상세보기', style: TextStyle(fontSize: 14)),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(
                          Icons.delete_outline_rounded,
                          size: 18,
                          color: Colors.red,
                        ),
                        SizedBox(width: 10),
                        Text(
                          '삭제하기',
                          style: TextStyle(fontSize: 14, color: Colors.red),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(color: OakeyTheme.borderLine),
          const SizedBox(height: 16),
          Text(
            data['note_content'],
            style: TextStyle(
              color: OakeyTheme.textMain,
              fontSize: OakeyTheme.fontSizeS,
              height: 1.6,
            ),
          ), // 노트 본문
        ],
      ),
    );
  }

  // 목록이 비어있을 때 표시할 공통 빈 화면 빌더
  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.edit_note_rounded,
            size: 64,
            color: OakeyTheme.textHint.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: OakeyTheme.textHint,
            ),
          ),
        ],
      ),
    );
  }
}
