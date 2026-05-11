import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import '../models/character.dart';
import 'database_helper.dart';

/// 角色数据持久化服务（SQLite 版）
/// 不预设默认角色，首次安装返回空列表
class CharacterStorageService {
  static final CharacterStorageService _instance = CharacterStorageService._();
  CharacterStorageService._();
  factory CharacterStorageService() => _instance;

  /// 加载所有角色
  Future<List<Character>> load() async {
    final db = DatabaseHelper().db;
    final rows = await db.query('characters');
    return rows.map(_rowToCharacter).toList();
  }

  /// 保存或更新角色，返回自动生成的 ID
  Future<int> save(Character character) async {
    final db = DatabaseHelper().db;
    final data = <String, Object?>{
      if (character.id != 0) 'id': character.id,
      'name': character.name,
      'avatar': character.avatar,
      'description': character.description,
      'personality': character.personality,
      'greeting': character.greeting,
      'tags': jsonEncode(character.tags),
      'my_nickname': character.myNickname,
      'ai_nickname': character.aiNickname,
    };
    return await db.insert('characters', data, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  /// 删除角色
  Future<void> delete(int id) async {
    final db = DatabaseHelper().db;
    await db.delete('characters', where: 'id = ?', whereArgs: [id]);
  }

  Character _rowToCharacter(Map<String, dynamic> r) {
    return Character(
      id: r['id'] as int,
      name: r['name'] as String,
      avatar: r['avatar'] as String,
      description: r['description'] as String,
      personality: r['personality'] as String,
      greeting: r['greeting'] as String,
      tags: (jsonDecode(r['tags'] as String) as List<dynamic>).cast<String>(),
      myNickname: r['my_nickname'] as String? ?? '冒险者',
      aiNickname: r['ai_nickname'] as String? ?? '',
    );
  }
}
