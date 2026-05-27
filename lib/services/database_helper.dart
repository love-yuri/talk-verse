import 'dart:io';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path_provider/path_provider.dart';

/// 数据库辅助类 - 单例模式
/// 负责初始化 SQLite 数据库、建表
class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._();
  DatabaseHelper._();
  factory DatabaseHelper() => _instance;

  Database? _db;

  Database get db => _db!;

  /// 初始化数据库（在 main() 中调用）
  Future<void> init() async {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;

    final appDir = await getApplicationDocumentsDirectory();
    final dbPath = '${appDir.path}${Platform.pathSeparator}talkverse.db';

    await _open(dbPath);
  }

  /// 初始化内存数据库，供 widget 测试使用
  Future<void> initInMemory() async {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    await _open(inMemoryDatabasePath);
  }

  Future<void> _open(String dbPath) async {
    await _db?.close();
    _db = await databaseFactory.openDatabase(
      dbPath,
      options: OpenDatabaseOptions(
        version: 8,
        onCreate: _onCreate,
        onUpgrade: _onUpgrade,
        onOpen: (db) async {
          await db.execute('PRAGMA foreign_keys = ON');
        },
      ),
    );
  }

  /// 建表
  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE sessions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        character_id INTEGER NOT NULL,
        character_name TEXT NOT NULL,
        character_avatar TEXT NOT NULL,
        last_message_content TEXT DEFAULT '',
        last_message_time TEXT,
        unread_count INTEGER DEFAULT 0,
        scene_location TEXT,
        scene_time TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE messages (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        session_id INTEGER NOT NULL,
        content TEXT NOT NULL,
        type TEXT NOT NULL,
        timestamp TEXT NOT NULL,
        is_read INTEGER DEFAULT 0,
        status TEXT DEFAULT 'sent',
        is_error INTEGER DEFAULT 0,
        FOREIGN KEY (session_id) REFERENCES sessions(id) ON DELETE CASCADE
      )
    ''');
    await db.execute('CREATE INDEX idx_messages_session ON messages(session_id)');

    await db.execute('''
      CREATE TABLE token_records (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        session_id INTEGER NOT NULL,
        character_name TEXT NOT NULL,
        timestamp TEXT NOT NULL,
        input_tokens INTEGER DEFAULT 0,
        cache_read_tokens INTEGER DEFAULT 0,
        cache_create_tokens INTEGER DEFAULT 0,
        output_tokens INTEGER DEFAULT 0,
        model TEXT NOT NULL
      )
    ''');
    await db.execute('CREATE INDEX idx_tokens_session ON token_records(session_id)');

    await db.execute('''
      CREATE TABLE characters (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        avatar TEXT NOT NULL,
        personality TEXT NOT NULL,
        greeting TEXT DEFAULT '',
        my_nickname TEXT DEFAULT '冒险者',
        ai_nickname TEXT DEFAULT ''
      )
    ''');

    await db.execute('''
      CREATE TABLE character_sync_meta (
        local_character_id INTEGER PRIMARY KEY,
        remote_id TEXT NOT NULL UNIQUE,
        owner_username TEXT NOT NULL,
        last_synced_at TEXT NOT NULL,
        FOREIGN KEY (local_character_id) REFERENCES characters(id) ON DELETE CASCADE
      )
    ''');
    await db.execute('CREATE INDEX idx_character_sync_remote_id ON character_sync_meta(remote_id)');
  }

  /// 升级：逐版本迁移
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 8) {
      await db.execute('ALTER TABLE messages ADD COLUMN is_error INTEGER DEFAULT 0');
    }
  }
}
