import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../models/ai_settings.dart';
import '../models/user_session.dart';
import 'remote_database_service.dart';
import 'settings_service.dart';

/// 登录认证异常
class AuthException implements Exception {
  final String message;
  final Object? cause;

  const AuthException(this.message, [this.cause]);

  @override
  String toString() => message;
}

/// 登录认证与会话服务
class AuthService {
  static const _sessionKey = 'auth_session';
  static final AuthService _instance = AuthService._();
  AuthService._();
  factory AuthService() => _instance;

  final _remoteDb = RemoteDatabaseService();
  UserSession? _session;

  UserSession? get session => _session;
  bool get isLoggedIn => _session != null;

  /// 加载本地登录会话
  Future<UserSession?> loadSession() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_sessionKey);
    if (raw == null) {
      _session = null;
      return null;
    }
    try {
      _session = UserSession.fromJson(jsonDecode(raw) as Map<String, dynamic>);
      return _session;
    } on Object {
      await prefs.remove(_sessionKey);
      _session = null;
      return null;
    }
  }

  /// 登录并拉取云端 AI 设置
  Future<UserSession> login(String username, String password) async {
    final trimmedUsername = username.trim();
    if (trimmedUsername.isEmpty || password.isEmpty) {
      throw const AuthException('请输入账号和密码');
    }

    try {
      final file = await _remoteDb.getDatabase(RemoteDatabaseKind.system);
      final db = await databaseFactory.openDatabase(file.path);
      try {
        final users = await db.query(
          'users',
          where: 'username = ?',
          whereArgs: [trimmedUsername],
          limit: 1,
        );
        if (users.isEmpty) throw const AuthException('账号或密码错误');
        final user = users.first;
        if ((user['password'] as String? ?? '') != password) throw const AuthException('账号或密码错误');

        final session = UserSession(
          userId: user['id'] as int,
          username: user['username'] as String,
          loginAt: DateTime.now(),
        );
        await _saveSession(session);

        final settingRows = await db.query(
          'user_ai_settings',
          columns: ['ai_settings_json'],
          where: 'user_id = ?',
          whereArgs: [session.userId],
          limit: 1,
        );
        if (settingRows.isNotEmpty) {
          final settingsJson = jsonDecode(settingRows.first['ai_settings_json'] as String) as Map<String, dynamic>;
          await SettingsService().save(AiSettings.fromJson(settingsJson));
        }

        return session;
      } finally {
        await db.close();
      }
    } on AuthException {
      rethrow;
    } on Object catch (e) {
      throw AuthException('登录失败：$e', e);
    }
  }

  /// 退出登录
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_sessionKey);
    _session = null;
  }

  Future<void> _saveSession(UserSession session) async {
    _session = session;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_sessionKey, jsonEncode(session.toJson()));
  }
}
