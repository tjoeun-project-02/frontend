import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  // 서버 기본 주소
  static const String baseUrl = 'http://10.0.2.2:8080/api';

  // 공통 헤더 생성(토큰 포함 여부 자동 처리)
  static Future<Map<String, String>> _buildHeaders({
    bool withAuth = false,
  }) async {
    final Map<String, String> headers = {'Content-Type': 'application/json'};
    if (withAuth) {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('accessToken');
      print("✅ APIService 헤더에 토큰 추가: $token");
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }
    }
    return headers;
  }

  // 내 댓글 번호(ID) 조회(서버에서 내 댓글이 있으면 commentId 리턴)
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

      print('댓글 조회 실패 status=${response.statusCode} body=${response.body}');
    } catch (e) {
      print('댓글 조회 에러: $e');
    }

    return null;
  }

  // 내 노트 내용 조회 (WhiskyDetailScreen에서 사용)
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

  // 노트 등록(POST) -> 서버에서 생성된 commentId를 받을 수 있으면 리턴
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
      print('🚀 요청 전송: ${url.toString()}');
      print('📦 요청 바디: ${jsonEncode({'wsId': wsId, 'userId': userId, 'content': content})}');
      print('📥 서버 응답 코드: ${response.statusCode}');
      print('📥 서버 응답 바디: ${response.body}');
      if (response.statusCode == 200 || response.statusCode == 201) {
        final String bodyText = utf8.decode(response.bodyBytes).trim();

        // 서버가 id를 안 주는 경우도 있어서 안전 처리
        if (bodyText.isEmpty) return null;

        final dynamic decoded = jsonDecode(bodyText);

        // 1) { "commentId": 12, ... } 형태
        if (decoded is Map) {
          final dynamic id = decoded['commentId'] ?? decoded['id'];
          final int? parsed = int.tryParse(id?.toString() ?? '');
          return parsed;
        }

        // 2) 12 처럼 숫자만 내려주는 형태
        if (decoded is int) return decoded;

        // 3) [{"commentId":12}] 리스트로 내려주는 형태
        if (decoded is List && decoded.isNotEmpty) {
          final dynamic id = decoded[0]['commentId'] ?? decoded[0]['id'];
          final int? parsed = int.tryParse(id?.toString() ?? '');
          return parsed;
        }

        return null;
      }

      print('등록 실패 status=${response.statusCode} body=${response.body}');
    } catch (e) {
      print('등록 에러: $e');
    }

    return null;
  }

  // 노트 수정(PUT) -> 성공 여부 리턴
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

      print('수정 실패 status=${response.statusCode} body=${response.body}');
    } catch (e) {
      print('수정 에러: $e');
    }

    return false;
  }

  // 노트 삭제(DELETE) -> 성공 여부 리턴
  static Future<bool> deleteNote({required int commentId}) async {
    final url = Uri.parse('$baseUrl/comments/$commentId');

    try {
      final headers = await _buildHeaders(withAuth: true);
      final response = await http.delete(url, headers: headers);

      if (response.statusCode == 200) return true;

      print('삭제 실패 status=${response.statusCode} body=${response.body}');
    } catch (e) {
      print('삭제 에러: $e');
    }

    return false;
  }
}
