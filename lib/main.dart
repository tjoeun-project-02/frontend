import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import 'controller/user_controller.dart';
import 'screen/main/splash_screen.dart'; // 스플래시 화면
import 'screen/main/main_screen.dart';
import 'Directory/core/theme.dart';
import 'package:get/get.dart';

void main() async {
  // 플러터 엔진 초기화 확인
  WidgetsFlutterBinding.ensureInitialized();

  // 환경 변수 (.env) 로드
  await dotenv.load(fileName: 'assets/config/.env');
  Get.put(UserController(), permanent: true);
  // 카카오 SDK 초기화 (보안을 위해 .env 값 사용)
  KakaoSdk.init(
    nativeAppKey: dotenv.env['KAKAO_NATIVE_KEY']!,
    javaScriptAppKey: dotenv.env['KAKAO_JS_KEY']!,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      // 디버그 배너 숨김
      debugShowCheckedModeBanner: false,
      title: 'Oakey',

      theme: OakeyTheme.lightTheme,

      scrollBehavior: OakeyTheme.globalScrollBehavior,

      // theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple)),
      home: MainScreen(), // 스플래시로 변경
    );
  }
}
