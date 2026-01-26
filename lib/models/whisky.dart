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

  // 좋아요 상태 변수 추가 (값 변경 가능하도록 final 제외)
  bool isLiked;

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
    this.isLiked = false, // 기본값 false
  });

  // 서버 JSON 데이터로 객체 생성
  factory Whisky.fromJson(Map<String, dynamic> json) {
    return Whisky(
      wsId: json['wsId'] ?? json['ws_id'] ?? 0,
      wsName: json['wsName'] ?? json['ws_name'] ?? '',
      wsNameKo: json['wsNameKo'] ?? json['ws_name_ko'] ?? '',
      wsCategory: json['wsCategory'] ?? json['ws_category'] ?? '',
      wsDistillery: json['wsDistillery'] ?? json['ws_distillery'] ?? '',
      wsImage: json['wsImage'] ?? json['ws_image'],
      wsAbv: (json['wsAbv'] ?? json['ws_abv'] as num?)?.toDouble() ?? 0.0,
      wsAge: json['wsAge'] ?? json['ws_age'] ?? 0,
      wsRating: (json['wsRating'] ?? json['ws_rating'] as num?)?.toDouble() ?? 0.0,
      wsVoteCnt: json['wsVoteCnt'] ?? json['ws_vote_cnt'] ?? 0,
      tags: List<String>.from(json['tags'] ?? []),
      tasteProfile: Map<String, dynamic>.from(json['tasteProfile'] ?? json['taste_profile'] ?? {}),
      isLiked: false, // 초기화 시점에는 false
    );
  }

  // 로컬 DB 저장을 위한 Map 변환
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

  // 로컬 DB 데이터로 객체 생성
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
      isLiked: false,
    );
  }
}
