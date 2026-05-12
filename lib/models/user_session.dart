/// 登录会话信息
class UserSession {
  final int userId;
  final String username;
  final DateTime loginAt;

  const UserSession({
    required this.userId,
    required this.username,
    required this.loginAt,
  });

  factory UserSession.fromJson(Map<String, dynamic> json) {
    return UserSession(
      userId: json['userId'] as int,
      username: json['username'] as String,
      loginAt: DateTime.parse(json['loginAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'username': username,
      'loginAt': loginAt.toIso8601String(),
    };
  }
}
