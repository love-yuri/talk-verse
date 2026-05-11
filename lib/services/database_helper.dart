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
    // 桌面平台使用 FFI
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;

    final appDir = await getApplicationDocumentsDirectory();
    final dbPath = '${appDir.path}${Platform.pathSeparator}talkverse.db';

    _db = await databaseFactory.openDatabase(
      dbPath,
      options: OpenDatabaseOptions(
        version: 4,
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
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
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
        description TEXT NOT NULL,
        personality TEXT NOT NULL,
        greeting TEXT NOT NULL,
        tags TEXT DEFAULT '[]',
        my_nickname TEXT DEFAULT '冒险者',
        ai_nickname TEXT DEFAULT ''
      )
    ''');
  }

  /// 数据库升级 - 直接删除旧表重建
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    await db.execute('DROP TABLE IF EXISTS token_records');
    await db.execute('DROP TABLE IF EXISTS messages');
    await db.execute('DROP TABLE IF EXISTS sessions');
    await db.execute('DROP TABLE IF EXISTS characters');
    await _onCreate(db, newVersion);
  }
}
