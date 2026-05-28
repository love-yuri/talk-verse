import 'dart:convert';
import 'dart:typed_data';

/// SillyTavern 角色卡解析结果
class CharacterCardData {
  final String name;
  final String personality;
  final String greeting;

  const CharacterCardData({
    required this.name,
    required this.personality,
    required this.greeting,
  });
}

/// PNG 角色卡解析器
/// 支持 SillyTavern V1/V2/V3 格式的 PNG tEXt chunk 解析
class CharacterCardParser {
  /// 从 PNG 文件字节中解析角色卡数据
  static CharacterCardData? parsePng(Uint8List bytes) {
    final jsonStr = _extractCharacterJson(bytes);
    if (jsonStr == null) return null;
    return _parseJson(jsonStr);
  }

  /// 从 JSON 字符串中解析角色卡数据
  static CharacterCardData? parseJson(String jsonStr) {
    return _parseJson(jsonStr);
  }

  /// 提取 PNG tEXt chunk 中的角色卡 JSON
  static String? _extractCharacterJson(Uint8List bytes) {
    if (bytes.length < 8) return null;
    const pngSignature = [0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A];
    for (var i = 0; i < 8; i++) {
      if (bytes[i] != pngSignature[i]) return null;
    }

    var offset = 8;
    String? charaBase64;
    String? ccv3Base64;

    while (offset + 8 <= bytes.length) {
      final length = (bytes[offset] << 24) |
          (bytes[offset + 1] << 16) |
          (bytes[offset + 2] << 8) |
          bytes[offset + 3];
      final chunkType = String.fromCharCodes(bytes, offset + 4, offset + 8);

      if (chunkType == 'IEND') break;
      if (offset + 8 + length + 4 > bytes.length) break;

      if (chunkType == 'tEXt') {
        final data = bytes.sublist(offset + 8, offset + 8 + length);
        final nullIndex = data.indexOf(0);
        if (nullIndex > 0) {
          final keyword = String.fromCharCodes(data, 0, nullIndex).toLowerCase();
          final text = String.fromCharCodes(data, nullIndex + 1);

          if (keyword == 'ccv3') {
            ccv3Base64 = text;
          } else if (keyword == 'chara') {
            charaBase64 = text;
          }
        }
      }

      offset += 12 + length;
    }

    final base64Str = ccv3Base64 ?? charaBase64;
    if (base64Str == null) return null;

    try {
      return utf8.decode(base64.decode(base64Str));
    } catch (_) {
      return null;
    }
  }

  /// 解析角色卡 JSON（支持 V1/V2/V3）
  static CharacterCardData? _parseJson(String jsonStr) {
    try {
      final json = jsonDecode(jsonStr) as Map<String, dynamic>;

      if (json.containsKey('data')) {
        final data = json['data'] as Map<String, dynamic>;
        return _extractFromData(data, json);
      }

      return _extractFromData(json, json);
    } catch (_) {
      return null;
    }
  }

  /// 从 data 对象中提取字段
  /// 参照 SillyTavern 的字段拼装逻辑，提取所有角色设定相关字段
  /// 包括 character_book（World Info / Lorebook）中的所有条目
  static CharacterCardData _extractFromData(
    Map<String, dynamic> data,
    Map<String, dynamic> root,
  ) {
    final name = (data['name'] as String?)?.trim() ?? '';
    final description = (data['description'] as String?)?.trim() ?? '';
    final personality = (data['personality'] as String?)?.trim() ?? '';
    final firstMes = (data['first_mes'] as String?)?.trim() ?? '';
    final scenario = (data['scenario'] as String?)?.trim() ?? '';
    final mesExample = (data['mes_example'] as String?)?.trim() ?? '';
    final systemPrompt = (data['system_prompt'] as String?)?.trim() ?? '';
    final postHistoryInstructions = (data['post_history_instructions'] as String?)?.trim() ?? '';

    final extensions = data['extensions'] as Map<String, dynamic>?;

    // 提取深度提示
    String? depthPrompt;
    if (extensions != null) {
      final depthPromptData = extensions['depth_prompt'] as Map<String, dynamic>?;
      if (depthPromptData != null) {
        depthPrompt = (depthPromptData['prompt'] as String?)?.trim();
        if (depthPrompt?.isEmpty == true) depthPrompt = null;
      }
    }

    // 提取 character_book 条目（不管是否禁用，全部提取）
    final bookEntries = _extractCharacterBook(data, extensions);

    // 按照 SillyTavern 的 prompt 拼装顺序组合
    final parts = <String>[];

    if (systemPrompt.isNotEmpty) parts.add(systemPrompt);
    if (description.isNotEmpty) parts.add(description);
    if (personality.isNotEmpty && personality != description) {
      parts.add(personality);
    }
    if (scenario.isNotEmpty) parts.add('Scenario: $scenario');
    if (depthPrompt != null) parts.add(depthPrompt);
    if (bookEntries.isNotEmpty) parts.addAll(bookEntries);
    if (mesExample.isNotEmpty) parts.add(mesExample);
    if (postHistoryInstructions.isNotEmpty) parts.add(postHistoryInstructions);

    return CharacterCardData(
      name: name,
      personality: parts.join('\n\n'),
      greeting: firstMes,
    );
  }

  /// 从 character_book 中提取所有条目内容
  static List<String> _extractCharacterBook(
    Map<String, dynamic> data,
    Map<String, dynamic>? extensions,
  ) {
    final entries = <String>[];

    Map<String, dynamic>? book;
    if (extensions != null) {
      book = extensions['character_book'] as Map<String, dynamic>?;
    }
    if (book == null && data.containsKey('character_book')) {
      book = data['character_book'] as Map<String, dynamic>?;
    }
    if (book == null) return entries;

    final entryList = book['entries'] as List<dynamic>?;
    if (entryList == null) return entries;

    for (final entry in entryList) {
      if (entry is! Map<String, dynamic>) continue;
      final content = (entry['content'] as String?)?.trim() ?? '';
      if (content.isEmpty) continue;
      entries.add(content);
    }

    return entries;
  }
}
