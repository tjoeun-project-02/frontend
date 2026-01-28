import 'package:flutter/material.dart';
import 'package:frontend/screen/list/whisky_list_screen.dart';
import 'package:get/get.dart';
import '../../Directory/core/theme.dart';
import '../list/whisky_detail_screen.dart';
import '../../models/whisky.dart';
// import '../main/main_screen.dart';

class OcrResultScreen extends StatelessWidget {
  final List<dynamic> results; // FastAPI에서 받은 데이터

  const OcrResultScreen({super.key, required this.results});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: OakeyTheme.backgroundMain,
      // 상단바: 뒤로가기 버튼만 깔끔하게 배치
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: OakeyTheme.textMain),
          onPressed: () => Get.back(), // 뒤로가기 (다시 스캔하기와 동일 효과)
        ),
        centerTitle: true,
        title: const Text(
          "검색 결과",
          style: TextStyle(
            color: OakeyTheme.textMain,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 10),
            // 1. 헤더 텍스트
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                children: [
                  Text(
                    "찾으시는 위스키인가요?",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: OakeyTheme.textMain,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "가장 유사한 위스키를 찾아보았습니다.",
                    style: TextStyle(fontSize: 14, color: OakeyTheme.textSub),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // 2. 위스키 결과 리스트 (카드 확대됨)
            Expanded(
              child: results.isEmpty
                  ? const Center(child: Text("인식된 위스키 정보가 없습니다."))
                  : ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      scrollDirection: Axis.horizontal,
                      itemCount: results.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(width: 20),
                      itemBuilder: (context, index) {
                        final data = results[index];
                        final whisky = Whisky.fromJson(data);
                        return _buildBigWhiskyCard(context, whisky);
                      },
                    ),
            ),

            const SizedBox(height: 30),

            // 3. 하단 버튼 영역
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 30),
              child: Column(
                children: [
                  // 버튼 1: 다시 스캔하기 (이전 상태로 복귀)
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () {
                        Get.back();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFF0EAE5),
                        foregroundColor: OakeyTheme.textMain,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text(
                        "다시 스캔하기",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // 버튼 2: 직접 검색하기 (리스트 페이지/메인으로 이동)
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () {
                        Get.offAll(() => WhiskyListScreen());
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: OakeyTheme.primaryDeep,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text(
                        "직접 검색하기",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ★ 디자인이 수정된 대형 위스키 카드 (클릭 기능 포함)
  Widget _buildBigWhiskyCard(BuildContext context, Whisky whisky) {
    return GestureDetector(
      // ★ [기능 구현] 카드 클릭 시 상세 페이지로 이동 (ID 및 정보 전달)
      onTap: () => Get.to(() => WhiskyDetailScreen(whisky: whisky)),

      child: Container(
        width: 240, // 너비 (정보가 많아 보이게)
        margin: const EdgeInsets.only(bottom: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
          border: Border.all(color: OakeyTheme.borderLine.withOpacity(0.6)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. 위스키 이미지 영역 (카드 상단)
            Expanded(
              flex: 5,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  color: Color(0xFFFAFAFA),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                ),
                child: Image.network(
                  whisky.wsImage ?? '',
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => const Icon(
                    Icons.liquor,
                    size: 60,
                    color: OakeyTheme.primarySoft,
                  ),
                ),
              ),
            ),

            // 2. 정보 텍스트 영역 (카드 하단)
            Expanded(
              flex: 4,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 카테고리 배지
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: OakeyTheme.accentOrange.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            whisky.wsCategory.toUpperCase(),
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: OakeyTheme.accentOrange,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),

                        // 한글 이름
                        Text(
                          whisky.wsNameKo,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: OakeyTheme.textMain,
                            height: 1.2,
                          ),
                        ),
                        const SizedBox(height: 4),

                        // 영어 이름
                        Text(
                          whisky.wsName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: OakeyTheme.textHint,
                          ),
                        ),
                      ],
                    ),

                    // 하단 별점 및 상세보기 힌트
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.star,
                              color: OakeyTheme.accentGold,
                              size: 18,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              "${whisky.wsRating}",
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: OakeyTheme.textMain,
                              ),
                            ),
                          ],
                        ),
                        const Text(
                          "자세히 보기 >",
                          style: TextStyle(
                            fontSize: 12,
                            color: OakeyTheme.textSub,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
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
