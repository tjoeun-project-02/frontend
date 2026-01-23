import 'dart:convert';

class Whisky {
  final int wsId;
  final String wsName;
  final String wsNameKo;
  final String wsCategory;
  final String wsDistillery;
  final String? wsImage;
  final double wsAbv;
  final int wsAge;
  final double wsRating;
  final int wsVoteCnt;
  final List<String> tags;
  final Map<String, dynamic> tasteProfile;

  Whisky({
    required this.wsId,
    required this.wsName,
    required this.wsNameKo,
    required this.wsCategory,
    required this.wsDistillery,
    this.wsImage,
    required this.wsAbv,
    required this.wsAge,
    required this.wsRating,
    required this.wsVoteCnt,
    required this.tags,
    required this.tasteProfile,
  });

  // 1. 서버 API(JSON)로부터 객체 생성
  factory Whisky.fromJson(Map<String, dynamic> json) {
    return Whisky(
      wsId: json['wsId'] ?? 0,
      wsName: json['wsName'] ?? '',
      wsNameKo: json['wsNameKo'] ?? '',
      wsCategory: json['wsCategory'] ?? '',
      wsDistillery: json['wsDistillery'] ?? '',
      wsImage: json['wsImage'],
      wsAbv: (json['wsAbv'] as num?)?.toDouble() ?? 0.0,
      wsAge: json['wsAge'] ?? 0,
      wsRating: (json['wsRating'] as num?)?.toDouble() ?? 0.0,
      wsVoteCnt: json['wsVoteCnt'] ?? 0,
      tags: List<String>.from(json['tags'] ?? []),
      tasteProfile: Map<String, dynamic>.from(json['tasteProfile'] ?? {}),
    );
  }

  // 2. 객체를 로컬 SQLite DB용 Map으로 변환 (List, Map은 JSON 문자열로)
  Map<String, dynamic> toDbMap() {
    return {
      'wsId': wsId,
      'wsName': wsName,
      'wsNameKo': wsNameKo,
      'wsCategory': wsCategory,
      'wsDistillery': wsDistillery,
      'wsImage': wsImage,
      'wsAbv': wsAbv,
      'wsAge': wsAge,
      'wsRating': wsRating,
      'wsVoteCnt': wsVoteCnt,
      'tags': jsonEncode(tags),
      'tasteProfile': jsonEncode(tasteProfile),
    };
  }

  // 3. 로컬 SQLite DB 데이터(Map)로부터 객체 생성
  factory Whisky.fromDbMap(Map<String, dynamic> map) {
    return Whisky(
      wsId: map['wsId'],
      wsName: map['wsName'],
      wsNameKo: map['wsNameKo'],
      wsCategory: map['wsCategory'],
      wsDistillery: map['wsDistillery'],
      wsImage: map['wsImage'],
      wsAbv: (map['wsAbv'] as num).toDouble(),
      wsAge: map['wsAge'],
      wsRating: (map['wsRating'] as num).toDouble(),
      wsVoteCnt: map['wsVoteCnt'],
      tags: List<String>.from(jsonDecode(map['tags'])),
      tasteProfile: Map<String, dynamic>.from(jsonDecode(map['tasteProfile'])),
    );
  }
}
