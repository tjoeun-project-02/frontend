import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Directory/core/theme.dart';
import 'dart:math';
import '../models/whisky.dart';
import '../screen/ocr/ocr_result_screen.dart';
import '../services/ocr_service.dart';
import '../services/whisky_service.dart';
import '../services/db_helper.dart';
import '../services/api_service.dart';
import '../controller/user_controller.dart';

class WhiskyController extends GetxController {
  final WhiskyService _whiskyService = WhiskyService();
  final DBHelper _dbHelper = DBHelper();

  // 화면에 표시될 위스키 리스트
  var whiskies = <Whisky>[].obs;

  // DB에서 가져온 원본 전체 위스키 데이터
  List<Whisky> _allSourceWhiskies = [];

  var isLoading = true.obs;
  var selectedFilters = <String>{}.obs;

  var currentActiveTags = <String>{}.obs;

  // 내가 찜한 위스키 ID 목록
  var likedWhiskyIds = <int>{}.obs;

  final TextEditingController searchController = TextEditingController();

  // 추천 위스키 데이터 리스트
  RxList<Whisky> recommendedWhiskies = <Whisky>[].obs;

  // 추천된 카테고리 이름
  RxString recommendedCategory = ''.obs;

  final Map<String, String> _flavorDictionary = {};

  final Map<String, List<String>> flavorGroups = {
    "과일/상큼": [
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
    ],
    "달콤/바닐라": [
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
    ],
    "스모키/피트": [
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
    ],
    "스파이시/강렬": [
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
    ],
    "견과류/고소": [
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
    ],
    "우디/오크": [
      "woody",
      "oak",
      "wood",
      "pine",
      "cedar",
      "sawdust",
      "tannin",
      "dry",
    ],
    "꽃/허브": [
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
    ],
    "풍부함/숙성": [
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
      "leather",
      "wax",
      "oil",
      "earthy",
      "mushroom",
    ],
  };

  // 영어 태그 데이터
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

  // 한글 태그 데이터
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
    _initializeFlavorMap();

    // 앱 시작 시 원본 데이터 로드
    loadSourceData();

    // 검색어 입력 시 실시간 필터링
    searchController.addListener(() {
      applyFilterAndSearch();
    });

