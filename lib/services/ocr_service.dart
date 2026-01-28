import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class OcrService {
  static const String ocrUrl = "http://10.0.2.2:8000/ocr";

  static Future<Map<String, dynamic>?> uploadWhiskyImage(File imageFile) async {
    try {
      var request = http.MultipartRequest('POST', Uri.parse(ocrUrl));
      request.files.add(await http.MultipartFile.fromPath('file', imageFile.path));

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        return jsonDecode(utf8.decode(response.bodyBytes));
      } else {
        print("OCR 서버 에러: ${response.statusCode}");
        return null;
      }
    } catch (e) {
      print("통신 중 오류 발생: $e");
      return null;
    }
  }
}