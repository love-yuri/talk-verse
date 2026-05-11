import 'message.dart';

/// 聊天会话模型
/// 定义聊天会话的数据结构
class ChatSession {
  final int id;
  final int characterId;
  final String characterName;
  final String characterAvatar;
  final List<Message> messages;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? sceneLocation;
  final String? sceneTime;

  ChatSession({
    required this.id,
    required this.characterId,
    required this.characterName,
    required this.characterAvatar,
    this.messages = const [],
    required this.createdAt,
    required this.updatedAt,
    this.sceneLocation,
    this.sceneTime,
  });

  /// 从JSON创建会话对象
  factory ChatSession.fromJson(Map<String, dynamic> json) {
    return ChatSession(
      id: json['id'] as int,
      characterId: json['characterId'] as int,
      characterName: json['characterName'] as String,
      characterAvatar: json['characterAvatar'] as String,
      messages: (json['messages'] as List<dynamic>?)
              ?.map((e) => Message.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      sceneLocation: json['sceneLocation'] as String?,
      sceneTime: json['sceneTime'] as String?,
    );
  }

  /// 转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'characterId': characterId,
      'characterName': characterName,
      'characterAvatar': characterAvatar,
      'messages': messages.map((e) => e.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      if (sceneLocation != null) 'sceneLocation': sceneLocation,
      if (sceneTime != null) 'sceneTime': sceneTime,
    };
  }

  /// 获取最后一条消息
  Message? get lastMessage => messages.isNotEmpty ? messages.last : null;

  /// 获取未读消息数量
  int get unreadCount => messages.where((m) => !m.isRead && m.type == MessageType.ai).length;

  /// 创建副本
  ChatSession copyWith({
    int? id,
    int? characterId,
    String? characterName,
    String? characterAvatar,
    List<Message>? messages,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? sceneLocation,
    String? sceneTime,
  }) {
    return ChatSession(
      id: id ?? this.id,
      characterId: characterId ?? this.characterId,
      characterName: characterName ?? this.characterName,
      characterAvatar: characterAvatar ?? this.characterAvatar,
      messages: messages ?? this.messages,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      sceneLocation: sceneLocation ?? this.sceneLocation,
      sceneTime: sceneTime ?? this.sceneTime,
    );
  }
}
