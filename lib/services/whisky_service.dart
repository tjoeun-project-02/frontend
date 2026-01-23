import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/whisky.dart';
import 'db_helper.dart';

class WhiskyService {
  // 안드로이드 에뮬레이터에서 로컬 백엔드 서버에 접속하는 주소
  static const String baseUrl = "http://10.0.2.2:8080/api/whiskies";

  // 로컬 DB 접근을 위한 헬퍼 인스턴스
  final DBHelper _dbHelper = DBHelper();

  // 1. [추가] 로컬 DB(SQLite)에서 데이터를 직접 가져오는 함수
  // 화면에 목록을 띄울 때 서버 대신 이 함수를 먼저 사용하게 될 거야.
  Future<List<Whisky>> fetchWhiskiesFromLocal() async {
    try {
      print("로그: 로컬 저장소(SQLite)에서 목록을 불러옵니다.");
      // DBHelper에 만들어둔 전체 조회 함수를 실행해.
      return await _dbHelper.getAllWhiskies();
    } catch (e) {
      print("로컬 데이터 로드 중 에러: $e");
      return [];
    }
  }

  // 2. [유지] 서버의 최신 버전 번호를 가져오는 함수 (버전 체크용)
  Future<int> fetchRemoteVersion() async {
    try {
      final response = await http.get(
        Uri.parse("$baseUrl/metadata/version/whisky_list"),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        // 서버 테이블 컬럼명인 'CURRENT_VERSION'으로 데이터 추출
        return data['CURRENT_VERSION'] ?? 0;
      }
      return 0;
    } catch (e) {
      print("메타 정보 호출 에러: $e");
      return 0;
    }
  }

  // 3. [유지] 서버로부터 최신 리스트를 받아오는 함수 (업데이트용)
  // 버전이 다를 때 호출해서 데이터를 긁어오는 용도야.
  Future<List<Whisky>> fetchWhiskiesFromServer(
    int page,
    int size, {
    String? keyword,
    List<String>? filters,
  }) async {
    try {
      var url = "$baseUrl?page=$page&size=$size";

      if (keyword != null && keyword.isNotEmpty) {
        url += "&keyword=${Uri.encodeComponent(keyword)}";
      }

      if (filters != null && filters.isNotEmpty) {
        url += "&filters=${Uri.encodeComponent(filters.join(','))}";
      }

      print("서버 데이터 요청 URL: $url");

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        List<dynamic> body = jsonDecode(utf8.decode(response.bodyBytes));
        return body.map((dynamic item) => Whisky.fromJson(item)).toList();
      } else {
        print("서버 응답 에러: ${response.statusCode}");
        return [];
      }
    } catch (e) {
      print("네트워크 에러 발생: $e");
      return [];
    }
  }
}
