import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../Directory/core/theme.dart';

// 1. 상태 관리를 위한 컨트롤러 (포커스 감지)
class OakeySearchBarController extends GetxController {
  RxBool isFocused = false.obs;
  final FocusNode focusNode = FocusNode();

  @override
  void onInit() {
    super.onInit();
    focusNode.addListener(() {
      isFocused.value = focusNode.hasFocus;
    });
  }

  @override
  void onClose() {
    focusNode.dispose();
    super.onClose();
  }
}

// 2. UI 위젯
class OakeySearchBar extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final String hintText;
  final VoidCallback? onCameraTap;

  OakeySearchBar({
    super.key,
    required this.controller,
    this.onChanged,
    this.onSubmitted,
    this.hintText = '검색어를 입력하세요',
    this.onCameraTap,
  });

  @override
  Widget build(BuildContext context) {
    // 컨트롤러 주입
    final searchController = Get.put(OakeySearchBarController());

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Obx(
        () => AnimatedContainer(
          duration: const Duration(milliseconds: 200), // 부드러운 전환 애니메이션
          height: 56, // 터치하기 편한 높이
          decoration: BoxDecoration(
            color: OakeyTheme.surfacePure,
            borderRadius: BorderRadius.circular(16), // 앱 분위기에 맞는 둥근 모서리
            // 평소엔 그림자, 포커스되면 테두리로 강조
            border: searchController.isFocused.value
                ? Border.all(
                    color: OakeyTheme.primaryDeep,
                    width: 1.5,
                  ) // 포커스: 진한 테두리
                : Border.all(color: Colors.transparent, width: 1.5), // 평소: 투명

            boxShadow: [
              // 포커스 여부에 따라 그림자 깊이 조절 (눌렀을 때 살짝 들어가는 느낌)
              BoxShadow(
                color: OakeyTheme.primaryDeep.withOpacity(
                  searchController.isFocused.value ? 0.08 : 0.05,
                ),
                blurRadius: searchController.isFocused.value ? 12 : 20,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              // 1. 검색 아이콘 (왼쪽 고정)
              Padding(
                padding: const EdgeInsets.only(left: 16.0),
                child: Icon(
                  Icons.search_rounded,
                  // 포커스되면 아이콘도 진하게
                  color: searchController.isFocused.value
                      ? OakeyTheme.primaryDeep
                      : OakeyTheme.textHint,
                  size: 24,
                ),
              ),

              // 2. 텍스트 입력 필드 (가운데)
              Expanded(
                child: TextField(
                  controller: controller,
                  focusNode: searchController.focusNode,
                  onChanged: onChanged,
                  onSubmitted: onSubmitted,
                  textAlignVertical: TextAlignVertical.center,
                  textInputAction: TextInputAction.search,
                  style: const TextStyle(
                    fontSize: 16,
                    color: OakeyTheme.textMain,
                    fontWeight: FontWeight.w500,
                  ),
                  decoration: InputDecoration(
                    hintText: hintText,
                    hintStyle: TextStyle(
                      color: OakeyTheme.textHint.withOpacity(0.6),
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                    ),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                    isDense: true, // 높이 최적화
                  ),
                ),
              ),

              // 3. 카메라 버튼 (오른쪽 포인트)
              Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: onCameraTap,
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        // 카메라 버튼만 살짝 배경색을 줘서 '누를 수 있는 버튼'임을 강조
                        color: OakeyTheme.surfaceMuted.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.camera_alt_rounded,
                        color: OakeyTheme.primaryDeep, // 브랜드 컬러 포인트
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
