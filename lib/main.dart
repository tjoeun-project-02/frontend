import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import 'screen/splash_screen.dart';  // 새로 생성

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: 'assets/config/.env');

  KakaoSdk.init(
    nativeAppKey: dotenv.env['KAKAO_NATIVE_KEY']!,  // .env에서 불러오기 (보안 강화)
    javaScriptAppKey: dotenv.env['KAKAO_JS_KEY']!,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Oakey',
      theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple)),
      home: SplashScreen(),  // 스플래시로 변경
    );
  }
}
