import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';

import '../ai_modules/ai_provider.dart';
import '../ai_modules/anthropic/anthropic_provider.dart';
import '../constants/app_colors.dart';
import '../constants/app_dimensions.dart';
import '../models/ai_settings.dart';
import '../models/character.dart';
import '../models/message.dart';
import '../services/settings_service.dart';
import '../widgets/warm_background.dart';
import 'character_edit_screen.dart';

class AiCharacterGenerateScreen extends StatefulWidget {
  final int index;

  const AiCharacterGenerateScreen({super.key, required this.index});

  @override
  State<AiCharacterGenerateScreen> createState() =>
      _AiCharacterGenerateScreenState();
}

class _AiCharacterGenerateScreenState extends State<AiCharacterGenerateScreen> {
  final _sceneCtrl = TextEditingController();
  final _minCharsCtrl = TextEditingController(text: '1200');
  final _settingsService = SettingsService();

  bool _generating = false;
  String _generationStatus = '';
  String _generatedPreview = '';

  @override
  void dispose() {
    _sceneCtrl.dispose();
    _minCharsCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color =
        AppColors.avatarColors[widget.index % AppColors.avatarColors.length];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          _buildHeader(context, color),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildIntroCard(color),
                  const SizedBox(height: 16),
                  _buildSceneField(),
                  const SizedBox(height: 14),
                  _buildMinCharsField(),
                  const SizedBox(height: 22),
                  _buildGenerateButton(),
                  if (_generating || _generatedPreview.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    _buildProgressCard(),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, Color color) {
    return Container(
      padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color.withValues(alpha: 0.4),
            AppColors.chatAppBarMid,
            color.withValues(alpha: 0.3),
          ],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          children: [
            TapScale(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.close, size: 18, color: Colors.white),
              ),
            ),
            const SizedBox(width: 10),
            const Text(
              'AI 创建角色卡',
              style: TextStyle(
                fontFamily: 'MapleMono',
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: Colors.white,
                letterSpacing: -0.24,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIntroCard(Color color) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceGlass,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        border: Border.all(
          color: AppColors.border.withValues(alpha: 0.75),
          width: 0.7,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.08),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.auto_awesome_rounded, color: AppColors.accent, size: 22),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              '描述你想要的故事场景、人物关系、氛围或禁忌点，AI 会补全角色名称、人设、剧情背景和开场白。生成后会进入编辑页确认。',
              style: TextStyle(
                fontFamily: 'MapleMono',
                fontSize: 13,
                color: AppColors.textSecondary,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSceneField() {
    return _fieldShell(
      label: '场景描述',
      child: TextField(
        controller: _sceneCtrl,
        minLines: 6,
        maxLines: 10,
        style: const TextStyle(
          fontFamily: 'MapleMono',
          fontSize: 13,
          color: AppColors.textPrimary,
          height: 1.55,
        ),
        decoration: const InputDecoration(
          hintText: '例如：修仙宗门里冷淡师姐和新入门弟子，慢热、暧昧、带一点危险感...',
          hintStyle: TextStyle(
            fontFamily: 'MapleMono',
            fontSize: 13,
            color: AppColors.textTertiary,
            height: 1.55,
          ),
          filled: false,
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          contentPadding: EdgeInsets.zero,
          isDense: true,
        ),
      ),
    );
  }

  Widget _buildMinCharsField() {
    return _fieldShell(
      label: '人设最低字数（可选）',
      child: Row(
        children: [
          const Icon(Icons.notes_rounded, size: 18, color: AppColors.accent),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: _minCharsCtrl,
              keyboardType: TextInputType.number,
              style: const TextStyle(
                fontFamily: 'MapleMono',
                fontSize: 14,
                color: AppColors.textPrimary,
              ),
              decoration: const InputDecoration(
                hintText: '1200',
                hintStyle: TextStyle(
                  fontFamily: 'MapleMono',
                  fontSize: 14,
                  color: AppColors.textTertiary,
                ),
                filled: false,
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                contentPadding: EdgeInsets.zero,
                isDense: true,
              ),
            ),
          ),
          const Text(
            '字',
            style: TextStyle(
              fontFamily: 'MapleMono',
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _fieldShell({required String label, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'MapleMono',
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.surfaceGlass,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.border.withValues(alpha: 0.75),
              width: 0.7,
            ),
          ),
          child: child,
        ),
      ],
    );
  }

  Widget _buildGenerateButton() {
    return TapScale(
      onTap: _generating ? null : _generate,
      child: Opacity(
        opacity: _generating ? 0.75 : 1,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 15),
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: AppColors.accent.withValues(alpha: 0.24),
                blurRadius: 14,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Center(
            child: _generating
                ? Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _generationStatus.isEmpty
                            ? '正在连接...'
                            : _generationStatus,
                        style: const TextStyle(
                          fontFamily: 'MapleMono',
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  )
                : const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.auto_awesome_rounded,
                        color: Colors.white,
                        size: 18,
                      ),
                      SizedBox(width: 8),
                      Text(
                        '生成角色卡',
                        style: TextStyle(
                          fontFamily: 'MapleMono',
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildProgressCard() {
    final preview = _generatedPreview.length > 1200
        ? '...${_generatedPreview.substring(_generatedPreview.length - 1200)}'
        : _generatedPreview;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceGlass,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.border.withValues(alpha: 0.75),
          width: 0.7,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.stream_rounded,
                size: 17,
                color: AppColors.accent,
              ),
              const SizedBox(width: 8),
              Text(
                _generationStatus.isEmpty ? '等待生成' : _generationStatus,
                style: const TextStyle(
                  fontFamily: 'MapleMono',
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            constraints: const BoxConstraints(maxHeight: 220),
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.surfaceAlt.withValues(alpha: 0.72),
              borderRadius: BorderRadius.circular(10),
            ),
            child: SingleChildScrollView(
              reverse: true,
              child: Text(
                preview.isEmpty ? '模型开始输出后会显示角色卡预览...' : preview,
                style: const TextStyle(
                  fontFamily: 'MapleMono',
                  fontSize: 12,
                  color: AppColors.textSecondary,
                  height: 1.55,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _generate() async {
    final scene = _sceneCtrl.text.trim();
    if (scene.isEmpty) {
      _showSnack('请先输入场景描述', backgroundColor: AppColors.warning);
      return;
    }

    final minChars = max(300, int.tryParse(_minCharsCtrl.text.trim()) ?? 1200);
    setState(() {
      _generating = true;
      _generatedPreview = '';
      _generationStatus = '正在连接...';
    });

    try {
      final settings = await _settingsService.load();
      if (!settings.isConfigured) {
        throw Exception('请先在设置中配置 API Key');
      }

      final active = settings.activeConfig;
      final generationSettings = AiSettings(
        configs: [
          active.copyWith(
            reasoningEnabled: false,
            temperature: 0.85,
            maxTokens: max(active.maxTokens, min(8192, minChars * 3)),
          ),
        ],
      );
      final provider = AnthropicProvider(generationSettings);
      final buffer = StringBuffer();
      await provider
          .sendMessageStream([
            Message(
              id: 0,
              content: _buildPrompt(scene, minChars),
              type: MessageType.user,
              timestamp: DateTime.now(),
            ),
          ], systemPrompt: _systemPrompt)
          .timeout(
            const Duration(minutes: 2),
            onTimeout: (sink) {
              sink.addError(Exception('生成超时，请稍后重试'));
            },
          )
          .forEach((event) {
            if (!mounted) return;
            if (event is AiTextEvent) {
              buffer.write(event.text);
              final text = buffer.toString();
              setState(() {
                _generatedPreview = _formatLivePreview(text);
                _generationStatus = '已生成 ${text.length} 字';
              });
            }
          });

      final raw = buffer.toString();
      setState(() => _generationStatus = '正在解析结果...');
      final character = _parseCharacter(raw);
      if (!mounted) return;

      final edited = await Navigator.push<Character>(
        context,
        MaterialPageRoute(
          builder: (_) => CharacterEditScreen(
            character: character,
            index: widget.index,
            isCreating: true,
          ),
        ),
      );
      if (!mounted) return;
      if (edited != null) Navigator.pop(context, edited);
    } catch (e) {
      if (mounted) _showSnack('生成失败：$e', backgroundColor: AppColors.error);
    } finally {
      if (mounted) setState(() => _generating = false);
    }
  }

  String get _systemPrompt =>
      '你是专业的角色卡创作助手。你必须只输出一个合法 JSON 对象，不要输出 Markdown、解释、代码块或额外文字。';

  String _buildPrompt(String scene, int minChars) {
    return '''
根据用户给出的场景描述创建一个可用于角色扮演聊天的角色卡。

场景描述：
$scene

要求：
1. 输出 JSON 对象，字段必须为：name, personality, greeting, myNickname, aiNickname。
2. name 是角色名称。
3. personality 必须不少于 $minChars 个中文字符，包含角色身份、人设性格、背景经历、剧情开局、关系张力、说话风格、互动边界、世界观要点。
4. greeting 是角色第一句开场白，应能直接开启剧情，包含场景动作和一句对用户说的话。
5. myNickname 是用户在故事中的称呼，默认可以是“你”或贴合场景的身份称呼。
6. aiNickname 是角色对自己的称呼或角色名。
7. 内容必须中文。
8. 不要把字段写成数组，不要省略字段，不要输出 JSON 以外的任何内容。
''';
  }

  Character _parseCharacter(String raw) {
    final jsonText = _extractJsonObject(raw);
    final data = jsonDecode(jsonText) as Map<String, dynamic>;

    String read(String key) => (data[key] as String?)?.trim() ?? '';
    final name = read('name');
    final personality = read('personality');
    if (name.isEmpty || personality.isEmpty) {
      throw const FormatException('AI 返回缺少角色名称或人设');
    }

    return Character(
      id: 0,
      name: name,
      avatar: 'assets/images/default_avatar.png',
      personality: personality,
      greeting: read('greeting'),
      myNickname: read('myNickname').isEmpty ? '你' : read('myNickname'),
      aiNickname: read('aiNickname'),
    );
  }

  String _formatLivePreview(String raw) {
    final name = _readJsonStringValue(raw, 'name');
    final personality = _readJsonStringValue(raw, 'personality');
    final greeting = _readJsonStringValue(raw, 'greeting');
    final myNickname = _readJsonStringValue(raw, 'myNickname');
    final aiNickname = _readJsonStringValue(raw, 'aiNickname');

    final sections = <String>[];
    if (name.isNotEmpty) sections.add('角色名称：$name');
    if (aiNickname.isNotEmpty) sections.add('AI 称呼：$aiNickname');
    if (myNickname.isNotEmpty) sections.add('我的称呼：$myNickname');
    if (personality.isNotEmpty) sections.add('角色设定：\n$personality');
    if (greeting.isNotEmpty) sections.add('开场白：\n$greeting');

    if (sections.isEmpty) {
      return '正在接收结构化角色卡...';
    }
    return sections.join('\n\n');
  }

  String _readJsonStringValue(String raw, String key) {
    final keyIndex = raw.indexOf('"$key"');
    if (keyIndex == -1) return '';

    final colonIndex = raw.indexOf(':', keyIndex + key.length + 2);
    if (colonIndex == -1) return '';

    var start = -1;
    for (var i = colonIndex + 1; i < raw.length; i++) {
      if (raw[i].trim().isEmpty) continue;
      if (raw[i] != '"') return '';
      start = i + 1;
      break;
    }
    if (start == -1) return '';

    final buffer = StringBuffer();
    var escaped = false;
    var closed = false;
    for (var i = start; i < raw.length; i++) {
      final char = raw[i];
      if (escaped) {
        buffer.write(r'\');
        buffer.write(char);
        escaped = false;
      } else if (char == r'\') {
        escaped = true;
      } else if (char == '"') {
        closed = true;
        break;
      } else {
        buffer.write(char);
      }
    }
    if (escaped) buffer.write(r'\');

    final encoded = buffer.toString();
    if (encoded.isEmpty) return '';
    if (closed) {
      try {
        return (jsonDecode('"$encoded"') as String).trim();
      } catch (_) {
        return _decodeLooseJsonString(encoded).trim();
      }
    }
    return _decodeLooseJsonString(encoded).trim();
  }

  String _decodeLooseJsonString(String value) {
    return value
        .replaceAll(r'\n', '\n')
        .replaceAll(r'\r', '\r')
        .replaceAll(r'\t', '\t')
        .replaceAll(r'\"', '"')
        .replaceAll(r'\\', r'\');
  }

  String _extractJsonObject(String raw) {
    final text = raw.trim();
    final start = text.indexOf('{');
    if (start == -1) throw const FormatException('AI 未返回 JSON');

    var depth = 0;
    var inString = false;
    var escaped = false;
    for (var i = start; i < text.length; i++) {
      final char = text[i];
      if (inString) {
        if (escaped) {
          escaped = false;
        } else if (char == r'\') {
          escaped = true;
        } else if (char == '"') {
          inString = false;
        }
        continue;
      }

      if (char == '"') {
        inString = true;
      } else if (char == '{') {
        depth++;
      } else if (char == '}') {
        depth--;
        if (depth == 0) return text.substring(start, i + 1);
      }
    }

    throw const FormatException('AI 返回的 JSON 不完整');
  }

  void _showSnack(String message, {Color? backgroundColor}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: backgroundColor),
    );
  }
}
