import 'package:sqflite/sqflite.dart';
import '../models/character.dart';
import 'database_helper.dart';

/// 角色同步保存结果
class CharacterSyncSaveResult {
  final int id;
  final bool updatedExisting;

  const CharacterSyncSaveResult({
    required this.id,
    required this.updatedExisting,
  });
}

/// 发现页角色来源信息
class DiscoverCharacterItem {
  final Character character;
  final String? remoteId;
  final String? ownerUsername;

  const DiscoverCharacterItem({
    required this.character,
    this.remoteId,
    this.ownerUsername,
  });

  bool get isRemote => remoteId != null;
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
    final rows = await db.query(
      'characters',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return _rowToCharacter(rows.first);
  }

  /// 加载所有角色
  Future<List<Character>> load() async {
    final db = DatabaseHelper().db;
    final rows = await db.query('characters');
    return rows.map(_rowToCharacter).toList();
  }

  /// 加载发现页角色及同步来源信息
  Future<List<DiscoverCharacterItem>> loadForDiscover() async {
    final db = DatabaseHelper().db;
    final rows = await db.rawQuery('''
      SELECT
        c.id,
        c.name,
        c.avatar,
        c.personality,
        c.greeting,
        c.my_nickname,
        c.ai_nickname,
        m.remote_id,
        m.owner_username
      FROM characters c
      LEFT JOIN character_sync_meta m ON m.local_character_id = c.id
      ORDER BY c.id ASC
    ''');

    return rows.map((row) {
      return DiscoverCharacterItem(
        character: _rowToCharacter(row),
        remoteId: row['remote_id'] as String?,
        ownerUsername: row['owner_username'] as String?,
      );
    }).toList();
  }

  /// 按名称查找角色
  Future<Character?> findByName(String name) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return null;

    final db = DatabaseHelper().db;
    final rows = await db.query(
      'characters',
      where: 'name = ?',
      whereArgs: [trimmed],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return _rowToCharacter(rows.first);
  }

  /// 同步远程角色，同名角色会被更新
  Future<CharacterSyncSaveResult> syncRemote(Character character) async {
    final existing = await findByName(character.name);
    final saved = character.copyWith(id: existing?.id ?? 0);
    final id = await save(saved);
    return CharacterSyncSaveResult(
      id: existing?.id ?? id,
      updatedExisting: existing != null,
    );
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
    return await db.insert(
      'characters',
      data,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// 批量删除角色
  Future<void> deleteMany(List<int> ids) async {
    if (ids.isEmpty) return;

    final db = DatabaseHelper().db;
    final placeholders = List.filled(ids.length, '?').join(',');
    await db.delete(
      'characters',
      where: 'id IN ($placeholders)',
      whereArgs: ids,
    );
  }

  /// 删除角色
  Future<void> delete(int id) async {
    await deleteMany([id]);
  }

  Character _rowToCharacter(Map<String, Object?> r) {
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
