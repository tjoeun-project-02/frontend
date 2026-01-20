import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../Directory/core/theme.dart';
import '../../widgets/oakey_detail_app_bar.dart';

// 위스키 가이드 화면을 구성하는 위젯
class WhiskyGuideScreen extends StatefulWidget {
  const WhiskyGuideScreen({super.key});

  @override
  State<WhiskyGuideScreen> createState() => _WhiskyGuideScreenState();
}

// 가이드 화면의 상태를 관리하는 클래스
class _WhiskyGuideScreenState extends State<WhiskyGuideScreen> {
  // 현재 열려있는 카드의 인덱스를 저장
  int _expandedIndex = -1;

  // 가이드 챕터 및 질문 데이터 리스트
  final List<Map<String, dynamic>> _guideData = [
    {
      "chapter": "CHAPTER 01",
      "title": "위스키, 너는 누구니?",
      "qna": [
        {
          "Q": "위스키와 양주, 무엇이 다른가요?",
          "A":
              "양주는 서양 술을 통틀어 부르는 말이고, 위스키는 그중에서 곡물을 발효하고 증류해 나무통에 숙성시킨 술입니다. 재료와 숙성이 핵심입니다.",
        },
        {
          "Q": "싱글몰트가 정확히 무엇인가요?",
          "A": "오직 보리(Malt)만 써서 한 증류소에서 만든 위스키입니다. 섞지 않아서 그 증류소만의 개성이 뚜렷합니다.",
        },
        {
          "Q": "블렌디드는 맛없는 술인가요?",
          "A":
              "절대 아닙니다! 여러 위스키를 섞어서 맛의 밸런스를 완벽하게 맞춘 예술 작품입니다. 발렌타인이나 조니워커가 대표적입니다.",
        },
      ],
    },
    {
      "chapter": "CHAPTER 02",
      "title": "위스키, 어떻게 즐길까?",
      "qna": [
        {
          "Q": "처음엔 어떻게 마셔야 하나요?",
          "A":
              "향을 온전히 느끼려면 니트(Neat)로 조금씩 맛보세요. 혀에 닿자마자 삼키지 말고 입안에서 굴려보는 게 포인트입니다.",
        },
        {
          "Q": "너무 독하면 어떡하나요?",
          "A":
              "물을 한두 방울 떨어뜨려 보세요(워터드롭). 도수가 살짝 낮아지면서 향이 확 피어오릅니다. 아니면 탄산수 타서 하이볼로 즐겨도 좋습니다.",
        },
        {
          "Q": "온 더 락은 어떤가요?",
          "A":
              "시원해서 마시기는 편한데, 너무 차가우면 위스키 향이 닫혀버립니다. 비싼 싱글몰트보다는 데일리 위스키를 마실 때 추천합니다.",
        },
      ],
    },
    {
      "chapter": "CHAPTER 03",
      "title": "도구와 준비물",
      "qna": [
        {
          "Q": "전용 잔이 꼭 필요한가요?",
          "A":
              "일반 머그컵은 향이 다 날아갑니다. 글렌캐런 같이 입구가 좁아지는 잔을 쓰면 향을 모아줘서 맛이 완전히 달라집니다.",
        },
        {
          "Q": "안주는 무엇이 좋은가요?",
          "A": "맵고 짠 음식보다는 다크 초콜릿, 견과류, 치즈, 과일 같은 가벼운 안주가 위스키 맛을 해치지 않습니다.",
        },
        {
          "Q": "얼음은 아무거나 써도 되나요?",
          "A":
              "편의점 각얼음은 금방 녹아서 술이 밍밍해집니다. 기왕이면 단단하고 투명한 큰 돌얼음이나, 집에서 얼린 왕얼음을 사용해 보세요.",
        },
      ],
    },
    {
      "chapter": "CHAPTER 04",
      "title": "맛 표현하기",
      "qna": [
        {
          "Q": "테이스팅 노트가 무엇인가요?",
          "A":
              "향(Nose), 맛(Palate), 여운(Finish)을 기록하는 것입니다. 정답은 없습니다. 내가 느낀 대로 솔직하게 적는 게 최고입니다.",
        },
        {
          "Q": "피트(Peat) 향이 무엇인가요?",
          "A": "소독약이나 탄 냄새 같은 독특한 향입니다. 보리를 말릴 때 이탄을 태워서 입힌 향인데, 중독성이 엄청납니다.",
        },
        {
          "Q": "색이 진하면 맛도 진한가요?",
          "A": "꼭 그렇진 않습니다. 색소(카라멜)를 타서 색만 진하게 만든 경우도 많으니 색깔만 보고 판단하지 마세요.",
        },
      ],
    },
    {
      "chapter": "CHAPTER 05",
      "title": "위스키의 종류",
      "qna": [
        {
          "Q": "버번 위스키는 무엇인가요?",
          "A":
              "미국이 고향입니다. 옥수수가 주재료라 특유의 달달함과 바닐라 향이 강하고, 새 오크통만 써서 나무 맛도 진합니다.",
        },
        {
          "Q": "스카치 위스키는 무엇인가요?",
          "A":
              "스코틀랜드에서 만든 위스키만 스카치라고 부릅니다. 최소 3년 이상 숙성해야 하는 등 법적인 규제가 아주 까다롭습니다.",
        },
        {
          "Q": "쉐리 위스키란 무엇인가요?",
          "A":
              "스페인의 쉐리 와인을 담았던 오크통에 숙성한 위스키입니다. 건포도나 베리류 같은 붉은 과일의 달콤한 맛이 특징입니다.",
        },
      ],
    },
    {
      "chapter": "CHAPTER 06",
      "title": "보관 및 관리",
      "qna": [
        {
          "Q": "유통기한이 있나요?",
          "A":
              "개봉 안 했으면 없습니다. 도수가 높아서 균이 못 살거든요. 직사광선 피해서 서늘한 곳에 두면 평생 보관 가능합니다.",
        },
        {
          "Q": "개봉 후엔 언제까지 마셔야 하나요?",
          "A": "공기랑 닿으면 맛이 변하기 시작합니다. 보통 6개월에서 1년 안에 비우는 게 가장 맛있게 먹는 방법입니다.",
        },
        {
          "Q": "눕혀서 보관해도 되나요?",
          "A":
              "절대 안 됩니다! 독한 술이 코르크에 닿으면 코르크가 삭아서 부서집니다. 술 맛 다 버리니까 무조건 세워서 보관하세요.",
        },
      ],
    },
    {
      "chapter": "CHAPTER 07",
      "title": "라벨의 암호 풀기",
      "qna": [
        {
          "Q": "CS(Cask Strength)가 무엇인가요?",
          "A":
              "물(가수)을 한 방울도 섞지 않고 오크통에서 바로 꺼낸 위스키입니다. 도수가 50~60도로 엄청 높지만, 그만큼 향과 맛이 강렬해서 마니아들이 열광합니다.",
        },
        {
          "Q": "NAS(No Age Statement)는 저렴한 술인가요?",
          "A":
              "숙성 연수(12년, 18년 등)를 표기하지 않았다는 뜻입니다. 맛없는 게 아니라, 숙성 연수보다 맛의 밸런스를 더 중요하게 생각해서 만든 위스키도 많습니다.",
        },
        {
          "Q": "싱글 캐스크(Single Cask)는 무엇인가요?",
          "A":
              "여러 오크통을 섞지 않고, 딱 하나의 오크통에서 나온 술만 병에 담았다는 뜻입니다. 세상에 몇 병 없는 한정판이라 희소성이 높습니다.",
        },
      ],
    },
    {
      "chapter": "CHAPTER 08",
      "title": "실패 없는 안주 조합",
      "qna": [
        {
          "Q": "편의점에서 살 만한 안주는 무엇인가요?",
          "A":
              "단짠보다는 다크 초콜릿이나 양갱, 맛밤 같은 게 좋습니다. 너무 맵거나 짠 과자는 위스키의 섬세한 맛을 다 가려버리니까 피하는 게 좋습니다.",
        },
        {
          "Q": "회랑 위스키가 어울리나요?",
          "A":
              "의외의 꿀조합입니다! 특히 소독약 냄새 나는 피트 위스키랑 생굴이나 흰 살 생선회를 같이 먹으면 바다 내음이 폭발하는 경험을 할 수 있습니다.",
        },
        {
          "Q": "삼겹살이랑은 어떤가요?",
          "A":
              "기름진 고기랑 도수 높은 버번 위스키는 찰떡궁합입니다. 버번의 강한 타격감이 고기의 느끼함을 싹 잡아주거든요. 하이볼로 마시면 더 완벽합니다.",
        },
      ],
    },
  ];

