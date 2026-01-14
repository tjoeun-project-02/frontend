import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'api_service.dart';

class AuthService {
  // 1. 카카오 키 해시 확인 (디버그용)
  static Future<void> printKeyHash() async {
    final keyHash = await KakaoSdk.origin;
    print('🔥 Kakao KeyHash: $keyHash');
  }

  // 2. 로그인 상태 확인 (스플래시 화면용)
  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    final accessToken = prefs.getString('accessToken');
    return accessToken != null && accessToken.isNotEmpty;
  }

  // 3. 카카오 로그인 및 서버 연동 로직 (로그인 화면용)
  static Future<bool> handleKakaoLogin() async {
    try {
      // 카카오톡 설치 여부에 따라 로그인 방식 선택
      OAuthToken token = await isKakaoTalkInstalled()
          ? await UserApi.instance.loginWithKakaoTalk()
          : await UserApi.instance.loginWithKakaoAccount();

      // 우리 백엔드 서버에 로그인 요청
      final userData = await ApiService.loginWithKakao(token.accessToken);

      // 서버에서 받은 정보를 로컬에 저장
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('accessToken', userData['accessToken']);
      await prefs.setString('refreshToken', userData['refreshToken']);
      await prefs.setInt('userId', userData['userId']);

      return true;
    } catch (e) {
      print('Kakao Login Error: $e');
      return false;
    }
  }

  // 4. 로그아웃 (메인 화면용)
  static Future<void> logout() async {
    try {
      // 카카오 로그아웃 (선택사항: 카카오 세션도 끊고 싶을 때)
      // await UserApi.instance.logout();

      // 로컬 저장소 데이터 삭제
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      print('로그아웃 완료: 모든 토큰 삭제됨');
    } catch (e) {
      print('Logout Error: $e');
    }
  }
}