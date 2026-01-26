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
        duration: const Duration(milliseconds: 250),
        height: 58,
        decoration: BoxDecoration(
          color: OakeyTheme.surfacePure,
          borderRadius: BorderRadius.circular(16),
          border: _isFocused
              ? Border.all(color: OakeyTheme.primaryDeep, width: 1.5)
              : Border.all(
                  color: OakeyTheme.borderLine.withOpacity(0.5),
                  width: 1.0,
                ),
          boxShadow: [
            BoxShadow(
              color: OakeyTheme.primaryDeep.withOpacity(
                _isFocused ? 0.15 : 0.03,
              ),
              blurRadius: _isFocused ? 15 : 10,
              offset: const Offset(0, 8),
              spreadRadius: _isFocused ? 1 : 0,
            ),
          ],
        ),
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 18.0, right: 12.0),
              child: Icon(
                Icons.search_rounded,
                color: _isFocused
                    ? OakeyTheme.primaryDeep
                    : OakeyTheme.textHint,
                size: 26,
              ),
            ),
            Container(
              width: 1,
              height: 24,
              color: OakeyTheme.borderLine.withOpacity(0.5),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: widget.controller,
                focusNode: _focusNode,
                onChanged: widget.onChanged,

                // 검색바 내부에서 '저장' 로직을 수행하고, 부모에게 알림
                onSubmitted: (value) {
                  // 1. 공백 제거(trim) 후 비어있으면 아무것도 안 하고 함수 종료!
                  if (value.trim().isEmpty) return;

                  // 2. 입력값이 있을 때만 저장하고 부모에게 알림
                  Get.find<HomeController>().addRecentSearch(value);
                  widget.onSubmitted?.call(value);
                },

                textAlignVertical: TextAlignVertical.center,
                textInputAction: TextInputAction.search,
                style: const TextStyle(
                  fontSize: 16,
                  color: OakeyTheme.textMain,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.2,
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
                  contentPadding: EdgeInsets.zero,
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
