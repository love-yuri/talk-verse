// Anthropic API 请求/响应数据模型

/// 消息内容块
class AnthropicContent {
  final String type;
  final String text;
  final String? id;
  final String? name;
  final Map<String, dynamic>? input;

  AnthropicContent({
    required this.type,
    this.text = '',
    this.id,
    this.name,
    this.input,
  });

  factory AnthropicContent.fromJson(Map<String, dynamic> json) {
    return AnthropicContent(
      type: json['type']?.toString() ?? '',
      text: json['text']?.toString() ?? '',
      id: json['id']?.toString(),
      name: json['name']?.toString(),
      input: json['input'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{'type': type};
    if (text.isNotEmpty) json['text'] = text;
    if (id != null) json['id'] = id;
    if (name != null) json['name'] = name;
    if (input != null) json['input'] = input;
    return json;
  }
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
  final bool thinkingEnabled;
  final int thinkingBudgetTokens;
  final List<Map<String, dynamic>>? tools;
  final double? temperature;
  final double? topP;
  final int? topK;

  AnthropicRequest({
    required this.model,
    this.maxTokens = 1024,
    required this.messages,
    this.system,
    this.thinkingEnabled = false,
    this.thinkingBudgetTokens = 4000,
    this.tools,
    this.temperature,
    this.topP,
    this.topK,
  });

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{
      'model': model,
      'max_tokens': maxTokens,
      'messages': messages.map((e) => e.toJson()).toList(),
    };
    if (system != null) json['system'] = system;
    if (temperature != null) json['temperature'] = temperature;
    if (topP != null) json['top_p'] = topP;
    if (topK != null) json['top_k'] = topK;
    if (thinkingEnabled) {
      json['thinking'] = {
        'type': 'enabled',
        'budget_tokens': thinkingBudgetTokens,
      };
    }
    if (tools != null && tools!.isNotEmpty) {
      json['tools'] = tools;
    }
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
