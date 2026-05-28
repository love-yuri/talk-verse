import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

import '../constants/webdav_config.dart';
import 'webdav_service.dart';

/// 远程 SQLite 数据库类型
enum RemoteDatabaseKind { system, roleCard }

/// 远程 SQLite 数据库初始化与下载服务
class RemoteDatabaseService {
  final WebDavService webDav;

  RemoteDatabaseService({WebDavService? webDav})
    : webDav = webDav ?? WebDavService();

  /// 获取远程数据库，缺失时自动创建
  Future<File> getDatabase(RemoteDatabaseKind kind) async {
    final remotePath = _remotePath(kind);
    try {
      final file = await webDav.download(remotePath);
      print(
        '[RemoteDatabase] 下载远程数据库成功: kind=$kind, remotePath=$remotePath, localPath=${file.path}, bytes=${await file.length()}',
      );
      await _ensureSchema(kind, file.path);
      return file;
    } on WebDavException catch (e) {
      if (e.statusCode != 404) rethrow;
      print(
        '[RemoteDatabase] 远程数据库不存在，将创建空库: kind=$kind, remotePath=$remotePath',
      );
      return _createRemoteDatabase(kind);
    }
  }

  /// 在锁内获取远程数据库，缺失时自动创建并上传
  Future<File> getDatabaseForWrite(RemoteDatabaseKind kind) async {
    final remotePath = _remotePath(kind);
    try {
      final file = await webDav.download(remotePath);
      print(
        '[RemoteDatabase] 写入前下载远程数据库成功: kind=$kind, remotePath=$remotePath, localPath=${file.path}, bytes=${await file.length()}',
      );
      await _ensureSchema(kind, file.path);
      return file;
    } on WebDavException catch (e) {
      if (e.statusCode != 404) rethrow;
      print(
        '[RemoteDatabase] 写入前发现远程数据库不存在，将创建空库: kind=$kind, remotePath=$remotePath',
      );
      await webDav.ensureRemoteDirectory();
      final file = await _createLocalDatabase(kind);
      await webDav.upload(remotePath, file);
      return file;
    }
  }

  Future<File> _createRemoteDatabase(RemoteDatabaseKind kind) async {
    await webDav.ensureRemoteDirectory();
    final file = await _createLocalDatabase(kind);
    await webDav.upload(_remotePath(kind), file);
    print(
      '[RemoteDatabase] 已创建并上传远程数据库: kind=$kind, remotePath=${_remotePath(kind)}, localPath=${file.path}',
    );
    return file;
  }

  Future<File> _createLocalDatabase(RemoteDatabaseKind kind) async {
    final dir = await getTemporaryDirectory();
    final name = '${DateTime.now().microsecondsSinceEpoch}_${_fileName(kind)}';
    final file = File('${dir.path}${Platform.pathSeparator}$name');
    if (await file.exists()) await file.delete();
    await _ensureSchema(kind, file.path);
    return file;
  }

  Future<void> _ensureSchema(RemoteDatabaseKind kind, String path) async {
    final db = await databaseFactory.openDatabase(path);
    try {
      await db.execute('PRAGMA foreign_keys = ON');
      await db.execute('''
        CREATE TABLE IF NOT EXISTS metadata (
          key TEXT PRIMARY KEY,
          value TEXT NOT NULL
        )
      ''');
      await db.insert(
        'metadata',
        {'key': 'schema_version', 'value': '1'},
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      await db.insert(
        'metadata',
        {'key': 'app', 'value': 'talk-verse'},
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      if (kind == RemoteDatabaseKind.system) {
        await _ensureSystemSchema(db);
      } else {
        await _ensureRoleCardSchema(db);
      }
    } finally {
      await db.close();
    }
  }

  Future<void> _ensureSystemSchema(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT NOT NULL UNIQUE,
        password TEXT NOT NULL
      )
    ''');
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_users_username ON users(username)',
    );
    await db.execute('''
      CREATE TABLE IF NOT EXISTS user_ai_settings (
        user_id INTEGER PRIMARY KEY,
        ai_settings_json TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
      )
    ''');
  }

  Future<void> _ensureRoleCardSchema(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS shared_role_cards (
        remote_id TEXT PRIMARY KEY,
        owner_username TEXT NOT NULL,
        name TEXT NOT NULL,
        avatar TEXT NOT NULL,
        personality TEXT NOT NULL,
        greeting TEXT DEFAULT '',
        my_nickname TEXT DEFAULT '冒险者',
        ai_nickname TEXT DEFAULT ''
      )
    ''');

    final columns = await db.rawQuery('PRAGMA table_info(shared_role_cards)');
    final columnNames = columns.map((column) => column['name'] as String).toSet();
    if (columnNames.contains('character_json')) {
      final countBefore =
          Sqflite.firstIntValue(
            await db.rawQuery('SELECT COUNT(*) FROM shared_role_cards'),
          ) ??
          0;
      print(
        '[RemoteDatabase] 检测到旧角色卡表 character_json 字段，开始迁移保留 $countBefore 行数据',
      );
      await db.transaction((txn) async {
        await txn.execute(
          'ALTER TABLE shared_role_cards RENAME TO shared_role_cards_old',
        );
        await txn.execute('''
          CREATE TABLE shared_role_cards (
            remote_id TEXT PRIMARY KEY,
            owner_username TEXT NOT NULL,
            name TEXT NOT NULL,
            avatar TEXT NOT NULL,
            personality TEXT NOT NULL,
            greeting TEXT DEFAULT '',
            my_nickname TEXT DEFAULT '冒险者',
            ai_nickname TEXT DEFAULT ''
          )
        ''');
        await txn.execute('''
          INSERT INTO shared_role_cards (
            remote_id,
            owner_username,
            name,
            avatar,
            personality,
            greeting,
            my_nickname,
            ai_nickname
          )
          SELECT
            remote_id,
            owner_username,
            name,
            avatar,
            personality,
            COALESCE(greeting, ''),
            COALESCE(my_nickname, '冒险者'),
            COALESCE(ai_nickname, '')
          FROM shared_role_cards_old
        ''');
        await txn.execute('DROP TABLE shared_role_cards_old');
      });
      final countAfter =
          Sqflite.firstIntValue(
            await db.rawQuery('SELECT COUNT(*) FROM shared_role_cards'),
          ) ??
          0;
      print(
        '[RemoteDatabase] 角色卡表迁移完成: before=$countBefore, after=$countAfter',
      );
    }

    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_shared_role_cards_owner ON shared_role_cards(owner_username)',
    );
  }

  String _remotePath(RemoteDatabaseKind kind) {
    return switch (kind) {
      RemoteDatabaseKind.system => WebDavConfig.systemDbPath,
      RemoteDatabaseKind.roleCard => WebDavConfig.roleCardDbPath,
    };
  }

  String _fileName(RemoteDatabaseKind kind) {
    return switch (kind) {
      RemoteDatabaseKind.system => 'system.db',
      RemoteDatabaseKind.roleCard => 'role_card.db',
    };
  }
}
