import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'api_service.dart';

class AuthService {
  // 1. 카카오 로그인 및 서버 연동 로직
  static Future<dynamic> handleKakaoLogin() async {
    try {
      // 카카오 토큰 획득
      OAuthToken token = await isKakaoTalkInstalled()
          ? await UserApi.instance.loginWithKakaoTalk()
          : await UserApi.instance.loginWithKakaoAccount();

      // [중요] 백엔드 서버에 로그인 요청 (여기서 403이나 404가 발생할 수 있음)
      final response = await ApiService.loginWithKakao(token.accessToken);

      if (response != null && response['accessToken'] != null) {
        // [CASE 1] 기존 회원: 즉시 로그인 처리 및 정보 저장
        await _saveAuthData(response);
        return true;
      }
      return false;
    } catch (e) {
      // [CASE 2] 신규 회원: 404 에러가 던져졌을 때 처리 (ApiService에서 404 처리 방식에 따라 다름)
      if (e.toString().contains('404')) {
        print('신규 회원 발견: 회원가입 페이지로 이동 필요');
        return 'NEW_USER';
      }

      // [CASE 3] 403 Forbidden 등 권한 에러
      print('Kakao Login Error: $e');
      rethrow; // 에러를 위로 던져 UI에서 알림을 띄우게 함
    }
  }

  // 데이터 저장 로직 분리 (Clean Architecture - Data Source)
  static Future<void> _saveAuthData(Map<String, dynamic> data) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('accessToken', data['accessToken']);
    await prefs.setString('refreshToken', data['refreshToken']);
    await prefs.setInt('userId', data['userId']);
    final profile = await ApiService.fetchUserProfile(prefs.getString('accessToken') as String);
    // 만약 서버에서 닉네임도 같이 준다면 저장
    await prefs.setString('nickname', profile['nickname']);
  }

  // 2. 로그인 상태 확인 (스플래시 화면용)
  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    final accessToken = prefs.getString('accessToken');
    return accessToken != null && accessToken.isNotEmpty;
  }

  // 3. 로그아웃
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}