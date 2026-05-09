import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/chat_session.dart';

/// 聊天记录持久化服务
/// 使用 SharedPreferences 存储聊天会话列表
class ChatStorageService {
  static const _key = 'chat_sessions';
  static final ChatStorageService _instance = ChatStorageService._();
  ChatStorageService._();
  factory ChatStorageService() => _instance;

  List<ChatSession> _sessions = [];

  /// 加载所有会话
  Future<List<ChatSession>> load() async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString(_key);
    if (json != null) {
      final list = jsonDecode(json) as List<dynamic>;
      _sessions = list
          .map((e) => ChatSession.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    return _sessions;
  }

  /// 保存整个会话列表
  Future<void> save(List<ChatSession> sessions) async {
    _sessions = sessions;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _key,
      jsonEncode(sessions.map((e) => e.toJson()).toList()),
    );
  }

  /// 保存单个会话（存在则更新，不存在则插入）
  Future<void> saveSession(ChatSession session) async {
    final idx = _sessions.indexWhere((s) => s.id == session.id);
    if (idx != -1) {
      _sessions[idx] = session;
    } else {
      _sessions.add(session);
    }
    await save(_sessions);
  }

  /// 删除指定会话
  Future<void> deleteSession(String id) async {
    _sessions.removeWhere((s) => s.id == id);
    await save(_sessions);
  }
}
