import 'dart:convert';
import 'dart:io';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 数据库辅助类 - 单例模式
/// 负责初始化 SQLite 数据库、建表、从 SharedPreferences 迁移旧数据
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
        version: 1,
        onCreate: _onCreate,
        onOpen: (db) async {
          await db.execute('PRAGMA foreign_keys = ON');
        },
      ),
    );

    await _migrateFromSharedPreferences();
  }

  /// 建表
  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE sessions (
        id TEXT PRIMARY KEY,
        character_id TEXT NOT NULL,
        character_name TEXT NOT NULL,
        character_avatar TEXT NOT NULL,
        last_message_content TEXT DEFAULT '',
        last_message_time TEXT,
        unread_count INTEGER DEFAULT 0,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE messages (
        id TEXT PRIMARY KEY,
        session_id TEXT NOT NULL,
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
        id TEXT PRIMARY KEY,
        session_id TEXT NOT NULL,
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
        id TEXT PRIMARY KEY,
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

  /// 从 SharedPreferences 迁移旧数据到 SQLite
  Future<void> _migrateFromSharedPreferences() async {
    final prefs = await SharedPreferences.getInstance();

    // 迁移聊天会话
    final sessionsJson = prefs.getString('chat_sessions');
    if (sessionsJson != null) {
      final list = jsonDecode(sessionsJson) as List<dynamic>;
      for (final item in list) {
        final session = item as Map<String, dynamic>;
        final sessionId = session['id'] as String;
        final messages = (session['messages'] as List<dynamic>?) ?? [];

        // 插入会话元数据
        // 取最后一条消息作为预览
        String lastContent = '';
        String? lastTime;
        int unreadCount = 0;
        if (messages.isNotEmpty) {
          final lastMsg = messages.last as Map<String, dynamic>;
          lastContent = (lastMsg['content'] as String?) ?? '';
          lastTime = lastMsg['timestamp'] as String?;
          unreadCount = messages
              .where((m) =>
                  (m['isRead'] == false || m['isRead'] == null) &&
                  m['type'] == 'ai')
              .length;
        }

        await _db!.insert('sessions', {
          'id': sessionId,
          'character_id': session['characterId'] ?? '',
          'character_name': session['characterName'] ?? '',
          'character_avatar': session['characterAvatar'] ?? '',
          'last_message_content': lastContent,
          'last_message_time': lastTime,
          'unread_count': unreadCount,
          'created_at': session['createdAt'] ?? DateTime.now().toIso8601String(),
          'updated_at': session['updatedAt'] ?? DateTime.now().toIso8601String(),
        }, conflictAlgorithm: ConflictAlgorithm.replace);

        // 插入消息
        for (final msg in messages) {
          final msgMap = msg as Map<String, dynamic>;
          await _db!.insert('messages', {
            'id': msgMap['id'] ?? '',
            'session_id': sessionId,
            'content': msgMap['content'] ?? '',
            'type': msgMap['type'] ?? 'user',
            'timestamp': msgMap['timestamp'] ?? DateTime.now().toIso8601String(),
            'is_read': (msgMap['isRead'] == true) ? 1 : 0,
            'status': msgMap['status'] ?? 'sent',
          }, conflictAlgorithm: ConflictAlgorithm.replace);
        }
      }
      await prefs.remove('chat_sessions');
    }

    // 迁移角色数据
    final charsJson = prefs.getString('characters');
    if (charsJson != null) {
      final list = jsonDecode(charsJson) as List<dynamic>;
      for (final item in list) {
        final c = item as Map<String, dynamic>;
        await _db!.insert('characters', {
          'id': c['id'] ?? '',
          'name': c['name'] ?? '',
          'avatar': c['avatar'] ?? '',
          'description': c['description'] ?? '',
          'personality': c['personality'] ?? '',
          'greeting': c['greeting'] ?? '',
          'tags': jsonEncode(c['tags'] ?? []),
          'my_nickname': c['myNickname'] ?? '冒险者',
          'ai_nickname': c['aiNickname'] ?? '',
        }, conflictAlgorithm: ConflictAlgorithm.replace);
      }
      await prefs.remove('characters');
    }

    // 迁移 Token 记录
    final tokensJson = prefs.getString('token_records');
    if (tokensJson != null) {
      final list = jsonDecode(tokensJson) as List<dynamic>;
      for (final item in list) {
        final t = item as Map<String, dynamic>;
        await _db!.insert('token_records', {
          'id': t['id'] ?? '',
          'session_id': t['sessionId'] ?? '',
          'character_name': t['characterName'] ?? '',
          'timestamp': t['timestamp'] ?? DateTime.now().toIso8601String(),
          'input_tokens': t['inputTokens'] ?? 0,
          'cache_read_tokens': t['cacheReadTokens'] ?? 0,
          'cache_create_tokens': t['cacheCreateTokens'] ?? 0,
          'output_tokens': t['outputTokens'] ?? 0,
          'model': t['model'] ?? '',
        }, conflictAlgorithm: ConflictAlgorithm.replace);
      }
      await prefs.remove('token_records');
    }
  }
}
