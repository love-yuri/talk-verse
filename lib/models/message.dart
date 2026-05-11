/// 聊天消息模型
/// 定义消息的数据结构
class Message {
  final int id;
  final String content;
  final MessageType type;
  final DateTime timestamp;
  final bool isRead;
  final MessageStatus status;

  Message({
    required this.id,
    required this.content,
    required this.type,
    required this.timestamp,
    this.isRead = false,
    this.status = MessageStatus.sent,
  });

  /// 从JSON创建消息对象
  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'] as int,
      content: json['content'] as String,
      type: MessageType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => MessageType.user,
      ),
      timestamp: DateTime.parse(json['timestamp'] as String),
      isRead: json['isRead'] as bool? ?? false,
      status: MessageStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => MessageStatus.sent,
      ),
    );
  }

  /// 转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'type': type.name,
      'timestamp': timestamp.toIso8601String(),
      'isRead': isRead,
      'status': status.name,
    };
  }

  /// 创建副本
  Message copyWith({
    int? id,
    String? content,
    MessageType? type,
    DateTime? timestamp,
    bool? isRead,
    MessageStatus? status,
  }) {
    return Message(
      id: id ?? this.id,
      content: content ?? this.content,
      type: type ?? this.type,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
      status: status ?? this.status,
    );
  }
}

/// 消息类型枚举
enum MessageType {
  user, // 用户消息
  ai, // AI消息
  system, // 系统消息
  typing, // 正在输入指示器
}

/// 消息发送状态枚举
enum MessageStatus {
  sending, // 发送中
  sent, // 已发送成功
  failed, // 发送失败
}
