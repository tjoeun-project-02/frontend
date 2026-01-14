class UserModel {
  final int userId;
  final String nickname;

  UserModel({required this.userId, required this.nickname});

  // JSON 데이터를 객체로 변환하는 팩토리 메서드
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      userId: json['userId'],
      nickname: json['nickname'],
    );
  }
}