/// AI角色模型
/// 定义AI角色的数据结构
class Character {
  final String id;
  final String name;
  final String avatar;
  final String description;
  final String personality;
  final String greeting;
  final List<String> tags;

  Character({
    required this.id,
    required this.name,
    required this.avatar,
    required this.description,
    required this.personality,
    required this.greeting,
    this.tags = const [],
  });

  /// 从JSON创建角色对象
  factory Character.fromJson(Map<String, dynamic> json) {
    return Character(
      id: json['id'] as String,
      name: json['name'] as String,
      avatar: json['avatar'] as String,
      description: json['description'] as String,
      personality: json['personality'] as String,
      greeting: json['greeting'] as String,
      tags: (json['tags'] as List<dynamic>?)?.cast<String>() ?? [],
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
    };
  }

  /// 创建副本
  Character copyWith({
    String? id,
    String? name,
    String? avatar,
    String? description,
    String? personality,
    String? greeting,
    List<String>? tags,
  }) {
    return Character(
      id: id ?? this.id,
      name: name ?? this.name,
      avatar: avatar ?? this.avatar,
      description: description ?? this.description,
      personality: personality ?? this.personality,
      greeting: greeting ?? this.greeting,
      tags: tags ?? this.tags,
    );
  }
}
