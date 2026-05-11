/// AI角色模型
/// 定义AI角色的数据结构
class Character {
  final int id;
  final String name;
  final String avatar;
  final String description;
  final String personality;
  final String greeting;
  final List<String> tags;
  final String myNickname;
  final String aiNickname;

  Character({
    required this.id,
    required this.name,
    required this.avatar,
    required this.description,
    required this.personality,
    required this.greeting,
    this.tags = const [],
    this.myNickname = '冒险者',
    this.aiNickname = '',
  });

  /// 从JSON创建角色对象
  factory Character.fromJson(Map<String, dynamic> json) {
    return Character(
      id: json['id'] as int,
      name: json['name'] as String,
      avatar: json['avatar'] as String,
      description: json['description'] as String,
      personality: json['personality'] as String,
      greeting: json['greeting'] as String,
      tags: (json['tags'] as List<dynamic>?)?.cast<String>() ?? [],
      myNickname: json['myNickname'] as String? ?? '冒险者',
      aiNickname: json['aiNickname'] as String? ?? '',
    );
  }

  /// 转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'avatar': avatar,
      'description': description,
      'personality': personality,
      'greeting': greeting,
      'tags': tags,
      'myNickname': myNickname,
      'aiNickname': aiNickname,
    };
  }

  /// 创建副本
  Character copyWith({
    int? id,
    String? name,
    String? avatar,
    String? description,
    String? personality,
    String? greeting,
    List<String>? tags,
    String? myNickname,
    String? aiNickname,
  }) {
    return Character(
      id: id ?? this.id,
      name: name ?? this.name,
      avatar: avatar ?? this.avatar,
      description: description ?? this.description,
      personality: personality ?? this.personality,
      greeting: greeting ?? this.greeting,
      tags: tags ?? this.tags,
      myNickname: myNickname ?? this.myNickname,
      aiNickname: aiNickname ?? this.aiNickname,
    );
  }
}
