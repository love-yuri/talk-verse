/// Token用量记录模型
class TokenRecord {
  final String id;
  final String sessionId;
  final String characterName;
  final DateTime timestamp;
  final int inputTokens;
  final int cacheReadTokens;
  final int cacheCreateTokens;
  final int outputTokens;
  final String model;

  const TokenRecord({
    required this.id,
    required this.sessionId,
    required this.characterName,
    required this.timestamp,
    required this.inputTokens,
    required this.cacheReadTokens,
    required this.cacheCreateTokens,
    required this.outputTokens,
    required this.model,
  });

  int get totalTokens => inputTokens + cacheReadTokens + cacheCreateTokens + outputTokens;

  factory TokenRecord.fromJson(Map<String, dynamic> json) {
    return TokenRecord(
      id: json['id'] as String,
      sessionId: json['sessionId'] as String,
      characterName: json['characterName'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      inputTokens: json['inputTokens'] as int,
      cacheReadTokens: json['cacheReadTokens'] as int? ?? 0,
      cacheCreateTokens: json['cacheCreateTokens'] as int? ?? 0,
      outputTokens: json['outputTokens'] as int,
      model: json['model'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'sessionId': sessionId,
        'characterName': characterName,
        'timestamp': timestamp.toIso8601String(),
        'inputTokens': inputTokens,
        'cacheReadTokens': cacheReadTokens,
        'cacheCreateTokens': cacheCreateTokens,
        'outputTokens': outputTokens,
        'model': model,
      };
}