  // 화면 UI를 구성하는 빌드 메서드
  @override
  Widget build(BuildContext context) {
    int globalIndex = 0;

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
                    // 최상단 배너 위젯 호출
                    _buildHeaderBanner(),
                    const SizedBox(height: 20),

                    // 데이터 리스트를 순회하며 챕터별 위젯 생성
                    ..._guideData.map((chapterData) {
                      List<Map<String, String>> qnas = chapterData['qna'];
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildChapterHeader(
                            chapterData['chapter'],
                            chapterData['title'],
                          ),
                          ...qnas.map((qna) {
                            int currentIndex = globalIndex;
                            globalIndex++;
                            return _buildCardAccordion(
                              currentIndex,
                              qna['Q']!,
                              qna['A']!,
                            );
                          }),
                          const SizedBox(height: 24),
                        ],
                      );
                    }),
                    const SizedBox(height: 56),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 상단 배너 영역을 디자인하는 위젯
  Widget _buildHeaderBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 60, 20, 20),
      decoration: BoxDecoration(
        color: OakeyTheme.primaryDeep,
        borderRadius: const BorderRadius.only(bottomRight: Radius.circular(60)),
        boxShadow: OakeyTheme.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "GUIDE FOR BEGINNER",
            style: TextStyle(
              color: OakeyTheme.accentGold,
              fontWeight: FontWeight.w800,
              fontSize: OakeyTheme.fontSizeS,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            "“ 위스키,\n어떻게 시작해야 할까요? ”",
            style: TextStyle(
              color: Colors.white,
              fontSize: OakeyTheme.fontSizeXL,
              fontWeight: FontWeight.w800,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            "가장 기초적인 정의부터 전문가처럼\n즐기는 법까지 Oakey와 함께 알아볼까요?",
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: OakeyTheme.fontSizeM,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  // 각 챕터의 제목을 표시하는 헤더 위젯
  Widget _buildChapterHeader(String chapter, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            chapter,
            style: const TextStyle(
              color: OakeyTheme.accentOrange,
              fontWeight: FontWeight.w800,
              fontSize: OakeyTheme.fontSizeS,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(
              color: OakeyTheme.primaryDeep,
              fontWeight: FontWeight.w800,
              fontSize: OakeyTheme.fontSizeL,
              letterSpacing: -0.5,
            ),
          ),
        ],
      ),
    );
  }

  // 질문과 답변을 보여주는 카드형 아코디언 위젯
  Widget _buildCardAccordion(int index, String question, String answer) {
    final bool isExpanded = _expandedIndex == index;

    return GestureDetector(
      onTap: () {
        // 클릭 시 해당 카드만 열고 나머지는 닫는 로직
        setState(() {
          _expandedIndex = isExpanded ? -1 : index;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: OakeyTheme.surfacePure,
          borderRadius: OakeyTheme.brCard,
          border: Border.all(
            color: isExpanded
                ? OakeyTheme.primaryDeep.withOpacity(0.2)
                : Colors.transparent,
            width: 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isExpanded ? 0.08 : 0.04),
              blurRadius: 20,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          children: [
            // 질문 텍스트와 화살표 아이콘을 배치
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Row(
                children: [
                  Text(
                    "Q.",
                    style: TextStyle(
                      color: isExpanded
                          ? OakeyTheme.accentOrange
                          : Colors.grey[400],
                      fontWeight: FontWeight.w800,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      question,
                      style: TextStyle(
                        color: isExpanded
                            ? OakeyTheme.textMain
                            : OakeyTheme.textMain,
                        fontWeight: isExpanded
                            ? FontWeight.w800
                            : FontWeight.w600,
                        fontSize: OakeyTheme.fontSizeM,
                        height: 1.3,
                      ),
                    ),
                  ),
                  AnimatedRotation(
                    turns: isExpanded ? 0.5 : 0.0,
                    duration: const Duration(milliseconds: 300),
                    child: Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: isExpanded
                          ? OakeyTheme.accentOrange
                          : Colors.grey[300],
                    ),
                  ),
                ],
              ),
            ),
            // 답변 영역의 크기를 애니메이션으로 조절
            AnimatedSize(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              alignment: Alignment.topCenter,
              child: Container(
                height: isExpanded ? null : 0,
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 2,
                      height: 20,
                      decoration: BoxDecoration(
                        color: OakeyTheme.accentGold,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "A.",
                            style: TextStyle(
                              color: OakeyTheme.accentGold,
                              fontWeight: FontWeight.w800,
                              fontSize: OakeyTheme.fontSizeS,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            answer,
                            style: const TextStyle(
                              color: OakeyTheme.textMain,
                              fontSize: OakeyTheme.fontSizeM,
                              height: 1.5,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
