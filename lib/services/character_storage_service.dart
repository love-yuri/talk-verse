import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/character.dart';

/// 角色数据持久化服务
class CharacterStorageService {
  static const _key = 'characters';
  static final CharacterStorageService _instance = CharacterStorageService._();
  CharacterStorageService._();
  factory CharacterStorageService() => _instance;

  List<Character> _characters = [];
  bool _seeded = false;

  static final _defaults = [
    Character(id: 'ai_1', name: '小助手', avatar: 'assets/images/default_avatar.png', description: '你的智能AI助手，随时为你解答问题', personality: '友好、专业、耐心', greeting: '你好！有什么可以帮你的吗？', tags: ['助手', '问答'], myNickname: '冒险者', aiNickname: '小助手'),
    Character(id: 'ai_2', name: '诗人', avatar: 'assets/images/default_avatar.png', description: '一位才华横溢的诗人，能为你创作优美的诗句', personality: '浪漫、文艺', greeting: '月光如水，诗意盎然。', tags: ['创作', '诗歌'], myNickname: '旅人', aiNickname: '诗人'),
    Character(id: 'ai_3', name: '朋友', avatar: 'assets/images/default_avatar.png', description: '一个温暖的朋友，陪你聊天解闷', personality: '开朗、幽默', greeting: '嘿！好久不见！', tags: ['聊天', '陪伴'], myNickname: '伙伴', aiNickname: '小友'),
    Character(id: 'ai_4', name: '老师', avatar: 'assets/images/default_avatar.png', description: '一位知识渊博的老师，帮你解答学习问题', personality: '严谨、耐心', greeting: '同学们好！', tags: ['教育', '学习'], myNickname: '同学', aiNickname: '老师'),
    Character(id: 'ai_5', name: '健身教练', avatar: 'assets/images/default_avatar.png', description: '专业的健身教练，为你制定训练计划', personality: '积极、鼓励', greeting: '准备好开始训练了吗？', tags: ['健身', '健康'], myNickname: '学员', aiNickname: '教练'),
  ];

  Future<List<Character>> load() async {
    if (_seeded) return _characters;
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString(_key);
    if (json != null) {
      final list = jsonDecode(json) as List<dynamic>;
      _characters = list.map((e) => Character.fromJson(e as Map<String, dynamic>)).toList();
    } else {
      _characters = List.from(_defaults);
      await _persist();
    }
    _seeded = true;
    return _characters;
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(_characters.map((e) => e.toJson()).toList()));
  }

  Future<void> save(Character character) async {
    final idx = _characters.indexWhere((c) => c.id == character.id);
    if (idx != -1) {
      _characters[idx] = character;
    } else {
      _characters.add(character);
    }
    await _persist();
  }

  Future<void> delete(String id) async {
    _characters.removeWhere((c) => c.id == id);
    await _persist();
  }

  /// 重置为默认角色列表
  Future<void> resetToDefaults() async {
    _characters = List.from(_defaults);
    await _persist();
  }
}
