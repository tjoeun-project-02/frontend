import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/whisky.dart';
import '../services/whisky_service.dart';
import '../services/db_helper.dart';

class WhiskyController extends GetxController {
  final WhiskyService _whiskyService = WhiskyService();
  final DBHelper _dbHelper = DBHelper();

  var whiskies = <Whisky>[].obs;
  var isLoading = true.obs;
  var selectedFilters = <String>{}.obs;

  final TextEditingController searchController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    loadData(); // 앱 시작 시 로드
  }

  // [핵심] 지능형 데이터 로드 로직
  Future<void> loadData() async {
    try {
      isLoading.value = true;

      // 1. 검색어와 필터가 있는지 확인
      bool isSearchMode =
          searchController.text.isNotEmpty || selectedFilters.isNotEmpty;

      if (isSearchMode) {
        // [경로 A] 필터가 걸려있으면 로컬 DB에서 조건에 맞는 것만 쏙쏙 뽑아옴
        print("로그: 필터링/검색 모드 실행 (${selectedFilters.toList()})");
        final filteredData = await _dbHelper.getFilteredWhiskies(
          selectedFilters.toList(),
          searchController.text,
        );
        whiskies.assignAll(filteredData);
      } else {
        // [경로 B] 기본 목록 로드 (버전 체크 로직 유지)
        int remoteVersion = await _whiskyService.fetchRemoteVersion();
        final prefs = await SharedPreferences.getInstance();
        int localVersion = prefs.getInt('whisky_db_version') ?? 0;

        if (remoteVersion > 0 && remoteVersion == localVersion) {
          final localData = await _dbHelper.getAllWhiskies();
          whiskies.assignAll(localData);
        } else {
          // 서버에서 새 데이터 받아와서 저장하는 로직... (기존과 동일)
          final serverData = await _whiskyService.fetchWhiskiesFromServer(
            0,
            100,
          );
          if (serverData.isNotEmpty) {
            await _dbHelper.clearAndInsertAll(serverData);
            await prefs.setInt('whisky_db_version', remoteVersion);
            whiskies.assignAll(serverData);
          }
        }
      }
    } catch (e) {
      print("에러 발생: $e");
    } finally {
      isLoading.value = false;
    }
  }

  // 필터 토글 로직
  void toggleFilter(
    String filter, {
    bool isSingleSelect = false,
    List<String>? options,
  }) {
    if (isSingleSelect && options != null) {
      if (selectedFilters.contains(filter)) {
        selectedFilters.remove(filter);
      } else {
        selectedFilters.removeWhere((f) => options.contains(f));
        selectedFilters.add(filter);
      }
    } else {
      if (selectedFilters.contains(filter)) {
        selectedFilters.remove(filter);
      } else {
        selectedFilters.add(filter);
      }
    }
    loadData(); // 필터 변경 시 다시 로드
  }
}
