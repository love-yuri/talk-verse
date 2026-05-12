/// AI角色模型
/// 定义AI角色的数据结构
class Character {
  final int id;
  final String name;
  final String avatar;
  final String personality;
  final String greeting;
  final String myNickname;
  final String aiNickname;

  Character({
    required this.id,
    required this.name,
    required this.avatar,
    required this.personality,
    required this.greeting,
    this.myNickname = '冒险者',
    this.aiNickname = '',
  });

  /// 从JSON创建角色对象
  factory Character.fromJson(Map<String, dynamic> json) {
    return Character(
      id: json['id'] as int,
      name: json['name'] as String,
      avatar: json['avatar'] as String,
      personality: json['personality'] as String,
      greeting: json['greeting'] as String,
      myNickname: json['myNickname'] as String? ?? '冒险者',
      aiNickname: json['aiNickname'] as String? ?? '',
    );
  }

  /// 从远程角色文件创建角色对象
  factory Character.fromRemoteJson(Map<String, dynamic> json) {
    final name = (json['name'] as String?)?.trim() ?? '';
    final personality = (json['personality'] as String?)?.trim() ?? '';

    if (name.isEmpty) {
      throw const FormatException('角色文件缺少角色名称');
    }
    if (personality.isEmpty) {
      throw const FormatException('角色文件缺少角色设定');
    }

    final avatar = (json['avatar'] as String?)?.trim() ?? '';
    final myNickname = (json['myNickname'] as String?)?.trim() ?? '';

    return Character(
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: name,
      avatar: avatar.isEmpty ? 'assets/images/default_avatar.png' : avatar,
      personality: personality,
      greeting: (json['greeting'] as String?)?.trim() ?? '',
      myNickname: myNickname.isEmpty ? '冒险者' : myNickname,
      aiNickname: (json['aiNickname'] as String?)?.trim() ?? '',
    );
  }

  /// 转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'avatar': avatar,
      'personality': personality,
      'greeting': greeting,
      'myNickname': myNickname,
      'aiNickname': aiNickname,
    };
  }

  /// 创建副本
  Character copyWith({
    int? id,
    String? name,
    String? avatar,
    String? personality,
    String? greeting,
    String? myNickname,
    String? aiNickname,
  }) {
    return Character(
      id: id ?? this.id,
      name: name ?? this.name,
      avatar: avatar ?? this.avatar,
      personality: personality ?? this.personality,
      greeting: greeting ?? this.greeting,
      myNickname: myNickname ?? this.myNickname,
      aiNickname: aiNickname ?? this.aiNickname,
    );
  }
}
