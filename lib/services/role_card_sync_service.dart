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
  final int localized;
  final int removed;

  const RoleCardSyncResult({
    required this.inserted,
    required this.updated,
    this.localized = 0,
    this.removed = 0,
  });

  int get total => inserted + updated + localized + removed;
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
      final file = await remoteDb.getDatabaseForWrite(
        RemoteDatabaseKind.roleCard,
      );
      final remoteId = await _remoteIdForCharacter(character, session);
      print(
        '[RoleCardSync] 发布角色卡: remoteId=$remoteId, name=${character.name}, owner=${session.username}',
      );
      final db = await databaseFactory.openDatabase(file.path);
      try {
        await db.insert('shared_role_cards', {
          'remote_id': remoteId,
          'owner_username': session.username,
          'name': character.name,
          'avatar': character.avatar,
          'personality': character.personality,
          'greeting': character.greeting,
          'my_nickname': character.myNickname,
          'ai_nickname': character.aiNickname,
        }, conflictAlgorithm: ConflictAlgorithm.replace);
      } finally {
        await db.close();
      }
      await webDav.upload(
        WebDavConfig.roleCardDbPath,
        file,
        lockToken: lockToken,
      );
      await _upsertSyncMeta(character.id, remoteId, session.username);
    });
  }

  /// 同步删除本地角色对应的共享角色卡。
  ///
  /// 默认仅删除当前登录用户发布的卡；远程角色页删除时可关闭该限制，按
  /// remote_id 删除对应远程记录。
  /// 该方法在删除本地角色前调用，默认先尝试清理远端，再由外部删本地。
  Future<int> deleteRemoteCardsByLocalIds(
    List<int> localIds, {
    bool ownedOnly = true,
  }) async {
    if (localIds.isEmpty) return 0;

    final session = await _requireSession();
    final metas = await _metasByLocalIds(localIds);
    final rowsToDelete = ownedOnly
        ? metas
              .where((m) => (m['owner_username'] as String?) == session.username)
              .toList()
        : metas;
    if (rowsToDelete.isEmpty) return 0;

    final remoteIds = rowsToDelete
        .map((m) => m['remote_id'])
        .whereType<String>()
        .toSet()
        .toList();

    int deleted = 0;
    await webDav.withLock(WebDavConfig.roleCardDbPath, (lockToken) async {
      final file = await remoteDb.getDatabaseForWrite(
        RemoteDatabaseKind.roleCard,
      );
      final db = await databaseFactory.openDatabase(file.path);
      try {
        for (final remoteId in remoteIds) {
          final removed = await db.delete(
            'shared_role_cards',
            where: 'remote_id = ?',
            whereArgs: [remoteId],
          );
          deleted += removed;
        }
      } finally {
        await db.close();
      }
      await webDav.upload(
        WebDavConfig.roleCardDbPath,
        file,
        lockToken: lockToken,
      );
    });

    print('[RoleCardSync] 清理远程角色卡: 删除 ${remoteIds.length} 条, 实际受影响 $deleted 条');
    return deleted;
  }

  /// 同步共享区角色卡到本地
  Future<RoleCardSyncResult> syncRemoteToLocal() async {
    final session = await _requireSession();
    print(
      '[RoleCardSync] 开始同步共享角色卡: user=${session.username}, remotePath=${WebDavConfig.roleCardDbPath}',
    );
    final file = await remoteDb.getDatabase(RemoteDatabaseKind.roleCard);
    print('[RoleCardSync] 远程角色卡数据库已下载: ${file.path}');
    final db = await databaseFactory.openDatabase(file.path);
    var inserted = 0;
    var updated = 0;
    var localized = 0;
    var removed = 0;
    final remoteIds = <String>{};
    try {
      final rows = await db.query('shared_role_cards');
      print('[RoleCardSync] shared_role_cards 行数: ${rows.length}');
      for (final row in rows) {
        print(
          '[RoleCardSync] 读取远程角色卡行: remote_id=${row['remote_id']}, owner=${row['owner_username']}, name=${row['name']}',
        );
        final remote = RemoteRoleCard.fromRow(row);
        remoteIds.add(remote.remoteId);
        final meta = await _metaByRemoteId(remote.remoteId);
        if (meta == null) {
          final localId = await characterStorage.save(
            remote.character.copyWith(id: 0),
          );
          await _upsertSyncMeta(localId, remote.remoteId, remote.ownerUsername);
          print(
            '[RoleCardSync] 新增远程角色到本地: remoteId=${remote.remoteId}, localId=$localId, name=${remote.character.name}',
          );
          inserted++;
          continue;
        }
        final localId = meta['local_character_id'] as int;
        await characterStorage.save(remote.character.copyWith(id: localId));
        await _upsertSyncMeta(localId, remote.remoteId, remote.ownerUsername);
        print(
          '[RoleCardSync] 更新本地远程角色: remoteId=${remote.remoteId}, localId=$localId, name=${remote.character.name}',
        );
        updated++;
      }
    } finally {
      await db.close();
    }
    final cleanup = await _reconcileDeletedRemoteCards(remoteIds);
    localized = cleanup.localized;
    removed = cleanup.removed;

    print(
      '[RoleCardSync] 同步完成: inserted=$inserted, updated=$updated, localized=$localized, removed=$removed',
    );
    return RoleCardSyncResult(
      inserted: inserted,
      updated: updated,
      localized: localized,
      removed: removed,
    );
  }

  Future<UserSession> _requireSession() async {
    final session = authService.session ?? await authService.loadSession();
    if (session == null) throw const AuthException('请先登录');
    return session;
  }

  Future<String> _remoteIdForCharacter(
    Character character,
    UserSession session,
  ) async {
    final db = DatabaseHelper().db;
    final rows = await db.query(
      'character_sync_meta',
      columns: ['remote_id'],
      where: 'local_character_id = ?',
      whereArgs: [character.id],
      limit: 1,
    );
    if (rows.isNotEmpty) return rows.first['remote_id'] as String;
    return '${session.username}_${character.id}_${DateTime.now().microsecondsSinceEpoch}';
  }

  Future<Map<String, Object?>?> _metaByRemoteId(String remoteId) async {
    final rows = await DatabaseHelper().db.query(
      'character_sync_meta',
      where: 'remote_id = ?',
      whereArgs: [remoteId],
      limit: 1,
    );
    return rows.isEmpty ? null : rows.first;
  }

  Future<List<Map<String, Object?>>> _metasByLocalIds(
    List<int> localIds,
  ) async {
    if (localIds.isEmpty) return [];

    final placeholders = List.filled(localIds.length, '?').join(',');
    final rows = await DatabaseHelper().db.rawQuery(
      'SELECT local_character_id, remote_id, owner_username FROM character_sync_meta WHERE local_character_id IN ($placeholders)',
      localIds,
    );
    return rows;
  }

  Future<_DeletedRemoteCardCleanup> _reconcileDeletedRemoteCards(
    Set<String> remoteIds,
  ) async {
    final metas = await _allSyncMetas();
    var localized = 0;
    var removed = 0;

    for (final meta in metas) {
      final remoteId = meta['remote_id'] as String;
      if (remoteIds.contains(remoteId)) continue;

      final localId = meta['local_character_id'] as int;
      final hasChatRecords = await _hasChatRecords(localId);
      if (hasChatRecords) {
        await _deleteSyncMeta(localId);
        localized++;
      } else {
        await characterStorage.delete(localId);
        removed++;
      }
    }

    return _DeletedRemoteCardCleanup(localized: localized, removed: removed);
  }

  Future<List<Map<String, Object?>>> _allSyncMetas() async {
    return DatabaseHelper().db.query(
      'character_sync_meta',
      columns: ['local_character_id', 'remote_id', 'owner_username'],
    );
  }

  Future<bool> _hasChatRecords(int localId) async {
    final rows = await DatabaseHelper().db.rawQuery(
      'SELECT COUNT(*) AS count FROM sessions WHERE character_id = ?',
      [localId],
    );
    final count = rows.first['count'] as int? ?? 0;
    return count > 0;
  }

  Future<void> _deleteSyncMeta(int localId) async {
    await DatabaseHelper().db.delete(
      'character_sync_meta',
      where: 'local_character_id = ?',
      whereArgs: [localId],
    );
  }

  Future<void> _upsertSyncMeta(
    int localId,
    String remoteId,
    String ownerUsername,
  ) async {
    await DatabaseHelper().db.insert('character_sync_meta', {
      'local_character_id': localId,
      'remote_id': remoteId,
      'owner_username': ownerUsername,
      'last_synced_at': DateTime.now().toIso8601String(),
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }
}

class _DeletedRemoteCardCleanup {
  final int localized;
  final int removed;

  const _DeletedRemoteCardCleanup({
    required this.localized,
    required this.removed,
  });
}
