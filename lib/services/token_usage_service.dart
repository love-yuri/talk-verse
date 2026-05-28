import 'package:sqflite/sqflite.dart';
import '../models/token_record.dart';
import 'database_helper.dart';

/// Token 用量持久化服务（SQLite 版）
class TokenUsageService {
  static final TokenUsageService _instance = TokenUsageService._();
  TokenUsageService._();
  factory TokenUsageService() => _instance;

  /// 加载所有 Token 记录
  Future<List<TokenRecord>> load() async {
    final db = DatabaseHelper().db;
    final rows = await db.query('token_records', orderBy: 'timestamp DESC');
    return rows.map(_rowToRecord).toList();
  }

  /// 分页加载 Token 记录（懒加载）
  Future<List<TokenRecord>> loadPage({int limit = 30, int offset = 0}) async {
    final db = DatabaseHelper().db;
    final rows = await db.query(
      'token_records',
      orderBy: 'timestamp DESC',
      limit: limit,
      offset: offset,
    );
    return rows.map(_rowToRecord).toList();
  }

  /// 加载聚合统计信息
  Future<TokenUsageSummary> loadSummary() async {
    final db = DatabaseHelper().db;
    final rows = await db.rawQuery('''
      SELECT
        COALESCE(SUM(input_tokens), 0) AS input_tokens,
        COALESCE(SUM(cache_read_tokens), 0) AS cache_read_tokens,
        COALESCE(SUM(cache_create_tokens), 0) AS cache_create_tokens,
        COALESCE(SUM(output_tokens), 0) AS output_tokens,
        COUNT(1) AS record_count
      FROM token_records
    ''');

    final row = rows.first;
    return TokenUsageSummary(
      inputTokens: (row['input_tokens'] as num?)?.toInt() ?? 0,
      cacheReadTokens: (row['cache_read_tokens'] as num?)?.toInt() ?? 0,
      cacheCreateTokens: (row['cache_create_tokens'] as num?)?.toInt() ?? 0,
      outputTokens: (row['output_tokens'] as num?)?.toInt() ?? 0,
      recordCount: (row['record_count'] as num?)?.toInt() ?? 0,
    );
  }

  /// 添加一条 Token 记录
  Future<void> addRecord(TokenRecord record) async {
    final db = DatabaseHelper().db;
    await db.insert('token_records', {
      'session_id': record.sessionId,
      'character_name': record.characterName,
      'timestamp': record.timestamp.toIso8601String(),
      'input_tokens': record.inputTokens,
      'cache_read_tokens': record.cacheReadTokens,
      'cache_create_tokens': record.cacheCreateTokens,
      'output_tokens': record.outputTokens,
      'model': record.model,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  /// 清空所有记录
  Future<void> clear() async {
    final db = DatabaseHelper().db;
    await db.delete('token_records');
  }

  /// 获取某个会话的所有记录
  Future<List<TokenRecord>> recordsForSession(int sessionId) async {
    final db = DatabaseHelper().db;
    final rows = await db.query(
      'token_records',
      where: 'session_id = ?',
      whereArgs: [sessionId],
      orderBy: 'timestamp DESC',
    );
    return rows.map(_rowToRecord).toList();
  }

  TokenRecord _rowToRecord(Map<String, dynamic> r) {
    return TokenRecord(
      id: r['id'] as int,
      sessionId: r['session_id'] as int,
      characterName: r['character_name'] as String,
      timestamp: DateTime.parse(r['timestamp'] as String),
      inputTokens: r['input_tokens'] as int,
      cacheReadTokens: r['cache_read_tokens'] as int? ?? 0,
      cacheCreateTokens: r['cache_create_tokens'] as int? ?? 0,
      outputTokens: r['output_tokens'] as int,
      model: r['model'] as String,
    );
  }
}

/// Token 用量聚合数据
class TokenUsageSummary {
  final int inputTokens;
  final int cacheReadTokens;
  final int cacheCreateTokens;
  final int outputTokens;
  final int recordCount;

  const TokenUsageSummary({
    required this.inputTokens,
    required this.cacheReadTokens,
    required this.cacheCreateTokens,
    required this.outputTokens,
    required this.recordCount,
  });

  int get totalTokens =>
      inputTokens + cacheReadTokens + cacheCreateTokens + outputTokens;

  static const empty = TokenUsageSummary(
    inputTokens: 0,
    cacheReadTokens: 0,
    cacheCreateTokens: 0,
    outputTokens: 0,
    recordCount: 0,
  );
}
