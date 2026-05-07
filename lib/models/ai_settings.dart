/// AI 设置模型
/// 存储 AI 服务的配置信息
class AiSettings {
  final String baseUrl;
  final String apiKey;
  final String model;

  AiSettings({
    this.baseUrl = 'https://api.anthropic.com',
    this.apiKey = '',
    this.model = 'claude-sonnet-4-20250514',
  });

  /// 从JSON创建设置对象
  factory AiSettings.fromJson(Map<String, dynamic> json) {
    return AiSettings(
      baseUrl: json['baseUrl'] as String? ?? 'https://api.anthropic.com',
      apiKey: json['apiKey'] as String? ?? '',
      model: json['model'] as String? ?? 'claude-sonnet-4-20250514',
    );
  }

  /// 转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'baseUrl': baseUrl,
      'apiKey': apiKey,
      'model': model,
    };
  }

  /// 创建副本
  AiSettings copyWith({
    String? baseUrl,
    String? apiKey,
    String? model,
  }) {
    return AiSettings(
      baseUrl: baseUrl ?? this.baseUrl,
      apiKey: apiKey ?? this.apiKey,
      model: model ?? this.model,
    );
  }

  /// 是否已配置 API Key
  bool get isConfigured => apiKey.isNotEmpty;
}
