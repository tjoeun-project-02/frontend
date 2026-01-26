import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../Directory/core/theme.dart';
import '../../controller/user_controller.dart';
import '../auth/login_screen.dart';
import '../main/main_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _initAndNavigate();
  }

  Future<void> _initAndNavigate() async {
    // 최소 로딩 시간 보장
    await Future.delayed(const Duration(seconds: 2));

    // 로그인 상태에 따른 화면 이동
    if (UserController.to.isLoggedIn.value) {
      Get.offAll(() => MainScreen());
    } else {
      Get.offAll(() => LoginScreen());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: OakeyTheme.backgroundMain,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/img/whiskey_logo.png', width: 200, height: 200),
            OakeyTheme.boxV_L,
            const CircularProgressIndicator(color: OakeyTheme.primaryDeep),
            OakeyTheme.boxV_L,
            Text(
              'Oakey',
              style: OakeyTheme.textTitleXL.copyWith(
                fontSize: 32,
                color: OakeyTheme.primaryDeep,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
