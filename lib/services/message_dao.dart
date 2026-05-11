import 'package:sqflite/sqflite.dart';
import '../models/message.dart';
import 'database_helper.dart';

/// 消息数据访问对象
/// 独立管理消息的 CRUD 操作
class MessageDao {
  static final MessageDao _instance = MessageDao._();
  MessageDao._();
  factory MessageDao() => _instance;

  /// 加载指定会话的所有消息
  Future<List<Message>> loadMessages(String sessionId) async {
    final db = DatabaseHelper().db;
    final rows = await db.query(
      'messages',
      where: 'session_id = ?',
      whereArgs: [sessionId],
      orderBy: 'timestamp ASC',
    );
    return rows.map(_rowToMessage).toList();
  }

  /// 插入一条消息
  Future<void> insertMessage(String sessionId, Message msg) async {
    final db = DatabaseHelper().db;
    await db.insert('messages', {
      'id': msg.id,
      'session_id': sessionId,
      'content': msg.content,
      'type': msg.type.name,
      'timestamp': msg.timestamp.toIso8601String(),
      'is_read': msg.isRead ? 1 : 0,
      'status': msg.status.name,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  /// 更新一条消息
  Future<void> updateMessage(Message msg) async {
    final db = DatabaseHelper().db;
    await db.update('messages', {
      'content': msg.content,
      'type': msg.type.name,
      'timestamp': msg.timestamp.toIso8601String(),
      'is_read': msg.isRead ? 1 : 0,
      'status': msg.status.name,
    }, where: 'id = ?', whereArgs: [msg.id]);
  }

  /// 删除一条消息
  Future<void> deleteMessage(String msgId) async {
    final db = DatabaseHelper().db;
    await db.delete('messages', where: 'id = ?', whereArgs: [msgId]);
  }

  /// 清空指定会话的所有消息
  Future<void> clearSessionMessages(String sessionId) async {
    final db = DatabaseHelper().db;
    await db.delete('messages', where: 'session_id = ?', whereArgs: [sessionId]);
  }

  Message _rowToMessage(Map<String, dynamic> r) {
    return Message(
      id: r['id'] as String,
      content: r['content'] as String,
      type: MessageType.values.firstWhere(
        (e) => e.name == r['type'],
        orElse: () => MessageType.user,
      ),
      timestamp: DateTime.parse(r['timestamp'] as String),
      isRead: (r['is_read'] as int?) == 1,
      status: MessageStatus.values.firstWhere(
        (e) => e.name == r['status'],
        orElse: () => MessageStatus.sent,
      ),
    );
  }
}
