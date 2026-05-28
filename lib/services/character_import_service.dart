import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';

import '../models/character.dart';
import 'character_card_parser.dart';

/// 角色卡导入结果
class CharacterImportResult {
  final Character character;
  final String? avatarPath;

  const CharacterImportResult({required this.character, this.avatarPath});
}

/// 角色卡导入服务
/// 支持从 PNG 图片和 JSON 文件导入 SillyTavern 格式的角色卡
class CharacterImportService {
  /// 选择并导入角色卡文件
  /// 返回解析后的角色数据，用户取消返回 null
  static Future<CharacterImportResult?> importFromFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['png', 'json'],
      withData: true,
    );

    if (result == null || result.files.isEmpty) return null;

    final file = result.files.first;
    final ext = file.extension?.toLowerCase();

    if (ext == 'png') {
      return _importFromPng(file);
    } else if (ext == 'json') {
      return _importFromJson(file);
    }

    return null;
  }

  /// 从 PNG 文件导入
  static Future<CharacterImportResult?> _importFromPng(PlatformFile file) async {
    final bytes = file.bytes;
    if (bytes == null) return null;

    final cardData = CharacterCardParser.parsePng(bytes);
    if (cardData == null || cardData.name.isEmpty) return null;

    // 保存图片到应用目录作为头像
    final avatarPath = await _saveAvatarImage(bytes, cardData.name);

    return CharacterImportResult(
      character: Character(
        id: 0,
        name: cardData.name,
        avatar: avatarPath,
        personality: cardData.personality,
        greeting: cardData.greeting,
      ),
      avatarPath: avatarPath,
    );
  }

  /// 从 JSON 文件导入
  static Future<CharacterImportResult?> _importFromJson(PlatformFile file) async {
    final bytes = file.bytes;
    if (bytes == null) return null;

    try {
      final jsonStr = String.fromCharCodes(bytes);
      final cardData = CharacterCardParser.parseJson(jsonStr);
      if (cardData == null || cardData.name.isEmpty) return null;

      return CharacterImportResult(
        character: Character(
          id: 0,
          name: cardData.name,
          avatar: 'assets/images/default_avatar.png',
          personality: cardData.personality,
          greeting: cardData.greeting,
        ),
      );
    } catch (_) {
      return null;
    }
  }

  /// 保存头像图片到应用文档目录
  static Future<String> _saveAvatarImage(Uint8List bytes, String name) async {
    final dir = await getApplicationDocumentsDirectory();
    final avatarDir = Directory('${dir.path}/avatars');
    if (!await avatarDir.exists()) {
      await avatarDir.create(recursive: true);
    }

    // 用角色名生成文件名，避免特殊字符
    final safeName = name.replaceAll(RegExp(r'[^\w一-鿿]'), '_');
    final filePath = '${avatarDir.path}/imported_$safeName.png';
    final file = File(filePath);
    await file.writeAsBytes(bytes);
    return filePath;
  }
}
