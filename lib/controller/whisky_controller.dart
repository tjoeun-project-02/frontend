import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Directory/core/theme.dart';
import '../models/whisky.dart';
import '../screen/ocr/ocr_result_screen.dart';
import '../services/ocr_service.dart';
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

  // 한글-영어 태그 매핑을 위한 사전
  final Map<String, String> _flavorDictionary = {};

  // 영어 태그 원본 데이터
  final List<String> _engTags = [
    "fruity",
    "fruit",
    "apple",
    "pear",
    "citrus",
    "lemon",
    "orange",
    "grape",
    "berry",
    "cherry",
    "plum",
    "peach",
    "apricot",
    "banana",
    "pineapple",
    "mango",
    "tropical",
    "dried fruit",
    "raisin",
    "fig",
    "date",
    "sultana",
    "prune",
    "sweet",
    "honey",
    "vanilla",
    "caramel",
    "toffee",
    "butterscotch",
    "chocolate",
    "cocoa",
    "sugar",
    "syrup",
    "maple",
    "candy",
    "cream",
    "custard",
    "butter",
    "cake",
    "biscuit",
    "spicy",
    "spice",
    "pepper",
    "cinnamon",
    "ginger",
    "clove",
    "nutmeg",
    "anise",
    "licorice",
    "mint",
    "herbal",
    "peaty",
    "peat",
    "smoke",
    "smoky",
    "ash",
    "bonfire",
    "charcoal",
    "tar",
    "iodine",
    "medicinal",
    "seaweed",
    "salt",
    "brine",
    "maritime",
    "woody",
    "oak",
    "wood",
    "pine",
    "cedar",
    "sawdust",
    "tannin",
    "dry",
    "nutty",
    "nut",
    "almond",
    "walnut",
    "hazelnut",
    "pecan",
    "malty",
    "malt",
    "grain",
    "cereal",
    "barley",
    "bread",
    "toast",
    "yeast",
    "dough",
    "floral",
    "flower",
    "rose",
    "heather",
    "grass",
    "hay",
    "straw",
    "leaf",
    "tea",
    "tobacco",
    "leather",
    "wax",
    "oil",
    "earthy",
    "mushroom",
    "sherry",
    "bourbon",
    "port",
    "rum",
    "wine",
    "cask",
    "finish",
    "rich",
    "smooth",
    "complex",
    "balanced",
  ];

  // 한글 태그 매핑 데이터 (따옴표 통일 및 오타 수정함)
  final List<String> _korTags = [
    "과일향",
    "과일",
    "사과",
    "배",
    "시트러스",
    "레몬",
    "오렌지",
    "포도",
    "베리",
    "체리",
    "자두",
    "복숭아",
    "살구",
    "바나나",
    "파인애플",
    "망고",
    "열대과일",
    "건과일",
    "건포도",
    "무화과",
    "대추",
    "술타나",
    "푸룬",
    "달콤한",
    "꿀",
    "바닐라",
    "카라멜",
    "토피",
    "버터스카치",
    "초콜릿",
    "코코아",
    "설탕",
    "시럽",
    "메이플",
    "캔디",
    "크림",
    "커스터드",
    "버터",
    "케이크",
    "비스킷",
    "매콤한",
    "향신료",
    "후추",
    "시나몬",
    "생강",
    "정향",
    "육두구",
    "아니스",
    "감초",
    "민트",
    "허브",
    "이끼 향",
    "이끼",
    "연기",
    "스모키",
    "재",
    "모닥불",
    "숯",
    "타르",
    "요오드",
    "약초",
    "해초",
    "소금",
    "소금물",
    "해양",
    "우디",
    "오크",
    "나무",
    "소나무",
    "삼나무",
    "톱밥",
    "타닌",
    "건조한",
    "너트 향",
    "견과류",
    "아몬드",
    "호두",
    "헤이즐넛",
    "피칸",
    "맥아",
    "몰트",
    "곡물",
    "시리얼",
    "보리",
    "빵",
    "토스트",
    "효모",
    "반죽",
    "꽃향기",
    "꽃",
    "장미",
    "헤더",
    "풀",
    "건초",
    "짚",
    "잎",
    "차",
    "담배",
    "가죽",
    "왁스",
    "기름",
    "흙내음",
    "버섯",
    "셰리",
    "버번",
    "포트",
    "럼",
    "와인",
    "통",
    "마무리",
    "풍부한",
    "부드러운",
    "복잡한",
    "균형 잡힌",
  ];

  @override
  void onInit() {
    super.onInit();

    // 앱 시작 시 사전 만들기 실행
    _initializeFlavorMap();

    loadData();
    ever(whiskies, (_) {
      if (whiskies.isNotEmpty && recommendedWhiskies.isEmpty) {
        generateRandomRecommendations();
      }
    });
  }

  // 사전 생성 함수 (한글 -> 영어 매핑)
  void _initializeFlavorMap() {
    int length = min(_engTags.length, _korTags.length);
    for (int i = 0; i < length; i++) {
      String kor = _korTags[i].trim();
      String eng = _engTags[i].trim().toLowerCase();
      _flavorDictionary[kor] = eng;
    }
  }

  // 랜덤 추천 로직
  void generateRandomRecommendations() {
    if (whiskies.isEmpty) return;
    final random = Random();
    final categories = whiskies.map((w) => w.wsCategory).toSet().toList();

    if (categories.isEmpty) return;
    final targetCategory = categories[random.nextInt(categories.length)];
    recommendedCategory.value = targetCategory;

    final categoryWhiskies = whiskies
        .where((w) => w.wsCategory == targetCategory)
        .toList();

    categoryWhiskies.shuffle();
    recommendedWhiskies.assignAll(categoryWhiskies.take(3).toList());
  }

  // 데이터 로드 (한글이름 + 영어이름 + ★태그 번역 검색 기능)
  Future<void> loadData() async {
    try {
      isLoading.value = true;

      // 1. 전체 데이터 가져오기
      List<Whisky> allWhiskies = await _dbHelper.getAllWhiskies();

      // 버전 체크 및 서버 동기화
      int remoteVersion = await _whiskyService.fetchRemoteVersion();
      final prefs = await SharedPreferences.getInstance();
      int localVersion = prefs.getInt('whisky_db_version') ?? 0;

      if (remoteVersion > localVersion || allWhiskies.isEmpty) {
        final serverData = await _whiskyService.fetchWhiskiesFromServer(0, 100);
        if (serverData.isNotEmpty) {
          await _dbHelper.clearAndInsertAll(serverData);
          await prefs.setInt('whisky_db_version', remoteVersion);
          allWhiskies = serverData;
        }
      }

      // 2. 검색어와 필터 적용 로직
      List<Whisky> resultList = [];
      bool isSearchMode =
          searchController.text.trim().isNotEmpty || selectedFilters.isNotEmpty;

      if (isSearchMode) {
        String keyword = searchController.text.trim();
        String keywordLower = keyword.toLowerCase();

        // 검색어 확장 로직
        // 사용자가 '사과'라고 검색하면 -> ["사과", "apple"] 리스트를 만듦
        List<String> targetSearchTags = [];

        // 1) 입력한 단어를 그대로 추가 (영어 검색 대비)
        targetSearchTags.add(keywordLower);

        // 2) 사전에서 한글 키워드 찾아서 영어 태그 추가
        // 예: "달콤" 검색 시 -> "sweet" 추가
        _flavorDictionary.forEach((korKey, engValue) {
          if (korKey.contains(keyword) || keyword.contains(korKey)) {
            targetSearchTags.add(engValue);
          }
        });

        resultList = allWhiskies.where((whisky) {
          // A. 검색어 매칭
          bool matchKeyword = false;
          if (keyword.isEmpty) {
            matchKeyword = true;
          } else {
            // 1) 한글 이름 검색
            bool matchKo = whisky.wsNameKo.contains(keyword);

            // 2) 영어 이름 검색 (대소문자 무시)
            bool matchEn = whisky.wsName.toLowerCase().contains(keywordLower);

            // 3) 태그 검색 (확장된 targetSearchTags 중 하나라도 포함하는지)
            // 위스키의 태그 리스트를 순회하며, 우리가 찾으려는 태그(한글or영어)가 있는지 확인
            bool matchTag = whisky.tags.any((tag) {
              String tagLower = tag.toLowerCase();
              return targetSearchTags.any(
                (target) => tagLower.contains(target),
              );
            });

            // 셋 중 하나라도 맞으면 통과
            matchKeyword = matchKo || matchEn || matchTag;
          }

          // B. 카테고리 필터 매칭
          bool matchFilter = true;
          if (selectedFilters.isNotEmpty) {
            matchFilter = selectedFilters.contains(whisky.wsCategory);
          }

          return matchKeyword && matchFilter;
        }).toList();
      } else {
        resultList = allWhiskies;
      }

      // 3. 찜 목록 동기화
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

        for (var whisky in resultList) {
          whisky.isLiked = likedWhiskyIds.contains(whisky.wsId);
        }
      } else {
        likedWhiskyIds.clear();
      }

      whiskies.assignAll(resultList);
    } catch (e) {
      print("데이터 로드 에러: $e");
    } finally {
      isLoading.value = false;
    }
  }

  // 좋아요 토글
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
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.black87,
        colorText: Colors.white,
      );
      return;
    }

    // 1. UI 즉시 반영
    bool isOriginallyLiked = likedWhiskyIds.contains(wsId);
    if (isOriginallyLiked) {
      likedWhiskyIds.remove(wsId);
    } else {
      likedWhiskyIds.add(wsId);
    }

    int index = whiskies.indexWhere((w) => w.wsId == wsId);
    if (index != -1) {
      whiskies[index].isLiked = !isOriginallyLiked;
      whiskies.refresh();
    }

    // 2. 서버 요청
    bool success = await ApiService.toggleLike(wsId, currentUserId);

    // 3. 실패 시 롤백
    if (!success) {
      print("❌ 좋아요 서버 저장 실패! 롤백합니다.");

      if (isOriginallyLiked) {
        likedWhiskyIds.add(wsId);
      } else {
        likedWhiskyIds.remove(wsId);
      }

      if (index != -1) {
        whiskies[index].isLiked = isOriginallyLiked;
        whiskies.refresh();
      }

      Get.snackbar(
        "저장 실패",
        "서버 문제로 좋아요가 반영되지 않았습니다.",
        snackPosition: SnackPosition.TOP,
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

  Future<void> startOcrProcess() async {
    final ImagePicker picker = ImagePicker();

    // 1. 하단 시트(BottomSheet)를 띄워 소스 선택
    final ImageSource? source = await Get.bottomSheet<ImageSource>(
      _buildOcrSourceSheet(),
    );

    if (source == null) return;

    // 2. 이미지 피킹
    final XFile? photo = await picker.pickImage(source: source);
    if (photo == null) return;

    // 3. 로딩 및 서버 통신
    Get.dialog(const Center(child: CircularProgressIndicator()), barrierDismissible: false);

    try {
      final result = await OcrService.uploadWhiskyImage(File(photo.path));
      Get.back(); // 로딩 종료

      if (result != null && result['spring_top3'] != null) {
        Get.to(() => OcrResultScreen(results: result['spring_top3']));
      } else {
        OakeyTheme.showToast("실패", "위스키를 인식하지 못했습니다.", isError: true);
      }
    } catch (e) {
      Get.back();
      OakeyTheme.showToast("에러", "서버 연결에 실패했습니다.", isError: true);
    }
  }

// BottomSheet 위젯 분리 (Controller 내부 혹은 별도 유틸)
  Widget _buildOcrSourceSheet() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Wrap(
        children: [
          ListTile(
            leading: const Icon(Icons.camera_alt, color: OakeyTheme.primaryDeep),
            title: const Text('직접 촬영하기'),
            onTap: () => Get.back(result: ImageSource.camera),
          ),
          ListTile(
            leading: const Icon(Icons.photo_library, color: OakeyTheme.primaryDeep),
            title: const Text('갤러리에서 가져오기'),
            onTap: () => Get.back(result: ImageSource.gallery),
          ),
        ],
      ),
    );
  }
}
