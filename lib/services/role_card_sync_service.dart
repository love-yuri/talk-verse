import 'dart:convert';

import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../constants/webdav_config.dart';
import '../models/character.dart';
import '../models/remote_role_card.dart';
import '../models/user_session.dart';
import 'auth_service.dart';
import 'character_storage_service.dart';
import 'database_helper.dart';
import 'remote_database_service.dart';
import 'webdav_service.dart';

/// 角色卡同步结果
class RoleCardSyncResult {
  final int inserted;
  final int updated;

  const RoleCardSyncResult({required this.inserted, required this.updated});

  int get total => inserted + updated;
}

/// 共享角色卡同步服务
class RoleCardSyncService {
  final AuthService authService;
  final CharacterStorageService characterStorage;
  final WebDavService webDav;
  final RemoteDatabaseService remoteDb;

  RoleCardSyncService({
    AuthService? authService,
    CharacterStorageService? characterStorage,
    WebDavService? webDav,
    RemoteDatabaseService? remoteDb,
  }) : authService = authService ?? AuthService(),
       characterStorage = characterStorage ?? CharacterStorageService(),
       webDav = webDav ?? WebDavService(),
       remoteDb = remoteDb ?? RemoteDatabaseService();

  /// 发布本地角色卡到共享区
  Future<void> publish(Character character) async {
    final session = await _requireSession();
    await webDav.withLock(WebDavConfig.roleCardDbPath, (lockToken) async {
      final file = await remoteDb.getDatabaseForWrite(RemoteDatabaseKind.roleCard);
      final remoteId = await _remoteIdForCharacter(character, session);
      final characterJson = jsonEncode(character.toJson());
      final db = await databaseFactory.openDatabase(file.path);
      try {
        await db.insert(
          'shared_role_cards',
          {
            'remote_id': remoteId,
            'owner_username': session.username,
            'name': character.name,
            'avatar': character.avatar,
            'personality': character.personality,
            'greeting': character.greeting,
            'my_nickname': character.myNickname,
            'ai_nickname': character.aiNickname,
            'character_json': characterJson,
          },
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      } finally {
        await db.close();
      }
      await webDav.upload(WebDavConfig.roleCardDbPath, file, lockToken: lockToken);
      await _upsertSyncMeta(character.id, remoteId, session.username);
    });
  }

  /// 同步共享区角色卡到本地
  Future<RoleCardSyncResult> syncRemoteToLocal() async {
    await _requireSession();
    final file = await remoteDb.getDatabase(RemoteDatabaseKind.roleCard);
    final db = await databaseFactory.openDatabase(file.path);
    var inserted = 0;
    var updated = 0;
    try {
      final rows = await db.query('shared_role_cards');
      for (final row in rows) {
        final remote = RemoteRoleCard.fromRow(row);
        final meta = await _metaByRemoteId(remote.remoteId);
        if (meta == null) {
          final localId = await characterStorage.save(remote.character.copyWith(id: 0));
          await _upsertSyncMeta(localId, remote.remoteId, remote.ownerUsername);
          inserted++;
          continue;
        }
        final localId = meta['local_character_id'] as int;
        await characterStorage.save(remote.character.copyWith(id: localId));
        await _upsertSyncMeta(localId, remote.remoteId, remote.ownerUsername);
        updated++;
      }
    } finally {
      await db.close();
    }
    return RoleCardSyncResult(inserted: inserted, updated: updated);
  }

  Future<UserSession> _requireSession() async {
    final session = authService.session ?? await authService.loadSession();
    if (session == null) throw const AuthException('请先登录');
    return session;
  }

  Future<String> _remoteIdForCharacter(Character character, UserSession session) async {
    final db = DatabaseHelper().db;
    final rows = await db.query('character_sync_meta', columns: ['remote_id'], where: 'local_character_id = ?', whereArgs: [character.id], limit: 1);
    if (rows.isNotEmpty) return rows.first['remote_id'] as String;
    return '${session.username}_${character.id}_${DateTime.now().microsecondsSinceEpoch}';
  }

  Future<Map<String, Object?>?> _metaByRemoteId(String remoteId) async {
    final rows = await DatabaseHelper().db.query('character_sync_meta', where: 'remote_id = ?', whereArgs: [remoteId], limit: 1);
    return rows.isEmpty ? null : rows.first;
  }

  Future<void> _upsertSyncMeta(int localId, String remoteId, String ownerUsername) async {
    await DatabaseHelper().db.insert(
      'character_sync_meta',
      {
        'local_character_id': localId,
        'remote_id': remoteId,
        'owner_username': ownerUsername,
        'last_synced_at': DateTime.now().toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
}
