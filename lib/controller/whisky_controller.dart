import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/whisky.dart';
import '../services/whisky_service.dart';
import '../services/db_helper.dart';
import '../services/api_service.dart';
import '../controller/user_controller.dart';
import 'dart:math'; // 오늘의 추천 랜덤생성

class WhiskyController extends GetxController {
  final WhiskyService _whiskyService = WhiskyService();
  final DBHelper _dbHelper = DBHelper();

  var whiskies = <Whisky>[].obs;
  var isLoading = true.obs;
  var selectedFilters = <String>{}.obs;

  // 내가 찜한 위스키 ID 목록
  var likedWhiskyIds = <int>{}.obs;

  final TextEditingController searchController = TextEditingController();

  // 추천 위스키 데이터를 담을 리스트
  RxList<Whisky> recommendedWhiskies = <Whisky>[].obs;
  // 추천된 카테고리 이름
  RxString recommendedCategory = ''.obs;

  @override
  void onInit() {
    super.onInit();
    ever(whiskies, (_) {
      if (whiskies.isNotEmpty) {
        generateRandomRecommendations();
      }
    });
  }

  // ★ 랜덤 추천 로직 구현
  void generateRandomRecommendations() {
    if (whiskies.isEmpty) return;

    final random = Random();

    // 1. 존재하는 모든 카테고리 추출 (중복 제거)
    final categories = whiskies.map((w) => w.wsCategory).toSet().toList();

    if (categories.isEmpty) return;

    // 2. 랜덤 카테고리 1개 선택
    final targetCategory = categories[random.nextInt(categories.length)];
    recommendedCategory.value = targetCategory;

    // 3. 해당 카테고리에 속한 위스키들만 필터링
    final categoryWhiskies = whiskies
        .where((w) => w.wsCategory == targetCategory)
        .toList();

    // 4. 리스트를 섞은 뒤 앞에서 3개 뽑기 (데이터가 3개보다 적으면 전부 가져옴)
    categoryWhiskies.shuffle();
    recommendedWhiskies.assignAll(categoryWhiskies.take(3).toList());
  }

  // 데이터 로드 및 찜 목록 동기화
  Future<void> loadData() async {
    try {
      isLoading.value = true;

      // 1. 위스키 리스트 로드
      List<Whisky> tempList = [];
      bool isSearchMode =
          searchController.text.isNotEmpty || selectedFilters.isNotEmpty;

      if (isSearchMode) {
        tempList = await _dbHelper.getFilteredWhiskies(
          selectedFilters.toList(),
          searchController.text,
        );
      } else {
        int remoteVersion = await _whiskyService.fetchRemoteVersion();
        final prefs = await SharedPreferences.getInstance();
        int localVersion = prefs.getInt('whisky_db_version') ?? 0;

        if (remoteVersion > 0 && remoteVersion == localVersion) {
          tempList = await _dbHelper.getAllWhiskies();
        } else {
          final serverData = await _whiskyService.fetchWhiskiesFromServer(
            0,
            100,
          );
          if (serverData.isNotEmpty) {
            await _dbHelper.clearAndInsertAll(serverData);
            await prefs.setInt('whisky_db_version', remoteVersion);
            tempList = serverData;
          }
        }
      }

      // 2. 로그인 상태라면 찜 목록 가져와서 동기화
      int currentUserId = 0;
      try {
        currentUserId = UserController.to.userId.value;
      } catch (e) {
        currentUserId = 0;
      }

      if (currentUserId > 0) {
        Set<int> serverLikes = await ApiService.fetchLikedWhiskyIds(
          currentUserId,
        );
        likedWhiskyIds.assignAll(serverLikes);

        for (var whisky in tempList) {
          whisky.isLiked = likedWhiskyIds.contains(whisky.wsId);
        }
      } else {
        likedWhiskyIds.clear();
      }

      whiskies.assignAll(tempList);
    } catch (e) {
      print("데이터 로드 에러: $e");
    } finally {
      isLoading.value = false;
    }
  }

  // ★ [수정됨] 좋아요 토글 (실패 시 롤백 기능 추가)
  Future<void> toggleLike(int wsId) async {
    int currentUserId = 0;
    try {
      currentUserId = UserController.to.userId.value;
    } catch (e) {
      currentUserId = 0;
    }

    if (currentUserId == 0) {
      Get.snackbar(
        "알림",
        "로그인이 필요합니다.",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.black87,
        colorText: Colors.white,
      );
      return;
    }

    // 1. UI 즉시 반영 (낙관적 업데이트)
    bool isOriginallyLiked = likedWhiskyIds.contains(wsId);
    if (isOriginallyLiked) {
      likedWhiskyIds.remove(wsId);
    } else {
      likedWhiskyIds.add(wsId);
    }

    // 리스트 갱신 알림
    int index = whiskies.indexWhere((w) => w.wsId == wsId);
    if (index != -1) {
      whiskies[index].isLiked = !isOriginallyLiked;
      whiskies.refresh();
    }

    // 2. 서버 요청 전송
    bool success = await ApiService.toggleLike(wsId, currentUserId);

    // 3. ★ [핵심] 실패 시 원상복구 (롤백)
    if (!success) {
      print("❌ 좋아요 서버 저장 실패! 롤백합니다.");

      // 상태 되돌리기
      if (isOriginallyLiked) {
        likedWhiskyIds.add(wsId); // 다시 추가
      } else {
        likedWhiskyIds.remove(wsId); // 다시 삭제
      }

      if (index != -1) {
        whiskies[index].isLiked = isOriginallyLiked;
        whiskies.refresh();
      }

      Get.snackbar(
        "저장 실패",
        "서버 문제로 좋아요가 반영되지 않았습니다.",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    }
  }

  bool isLiked(int wsId) => likedWhiskyIds.contains(wsId);

  void toggleFilter(
    String filter, {
    bool isSingleSelect = false,
    List<String>? options,
  }) {
    // ... 기존 필터 로직과 동일 ...
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
    loadData();
  }
}
