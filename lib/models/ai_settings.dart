/// API 配置模型
/// 一套完整的 API 配置（名称、地址、密钥、模型、推理模式）
class ApiConfig {
  final String name;
  final String baseUrl;
  final String apiKey;
  final String model;
  final bool reasoningEnabled;
  final int reasoningBudgetTokens;

  const ApiConfig({
    this.name = 'Default',
    this.baseUrl = 'https://api.anthropic.com',
    this.apiKey = '',
    this.model = 'claude-sonnet-4-20250514',
    this.reasoningEnabled = false,
    this.reasoningBudgetTokens = 4000,
  });

  factory ApiConfig.fromJson(Map<String, dynamic> json) {
    return ApiConfig(
      name: json['name'] as String? ?? 'Default',
      baseUrl: json['baseUrl'] as String? ?? 'https://api.anthropic.com',
      apiKey: json['apiKey'] as String? ?? '',
      model: json['model'] as String? ?? 'claude-sonnet-4-20250514',
      reasoningEnabled: json['reasoningEnabled'] as bool? ?? false,
      reasoningBudgetTokens: json['reasoningBudgetTokens'] as int? ?? 4000,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'baseUrl': baseUrl,
      'apiKey': apiKey,
      'model': model,
      'reasoningEnabled': reasoningEnabled,
      'reasoningBudgetTokens': reasoningBudgetTokens,
    };
  }

  ApiConfig copyWith({
    String? name,
    String? baseUrl,
    String? apiKey,
    String? model,
    bool? reasoningEnabled,
    int? reasoningBudgetTokens,
  }) {
    return ApiConfig(
      name: name ?? this.name,
      baseUrl: baseUrl ?? this.baseUrl,
      apiKey: apiKey ?? this.apiKey,
      model: model ?? this.model,
      reasoningEnabled: reasoningEnabled ?? this.reasoningEnabled,
      reasoningBudgetTokens: reasoningBudgetTokens ?? this.reasoningBudgetTokens,
    );
  }

  bool get isConfigured => apiKey.isNotEmpty;
}

/// AI 设置模型
/// 存储多套 API 配置，支持切换
class AiSettings {
  final List<ApiConfig> configs;
  final int activeConfigIndex;

  AiSettings({
    List<ApiConfig>? configs,
    this.activeConfigIndex = 0,
  }) : configs = configs ?? [const ApiConfig()];

  ApiConfig get activeConfig =>
      configs.isNotEmpty ? configs[activeConfigIndex.clamp(0, configs.length - 1)] : const ApiConfig();

  // 向后兼容 getter
  String get baseUrl => activeConfig.baseUrl;
  String get apiKey => activeConfig.apiKey;
  String get model => activeConfig.model;
  bool get reasoningEnabled => activeConfig.reasoningEnabled;
  int get reasoningBudgetTokens => activeConfig.reasoningBudgetTokens;
  bool get isConfigured => activeConfig.isConfigured;

  factory AiSettings.fromJson(Map<String, dynamic> json) {
    final configsList = json['configs'] as List<dynamic>?;
    List<ApiConfig> configs;
    if (configsList != null && configsList.isNotEmpty) {
      configs = configsList.map((c) => ApiConfig.fromJson(c as Map<String, dynamic>)).toList();
    } else {
      // 兼容旧数据格式：单套配置
      configs = [
        ApiConfig(
          name: 'Default',
          baseUrl: json['baseUrl'] as String? ?? 'https://api.anthropic.com',
          apiKey: json['apiKey'] as String? ?? '',
          model: json['model'] as String? ?? 'claude-sonnet-4-20250514',
        ),
      ];
    }
    return AiSettings(
      configs: configs,
      activeConfigIndex: (json['activeConfigIndex'] as int?) ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'configs': configs.map((c) => c.toJson()).toList(),
      'activeConfigIndex': activeConfigIndex,
    };
  }

  AiSettings copyWith({
    List<ApiConfig>? configs,
    int? activeConfigIndex,
  }) {
    return AiSettings(
      configs: configs ?? this.configs,
      activeConfigIndex: activeConfigIndex ?? this.activeConfigIndex,
    );
  }
}
