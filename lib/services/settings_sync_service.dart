import 'dart:convert';

import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../constants/webdav_config.dart';
import '../models/ai_settings.dart';
import '../models/user_session.dart';
import 'auth_service.dart';
import 'remote_database_service.dart';
import 'settings_service.dart';
import 'webdav_service.dart';

/// 云端设置同步服务
class SettingsSyncService {
  final AuthService authService;
  final WebDavService webDav;
  final RemoteDatabaseService remoteDb;

  SettingsSyncService({AuthService? authService, WebDavService? webDav, RemoteDatabaseService? remoteDb})
    : authService = authService ?? AuthService(),
      webDav = webDav ?? WebDavService(),
      remoteDb = remoteDb ?? RemoteDatabaseService();

  /// 拉取当前登录用户的云端 AI 设置
  Future<AiSettings?> pullAiSettingsForCurrentUser() async {
    final session = await _requireSession();
    final file = await remoteDb.getDatabase(RemoteDatabaseKind.system);
    final db = await databaseFactory.openDatabase(file.path);
    try {
      final rows = await db.query(
        'user_ai_settings',
        columns: ['ai_settings_json'],
        where: 'user_id = ?',
        whereArgs: [session.userId],
        limit: 1,
      );
      if (rows.isEmpty) return null;
      final json = jsonDecode(rows.first['ai_settings_json'] as String) as Map<String, dynamic>;
      final settings = AiSettings.fromJson(json);
      await SettingsService().save(settings);
      return settings;
    } finally {
      await db.close();
    }
  }

  /// 推送当前 AI 设置到云端
  Future<void> pushAiSettings(AiSettings settings) async {
    final session = await _requireSession();
    await webDav.withLock(WebDavConfig.systemDbPath, (lockToken) async {
      final file = await remoteDb.getDatabaseForWrite(RemoteDatabaseKind.system);
      final db = await databaseFactory.openDatabase(file.path);
      try {
        final users = await db.query('users', where: 'id = ? AND username = ?', whereArgs: [session.userId, session.username], limit: 1);
        if (users.isEmpty) throw const AuthException('云端账号不存在，请重新登录');
        await db.insert(
          'user_ai_settings',
          {
            'user_id': session.userId,
            'ai_settings_json': jsonEncode(settings.toJson()),
            'updated_at': DateTime.now().toIso8601String(),
          },
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      } finally {
        await db.close();
      }
      await webDav.upload(WebDavConfig.systemDbPath, file, lockToken: lockToken);
    });
  }

  Future<UserSession> _requireSession() async {
    final session = authService.session ?? await authService.loadSession();
    if (session == null) throw const AuthException('请先登录');
    return session;
  }
}
