// Anthropic API 请求/响应数据模型

/// 消息内容块
class AnthropicContent {
  final String type;
  final String text;

  AnthropicContent({required this.type, required this.text});

  factory AnthropicContent.fromJson(Map<String, dynamic> json) {
    return AnthropicContent(
      type: json['type']?.toString() ?? '',
      text: json['text']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {'type': type, 'text': text};
}

/// 单条消息
class AnthropicMessage {
  final String role;
  final List<AnthropicContent> content;

  AnthropicMessage({required this.role, required this.content});

  factory AnthropicMessage.fromJson(Map<String, dynamic> json) {
    return AnthropicMessage(
      role: json['role'] as String,
      content: (json['content'] as List)
          .map((e) => AnthropicContent.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
    'role': role,
    'content': content.map((e) => e.toJson()).toList(),
  };
}

/// API 请求体
class AnthropicRequest {
  final String model;
  final int maxTokens;
  final List<AnthropicMessage> messages;
  final String? system;

  AnthropicRequest({
    required this.model,
    this.maxTokens = 1024,
    required this.messages,
    this.system,
  });

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{
      'model': model,
      'max_tokens': maxTokens,
      'messages': messages.map((e) => e.toJson()).toList(),
    };
    if (system != null) json['system'] = system;
    return json;
  }
}

/// API 响应体
class AnthropicResponse {
  final String id;
  final String type;
  final String role;
  final List<AnthropicContent> content;
  final String model;
  final String stopReason;

  AnthropicResponse({
    required this.id,
    required this.type,
    required this.role,
    required this.content,
    required this.model,
    required this.stopReason,
  });

  factory AnthropicResponse.fromJson(Map<String, dynamic> json) {
    return AnthropicResponse(
      id: json['id']?.toString() ?? '',
      type: json['type']?.toString() ?? '',
      role: json['role']?.toString() ?? '',
      content: (json['content'] as List)
          .map((e) => AnthropicContent.fromJson(e as Map<String, dynamic>))
          .toList(),
      model: json['model']?.toString() ?? '',
      stopReason: json['stop_reason']?.toString() ?? '',
    );
  }

  /// 获取回复文本
  String get text => content.map((e) => e.text).join();
}
