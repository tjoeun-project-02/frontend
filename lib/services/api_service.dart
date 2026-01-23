import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String baseUrl = 'http://10.0.2.2:8080/api';

  // 공통 헤더 생성 및 토큰 처리
  static Future<Map<String, String>> _buildHeaders({
    bool withAuth = false,
  }) async {
    final Map<String, String> headers = {'Content-Type': 'application/json'};
    if (withAuth) {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('accessToken');
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }
    }
    return headers;
  }

  // 내 댓글 ID 조회
  static Future<int?> getMyCommentId(int wsId) async {
    final url = Uri.parse('$baseUrl/comments/whisky/$wsId/my');
    try {
      final headers = await _buildHeaders(withAuth: true);
      final response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        final List<dynamic> list = jsonDecode(utf8.decode(response.bodyBytes));
        if (list.isNotEmpty) {
          final dynamic id = list[0]['commentId'];
          return int.tryParse(id?.toString() ?? '');
        }
      }
    } catch (e) {
      print('댓글 조회 에러: $e');
    }
    return null;
  }

  // 내 노트 내용 조회
  static Future<Map<String, dynamic>?> fetchMyNote(int wsId) async {
    final url = Uri.parse('$baseUrl/comments/whisky/$wsId/my');
    try {
      final headers = await _buildHeaders(withAuth: true);
      final response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        final List<dynamic> list = jsonDecode(utf8.decode(response.bodyBytes));
        if (list.isNotEmpty) {
          return list[0] as Map<String, dynamic>;
        }
      }
    } catch (e) {
      print('내 노트 조회 에러: $e');
    }
    return null;
  }

  // 노트 등록
  static Future<int?> insertNote({
    required int wsId,
    required int userId,
    required String content,
  }) async {
    final url = Uri.parse('$baseUrl/comments');
    try {
      final headers = await _buildHeaders(withAuth: true);
      final response = await http.post(
        url,
        headers: headers,
        body: jsonEncode({'wsId': wsId, 'userId': userId, 'content': content}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final String bodyText = utf8.decode(response.bodyBytes).trim();
        if (bodyText.isEmpty) return null;

        final dynamic decoded = jsonDecode(bodyText);
        if (decoded is Map) {
          final dynamic id = decoded['commentId'] ?? decoded['id'];
          return int.tryParse(id?.toString() ?? '');
        }
        if (decoded is int) return decoded;
        if (decoded is List && decoded.isNotEmpty) {
          final dynamic id = decoded[0]['commentId'] ?? decoded[0]['id'];
          return int.tryParse(id?.toString() ?? '');
        }
        return null;
      }
    } catch (e) {
      print('등록 에러: $e');
    }
    return null;
  }

  // 노트 수정
  static Future<bool> updateNote({
    required int commentId,
    required String content,
  }) async {
    final url = Uri.parse('$baseUrl/comments/$commentId');
    try {
      final headers = await _buildHeaders(withAuth: true);
      final response = await http.put(
        url,
        headers: headers,
        body: jsonEncode({'content': content}),
      );
      if (response.statusCode == 200) return true;
    } catch (e) {
      print('수정 에러: $e');
    }
    return false;
  }

  // 노트 삭제
  static Future<bool> deleteNote({required int commentId}) async {
    final url = Uri.parse('$baseUrl/comments/$commentId');
    try {
      final headers = await _buildHeaders(withAuth: true);
      final response = await http.delete(url, headers: headers);
      if (response.statusCode == 200) return true;
    } catch (e) {
      print('삭제 에러: $e');
    }
    return false;
  }

  // 찜 목록의 ID들만 Set으로 반환
  static Future<Set<int>> fetchLikedWhiskyIds(int userId) async {
    final url = Uri.parse('$baseUrl/likes/$userId');
    try {
      final headers = await _buildHeaders(withAuth: true);
      if (!headers.containsKey('Authorization')) return {};

      final response = await http.get(url, headers: headers);
      if (response.statusCode == 200) {
        List<dynamic> list = jsonDecode(utf8.decode(response.bodyBytes));
        return list.map<int>((item) => item['wsId'] as int).toSet();
      }
    } catch (e) {
      print('찜 목록 ID 로딩 실패: $e');
    }
    return {};
  }

  // 찜 목록 전체 데이터 반환
  static Future<List<Map<String, dynamic>>> fetchLikedWhiskies(
    int userId,
  ) async {
    final url = Uri.parse('$baseUrl/likes/$userId');
    try {
      final headers = await _buildHeaders(withAuth: true);
      if (!headers.containsKey('Authorization')) return [];

      final response = await http.get(url, headers: headers);
      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(
          jsonDecode(utf8.decode(response.bodyBytes)),
        );
      }
    } catch (e) {
      print('찜 목록 데이터 로딩 실패: $e');
    }
    return [];
  }

  // 좋아요 토글
  static Future<bool> toggleLike(int wsId, int userId) async {
    final url = Uri.parse('$baseUrl/likes');
    try {
      final headers = await _buildHeaders(withAuth: true);
      if (!headers.containsKey('Authorization')) {
        print("❌ 토큰 없음: 로그인 상태 확인 필요");
        return false;
      }

      // 서버 DTO 필드명(wsId)과 일치해야 함
      final body = jsonEncode({'wsId': wsId});

      print("📤 좋아요 요청 보냄: $url, body: $body"); // 로그 추가

      final response = await http.post(url, headers: headers, body: body);

      print("📥 좋아요 응답: ${response.statusCode}, ${response.body}"); // 로그 추가

      if (response.statusCode == 200) return true;
    } catch (e) {
      print('❌ 좋아요 토글 통신 에러: $e');
    }
    return false;
  }
}
