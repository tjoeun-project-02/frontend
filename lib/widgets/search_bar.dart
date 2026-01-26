import 'package:flutter/material.dart';
import 'package:get/get.dart'; // GetX 임포트 필수
import '../Directory/core/theme.dart';
import '../controller/home_controller.dart'; // HomeController 임포트

class OakeySearchBar extends StatefulWidget {
  final TextEditingController controller;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final String hintText;
  final VoidCallback? onCameraTap;

  const OakeySearchBar({
    super.key,
    required this.controller,
    this.onChanged,
    this.onSubmitted,
    this.hintText = '검색어를 입력하세요',
    this.onCameraTap,
  });

  @override
  State<OakeySearchBar> createState() => _OakeySearchBarState();
}

class _OakeySearchBarState extends State<OakeySearchBar> {
  late FocusNode _focusNode;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _focusNode.addListener(() {
      setState(() {
        _isFocused = _focusNode.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 56,
        decoration: BoxDecoration(
          color: OakeyTheme.surfacePure,
          borderRadius: BorderRadius.circular(16),
          border: _isFocused
              ? Border.all(color: OakeyTheme.primaryDeep, width: 1.5)
              : Border.all(color: Colors.transparent, width: 1.5),
          boxShadow: [
            BoxShadow(
              color: OakeyTheme.primaryDeep.withOpacity(
                _isFocused ? 0.08 : 0.05,
              ),
              blurRadius: _isFocused ? 12 : 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 16.0),
              child: Icon(
                Icons.search_rounded,
                color: _isFocused
                    ? OakeyTheme.primaryDeep
                    : OakeyTheme.textHint,
                size: 24,
              ),
            ),
            Expanded(
              child: TextField(
                controller: widget.controller,
                focusNode: _focusNode,
                onChanged: widget.onChanged,

                // 검색바 내부에서 '저장' 로직을 수행하고, 부모에게 알림
                onSubmitted: (value) {
                  if (value.trim().isNotEmpty) {
                    // 1. 자동으로 최근 검색어에 저장
                    Get.find<HomeController>().addRecentSearch(value);
                  }
                  // 2. 부모 위젯(MainScreen)에서 정의한 나머지 동작(화면 이동 등) 실행
                  widget.onSubmitted?.call(value);
                },

                textAlignVertical: TextAlignVertical.center,
                textInputAction: TextInputAction.search,
                style: const TextStyle(
                  fontSize: 16,
                  color: OakeyTheme.textMain,
                  fontWeight: FontWeight.w500,
                ),
                decoration: InputDecoration(
                  hintText: widget.hintText,
                  hintStyle: TextStyle(
                    color: OakeyTheme.textHint.withOpacity(0.6),
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                  ),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                  isDense: true,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: widget.onCameraTap,
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: OakeyTheme.surfaceMuted.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.camera_alt_rounded,
                      color: OakeyTheme.primaryDeep,
                      size: 20,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
