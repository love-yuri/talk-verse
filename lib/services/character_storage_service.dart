import 'package:sqflite/sqflite.dart';
import '../models/character.dart';
import 'database_helper.dart';

/// 角色同步保存结果
class CharacterSyncSaveResult {
  final int id;
  final bool updatedExisting;

  const CharacterSyncSaveResult({required this.id, required this.updatedExisting});
}

/// 角色数据持久化服务（SQLite 版）
/// 不预设默认角色，首次安装返回空列表
class CharacterStorageService {
  static final CharacterStorageService _instance = CharacterStorageService._();
  CharacterStorageService._();
  factory CharacterStorageService() => _instance;

  /// 按 ID 加载单个角色
  Future<Character?> loadById(int id) async {
    final db = DatabaseHelper().db;
    final rows = await db.query('characters', where: 'id = ?', whereArgs: [id], limit: 1);
    if (rows.isEmpty) return null;
    return _rowToCharacter(rows.first);
  }

  /// 加载所有角色
  Future<List<Character>> load() async {
    final db = DatabaseHelper().db;
    final rows = await db.query('characters');
    return rows.map(_rowToCharacter).toList();
  }

  /// 按名称查找角色
  Future<Character?> findByName(String name) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return null;

    final db = DatabaseHelper().db;
    final rows = await db.query('characters', where: 'name = ?', whereArgs: [trimmed], limit: 1);
    if (rows.isEmpty) return null;
    return _rowToCharacter(rows.first);
  }

  /// 同步远程角色，同名角色会被更新
  Future<CharacterSyncSaveResult> syncRemote(Character character) async {
    final existing = await findByName(character.name);
    final saved = character.copyWith(id: existing?.id ?? 0);
    final id = await save(saved);
    return CharacterSyncSaveResult(id: existing?.id ?? id, updatedExisting: existing != null);
  }

  /// 保存或更新角色，返回自动生成的 ID
  Future<int> save(Character character) async {
    final db = DatabaseHelper().db;
    final data = <String, Object?>{
      if (character.id != 0) 'id': character.id,
      'name': character.name,
      'avatar': character.avatar,
      'personality': character.personality,
      'greeting': character.greeting,
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
      personality: r['personality'] as String,
      greeting: r['greeting'] as String,
      myNickname: r['my_nickname'] as String? ?? '冒险者',
      aiNickname: r['ai_nickname'] as String? ?? '',
    );
  }
}
