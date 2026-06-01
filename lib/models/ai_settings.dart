/// API 配置模型
/// 一套完整的 API 配置（名称、地址、密钥、模型、推理模式）
class ApiConfig {
  final String name;
  final String baseUrl;
  final String apiKey;
  final String model;
  final bool reasoningEnabled;
  final int reasoningBudgetTokens;
  final double temperature;
  final int maxTokens;
  final double topP;
  final int topK;

  const ApiConfig({
    this.name = 'Default',
    this.baseUrl = 'https://api.anthropic.com',
    this.apiKey = '',
    this.model = 'claude-sonnet-4-20250514',
    this.reasoningEnabled = false,
    this.reasoningBudgetTokens = 4000,
    this.temperature = 1.0,
    this.maxTokens = 1024,
    this.topP = 0.9,
    this.topK = 40,
  });

  factory ApiConfig.fromJson(Map<String, dynamic> json) {
    return ApiConfig(
      name: json['name'] as String? ?? 'Default',
      baseUrl: json['baseUrl'] as String? ?? 'https://api.anthropic.com',
      apiKey: json['apiKey'] as String? ?? '',
      model: json['model'] as String? ?? 'claude-sonnet-4-20250514',
      reasoningEnabled: json['reasoningEnabled'] as bool? ?? false,
      reasoningBudgetTokens: json['reasoningBudgetTokens'] as int? ?? 4000,
      temperature: (json['temperature'] as num?)?.toDouble() ?? 1.0,
      maxTokens: json['maxTokens'] as int? ?? 1024,
      topP: (json['topP'] as num?)?.toDouble() ?? 0.9,
      topK: json['topK'] as int? ?? 40,
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
      'temperature': temperature,
      'maxTokens': maxTokens,
      'topP': topP,
      'topK': topK,
    };
  }

  ApiConfig copyWith({
    String? name,
    String? baseUrl,
    String? apiKey,
    String? model,
    bool? reasoningEnabled,
    int? reasoningBudgetTokens,
    double? temperature,
    int? maxTokens,
    double? topP,
    int? topK,
  }) {
    return ApiConfig(
      name: name ?? this.name,
      baseUrl: baseUrl ?? this.baseUrl,
      apiKey: apiKey ?? this.apiKey,
      model: model ?? this.model,
      reasoningEnabled: reasoningEnabled ?? this.reasoningEnabled,
      reasoningBudgetTokens:
          reasoningBudgetTokens ?? this.reasoningBudgetTokens,
      temperature: temperature ?? this.temperature,
      maxTokens: maxTokens ?? this.maxTokens,
      topP: topP ?? this.topP,
      topK: topK ?? this.topK,
    );
  }

  bool get isConfigured => apiKey.isNotEmpty;
}

/// 头像生成 API 配置
class ImageApiConfig {
  final String baseUrl;
  final String apiKey;
  final String model;
  final String size;
  final String quality;
  final String outputFormat;
  final bool preferBase64;

  const ImageApiConfig({
    this.baseUrl = 'https://api.openai.com',
    this.apiKey = '',
    this.model = 'gpt-image-2',
    this.size = '1024x1024',
    this.quality = 'auto',
    this.outputFormat = 'png',
    this.preferBase64 = true,
  });

  factory ImageApiConfig.fromJson(Map<String, dynamic> json) {
    return ImageApiConfig(
      baseUrl: json['baseUrl'] as String? ?? 'https://api.openai.com',
      apiKey: json['apiKey'] as String? ?? '',
      model: json['model'] as String? ?? 'gpt-image-2',
      size: json['size'] as String? ?? '1024x1024',
      quality: json['quality'] as String? ?? 'auto',
      outputFormat: json['outputFormat'] as String? ?? 'png',
      preferBase64: json['preferBase64'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'baseUrl': baseUrl,
      'apiKey': apiKey,
      'model': model,
      'size': size,
      'quality': quality,
      'outputFormat': outputFormat,
      'preferBase64': preferBase64,
    };
  }

  bool get isConfigured => apiKey.isNotEmpty;
}

/// AI 设置模型
/// 存储多套 API 配置，支持切换
class AiSettings {
  final List<ApiConfig> configs;
  final int activeConfigIndex;
  final ImageApiConfig imageApiConfig;

  AiSettings({
    List<ApiConfig>? configs,
    this.activeConfigIndex = 0,
    ImageApiConfig? imageApiConfig,
  }) : configs = configs ?? [const ApiConfig()],
       imageApiConfig = imageApiConfig ?? const ImageApiConfig();

  ApiConfig get activeConfig => configs.isNotEmpty
      ? configs[activeConfigIndex.clamp(0, configs.length - 1)]
      : const ApiConfig();

  // 向后兼容 getter
  String get baseUrl => activeConfig.baseUrl;
  String get apiKey => activeConfig.apiKey;
  String get model => activeConfig.model;
  bool get reasoningEnabled => activeConfig.reasoningEnabled;
  int get reasoningBudgetTokens => activeConfig.reasoningBudgetTokens;
  double get temperature => activeConfig.temperature;
  int get maxTokens => activeConfig.maxTokens;
  double get topP => activeConfig.topP;
  int get topK => activeConfig.topK;
  bool get isConfigured => activeConfig.isConfigured;

  factory AiSettings.fromJson(Map<String, dynamic> json) {
    final configsList = json['configs'] as List<dynamic>?;
    List<ApiConfig> configs;
    if (configsList != null && configsList.isNotEmpty) {
      configs = configsList
          .map((c) => ApiConfig.fromJson(c as Map<String, dynamic>))
          .toList();
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
      imageApiConfig: ImageApiConfig.fromJson(
        json['imageApiConfig'] as Map<String, dynamic>? ?? const {},
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'configs': configs.map((c) => c.toJson()).toList(),
      'activeConfigIndex': activeConfigIndex,
      'imageApiConfig': imageApiConfig.toJson(),
    };
  }

  AiSettings copyWith({
    List<ApiConfig>? configs,
    int? activeConfigIndex,
    ImageApiConfig? imageApiConfig,
  }) {
    return AiSettings(
      configs: configs ?? this.configs,
      activeConfigIndex: activeConfigIndex ?? this.activeConfigIndex,
      imageApiConfig: imageApiConfig ?? this.imageApiConfig,
    );
  }
}
