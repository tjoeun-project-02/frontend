import 'package:flutter/material.dart';
import 'package:frontend/services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/main_bottom_nav.dart';
import 'login_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  String _userName = "";
  final Color _brandColor = const Color(0xFF4E342E);
  final Color _backgroundColor = const Color(0xFFF9F5F2);

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userName = prefs.getString('nickname') ?? "고객";
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: AppBar(
        title: const Text('Oakey', style: TextStyle(color: Color(0xFF4E342E), fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('안녕하세요 $_userName님\n어떤 위스키를 찾아볼까요?',
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),

            // 1. 검색창 및 카메라 아이콘
            _buildSearchBar(),
            const SizedBox(height: 25),

            // 2. 최근 검색어
            const Text('최근 검색어', style: TextStyle(fontSize: 16, color: Colors.grey)),
            const SizedBox(height: 12),
            _buildRecentSearches(),
            const SizedBox(height: 30),

            // 3. 가이드 배너 (초보자를 위한 안내서)
            _buildGuideBanner(),
            const SizedBox(height: 35),

            // 4. 오늘의 추천 위스키
            const Text('오늘의 추천 위스키',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 15),
            _buildRecommendationList(),
          ],
        ),
      ),
      // 공통 하단바 적용
      bottomNavigationBar: MainBottomNav(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
      ),
    );
  }

  // 검색창 위젯
  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: TextField(
        decoration: InputDecoration(
          hintText: '검색어를 입력하세요',
          prefixIcon: const Icon(Icons.search, color: Colors.grey),
          suffixIcon: IconButton(
            icon: const Icon(Icons.camera_alt_outlined, color: Color(0xFF8D776D)),
            onPressed: () {
              ApiService.logout();
              if (!mounted) return;

              // 2. 로그인 페이지로 이동하며 이전 스택 모두 제거
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => LoginScreen()),
                    (route) => false, // 모든 이전 경로를 제거함
              );
              }, // 라벨 스캔 기능 연결 예정
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 15),
        ),
      ),
    );
  }

  // 가이드 배너 위젯
  Widget _buildGuideBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: _brandColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('GUIDE FOR BEGINNER',
              style: TextStyle(color: Color(0xFFD4AF37), fontWeight: FontWeight.bold, fontSize: 12)),
          const SizedBox(height: 10),
          const Text('"위스키, 어떻게 시작해야 할까요?"\n초보자를 위한 친절한 안내서',
              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold, height: 1.4)),
          const SizedBox(height:15),
          const Text(
            '양주와의 차이점부터 나에게 맞는 시음법까지.\n처음 시작할 때 꼭 필요한 정보들을 알기 쉽게 정리했습니다.',
            style: TextStyle(fontSize: 15, color: Colors.white),),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFDCC084),
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('가이드 확인하기', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  // 최근 검색어 태그 리스트
  Widget _buildRecentSearches() {
    final tags = ['피트 입문', '맥캘란', '셰리 캐스크'];
    return Wrap(
      spacing: 10,
      children: tags.map((tag) => ActionChip(
        label: Text(tag, style: const TextStyle(color: Colors.grey)),
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10), side: const BorderSide(color: Color(0xFFE0E0E0))),
        onPressed: () {},
      )).toList(),
    );
  }

  // 추천 위스키 리스트 (가로 스크롤)
  Widget _buildRecommendationList() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 30),
      child: SizedBox(
        height: 200,

        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: 3,
          separatorBuilder: (_, __) => const SizedBox(width: 15),
          itemBuilder: (context, index) {
            return Container(
              width: 150,
              decoration: BoxDecoration(
                color: const Color(0xFFEFEBE9),
                borderRadius: BorderRadius.circular(15),
              ),
            );
          },
        ),
      )
    );
  }
}