    // 필터 변경 시 자동 필터링
    ever(selectedFilters, (_) {
      applyFilterAndSearch();
    });
  }

  // 태그 사전 초기화
  void _initializeFlavorMap() {
    int length = min(_engTags.length, _korTags.length);
    for (int i = 0; i < length; i++) {
      String kor = _korTags[i].trim();
      String eng = _engTags[i].trim().toLowerCase();
      _flavorDictionary[kor] = eng;
    }
  }

  // 랜덤 추천 생성
  void generateRandomRecommendations() {
    final sourceList = _allSourceWhiskies.isNotEmpty
        ? _allSourceWhiskies
        : whiskies;
    if (sourceList.isEmpty) return;

    final random = Random();
    final categories = sourceList.map((w) => w.wsCategory).toSet().toList();

    if (categories.isEmpty) return;
    final targetCategory = categories[random.nextInt(categories.length)];
    recommendedCategory.value = targetCategory;

    final categoryWhiskies = sourceList
        .where((w) => w.wsCategory == targetCategory)
        .toList();

    categoryWhiskies.shuffle();
    recommendedWhiskies.assignAll(categoryWhiskies.take(3).toList());
  }

  // DB에서 원본 데이터 로드 및 초기화
  Future<void> loadSourceData() async {
    try {
      isLoading.value = true;

      // 로컬 DB 조회
      List<Whisky> fetchedList = await _dbHelper.getAllWhiskies();

      // 서버 버전 체크 및 동기화
      int remoteVersion = await _whiskyService.fetchRemoteVersion();
      final prefs = await SharedPreferences.getInstance();
      int localVersion = prefs.getInt('whisky_db_version') ?? 0;

      if (remoteVersion > localVersion || fetchedList.isEmpty) {
        final serverData = await _whiskyService.fetchWhiskiesFromServer(0, 100);
        if (serverData.isNotEmpty) {
          await _dbHelper.clearAndInsertAll(serverData);
          await prefs.setInt('whisky_db_version', remoteVersion);
          fetchedList = serverData;
        }
      }

      // 원본 리스트 저장
      _allSourceWhiskies = fetchedList;

      // 찜 목록 동기화
      await _syncLikes();

      // 추천 데이터 생성
      if (_allSourceWhiskies.isNotEmpty && recommendedWhiskies.isEmpty) {
        generateRandomRecommendations();
      }

      // 초기 필터링 적용
      applyFilterAndSearch();
    } catch (e) {
      print("데이터 로드 에러: $e");
    } finally {
      isLoading.value = false;
    }
  }

  // 찜 목록 서버 동기화
  Future<void> _syncLikes() async {
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
    } else {
      likedWhiskyIds.clear();
    }
  }

  // 검색어와 필터를 동시 적용하여 리스트 갱신 (태그는 OR 조건)
  void applyFilterAndSearch() {
    String keyword = searchController.text.trim();
    String keywordLower = keyword.toLowerCase();

    // 1. 검색어 확장
    List<String> targetSearchTags = [];
    if (keyword.isNotEmpty) {
      targetSearchTags.add(keywordLower);
      _flavorDictionary.forEach((korKey, engValue) {
        if (korKey.contains(keyword) || keyword.contains(korKey)) {
          targetSearchTags.add(engValue);
        }
      });
    }

    // 2. [핵심 수정] 선택된 필터를 '카테고리'와 '태그'로 안전하게 분리하기
    List<String> activeCategoryFilters = [];
    List<String> activeTagFilters = [];

    final List<String> knownCategories = [
      'Single Malt',
      'Blended',
      'Bourbon',
      'Japanese',
    ];

    for (String filter in selectedFilters) {
      if (flavorGroups.containsKey(filter)) {
        activeTagFilters.addAll(flavorGroups[filter]!);
      } else if (knownCategories.contains(filter)) {
        activeCategoryFilters.add(filter);
      } else if (_flavorDictionary.containsKey(filter)) {
        activeTagFilters.add(_flavorDictionary[filter]!);
      } else {
        activeTagFilters.add(filter.toLowerCase());
      }
    }

    currentActiveTags.assignAll({...activeTagFilters, ...targetSearchTags});

    // 3. 필터링 수행
    List<Whisky> result = _allSourceWhiskies.where((whisky) {
      // A. 검색어 조건
      bool matchSearch = true;
      if (keyword.isNotEmpty) {
        bool matchKo = whisky.wsNameKo.contains(keyword);
        bool matchEn = whisky.wsName.toLowerCase().contains(keywordLower);
        bool matchTag = whisky.tags.any((tag) {
          String tagLower = tag.toLowerCase();
          return targetSearchTags.any((target) => tagLower.contains(target));
        });
        matchSearch = matchKo || matchEn || matchTag;
      }

      // B. 카테고리 필터 조건
      bool matchCategory = true;
      if (activeCategoryFilters.isNotEmpty) {
        matchCategory = activeCategoryFilters.contains(whisky.wsCategory);
      }

      // C. 태그 필터 조건 (OR 조건: 하나라도 포함되면 통과)
      bool matchTagFilter = true;
      if (activeTagFilters.isNotEmpty) {
        matchTagFilter = whisky.tags.any((t) {
          String tagLower = t.toLowerCase();
          // 내 태그(tagLower) 안에 필터 단어(filter)가 포함되어 있는지 확인
          return activeTagFilters.any((filter) => tagLower.contains(filter));
        });
      }

      return matchSearch && matchCategory && matchTagFilter;
    }).toList();

    result.sort((a, b) => b.wsRating.compareTo(a.wsRating));

    // 찜 상태 반영
    for (var whisky in result) {
      whisky.isLiked = likedWhiskyIds.contains(whisky.wsId);
    }

    whiskies.assignAll(result);
  }

  // 좋아요 토글 기능
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

    bool success = await ApiService.toggleLike(wsId, currentUserId);

    if (!success) {
      if (isOriginallyLiked)
        likedWhiskyIds.add(wsId);
      else
        likedWhiskyIds.remove(wsId);

      if (index != -1) {
        whiskies[index].isLiked = isOriginallyLiked;
        whiskies.refresh();
      }
      Get.snackbar("실패", "서버 오류로 좋아요가 반영되지 않았습니다.");
    }
  }

  // 찜 여부 확인
  bool isLiked(int wsId) => likedWhiskyIds.contains(wsId);

  // 필터 토글 기능
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
    Get.dialog(
      const Center(child: CircularProgressIndicator()),
      barrierDismissible: false,
    );

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
            leading: const Icon(
              Icons.camera_alt,
              color: OakeyTheme.primaryDeep,
            ),
            title: const Text('직접 촬영하기'),
            onTap: () => Get.back(result: ImageSource.camera),
          ),
          ListTile(
            leading: const Icon(
              Icons.photo_library,
              color: OakeyTheme.primaryDeep,
            ),
            title: const Text('갤러리에서 가져오기'),
            onTap: () => Get.back(result: ImageSource.gallery),
          ),
        ],
      ),
    );
  }
}
