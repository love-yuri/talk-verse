import 'package:sqflite/sqflite.dart';
import '../models/chat_session.dart';
import 'database_helper.dart';

/// 聊天会话元数据持久化服务
/// 只管理会话元数据，消息由 MessageDao 独立管理
class ChatStorageService {
  static final ChatStorageService _instance = ChatStorageService._();
  ChatStorageService._();
  factory ChatStorageService() => _instance;

  /// 加载所有会话（仅元数据，不含消息）
  Future<List<ChatSession>> load() async {
    final db = DatabaseHelper().db;
    final rows = await db.query('sessions', orderBy: 'id DESC');
    return rows.map((r) => ChatSession(
      id: r['id'] as int,
      characterId: r['character_id'] as int,
      characterName: r['character_name'] as String,
      characterAvatar: r['character_avatar'] as String,
      sceneLocation: r['scene_location'] as String?,
      sceneTime: r['scene_time'] as String?,
    )).toList();
  }

  /// 保存或更新单个会话元数据，返回自动生成的 ID
  Future<int> saveSession(ChatSession session) async {
    final db = DatabaseHelper().db;
    return await db.insert('sessions', {
      'character_id': session.characterId,
      'character_name': session.characterName,
      'character_avatar': session.characterAvatar,
      'last_message_content': session.lastMessage?.content ?? '',
      'last_message_time': session.lastMessage?.timestamp.toIso8601String(),
      'unread_count': session.unreadCount,
      'scene_location': session.sceneLocation,
      'scene_time': session.sceneTime,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  /// 更新会话的最后消息预览
  Future<void> updateLastMessage(int sessionId, String content, DateTime time) async {
    final db = DatabaseHelper().db;
    await db.update('sessions', {
      'last_message_content': content,
      'last_message_time': time.toIso8601String(),
    }, where: 'id = ?', whereArgs: [sessionId]);
  }

  /// 删除指定会话（级联删除消息）
  Future<void> deleteSession(int id) async {
    final db = DatabaseHelper().db;
    await db.delete('sessions', where: 'id = ?', whereArgs: [id]);
  }

  /// 更新会话的场景信息
  Future<void> updateScene(int sessionId, String location, String time) async {
    final db = DatabaseHelper().db;
    await db.update('sessions', {
      'scene_location': location.isEmpty ? null : location,
      'scene_time': time.isEmpty ? null : time,
    }, where: 'id = ?', whereArgs: [sessionId]);
  }
}
