import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/token_record.dart';

/// Token用量持久化服务
class TokenUsageService {
  static const _key = 'token_records';
  static final TokenUsageService _instance = TokenUsageService._();
  TokenUsageService._();
  factory TokenUsageService() => _instance;

  List<TokenRecord> _records = [];

  Future<List<TokenRecord>> load() async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString(_key);
    if (json != null) {
      final list = jsonDecode(json) as List<dynamic>;
      _records = list.map((e) => TokenRecord.fromJson(e as Map<String, dynamic>)).toList();
    }
    return _records;
  }

  Future<void> addRecord(TokenRecord record) async {
    _records.insert(0, record); // 最新的在前
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(_records.map((e) => e.toJson()).toList()));
  }

  Future<void> clear() async {
    _records.clear();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }

  /// 获取某个会话的所有记录
  List<TokenRecord> recordsForSession(String sessionId) {
    return _records.where((r) => r.sessionId == sessionId).toList();
  }
}
