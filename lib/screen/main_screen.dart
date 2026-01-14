import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import 'login_screen.dart';

class MainScreen extends StatefulWidget {
  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  UserModel? _user;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('accessToken');

      if (token == null) {
        _redirectToLogin();
        return;
      }

      final userData = await ApiService.fetchUserProfile(token);
      setState(() {
        _user = UserModel.fromJson(userData);
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading user: $e');
      // 에러 발생 시(토큰 만료 등) 로그아웃 처리 후 이동
      _redirectToLogin();
    }
  }

  void _redirectToLogin() async {
    await AuthService.logout(); // 토큰 삭제
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => LoginScreen()),
    );
  }

  void _handleLogout(BuildContext context) async {
    await AuthService.logout();
    if (!mounted) return;
    Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => LoginScreen())
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Oakey'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _handleLogout(context),
          )
        ],
      ),
      body: Center(
        child: _isLoading
            ? const CircularProgressIndicator()
            : Text(
          _user != null ? '안녕하세요, ${_user!.nickname} 님 👋' : '정보를 불러올 수 없습니다.',
          style: const TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}