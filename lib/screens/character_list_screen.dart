import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';
import '../models/character.dart';
import '../models/chat_session.dart';
import '../widgets/warm_background.dart';
import 'chat_screen.dart';

class CharacterListScreen extends StatefulWidget {
  const CharacterListScreen({super.key});

  @override
  State<CharacterListScreen> createState() => _CharacterListScreenState();
}

class _CharacterListScreenState extends State<CharacterListScreen> {
  final List<Character> _characters = [
    Character(id: 'ai_1', name: '小助手', avatar: '🤖', description: '你的智能AI助手，随时为你解答问题', personality: '友好、专业、耐心', greeting: '你好！有什么可以帮你的吗？', tags: ['助手', '问答']),
    Character(id: 'ai_2', name: '诗人', avatar: '📝', description: '一位才华横溢的诗人，能为你创作优美的诗句', personality: '浪漫、文艺', greeting: '月光如水，诗意盎然。', tags: ['创作', '诗歌']),
    Character(id: 'ai_3', name: '朋友', avatar: '😊', description: '一个温暖的朋友，陪你聊天解闷', personality: '开朗、幽默', greeting: '嘿！好久不见！', tags: ['聊天', '陪伴']),
    Character(id: 'ai_4', name: '老师', avatar: '👨‍🏫', description: '一位知识渊博的老师，帮你解答学习问题', personality: '严谨、耐心', greeting: '同学们好！', tags: ['教育', '学习']),
    Character(id: 'ai_5', name: '健身教练', avatar: '💪', description: '专业的健身教练，为你制定训练计划', personality: '积极、鼓励', greeting: '准备好开始训练了吗？', tags: ['健身', '健康']),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(child: _buildGrid()),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 6),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('${_characters.length} 个角色', style: AppTextStyles.greeting),
              const SizedBox(height: 2),
              const Text('发现', style: AppTextStyles.h1),
            ],
          ),
          const Spacer(),
          _iconBtn(Icons.search_rounded, () {}),
        ],
      ),
    );
  }

  Widget _iconBtn(IconData icon, VoidCallback onTap) {
    return TapScale(
      onTap: onTap,
      child: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(color: AppColors.surfaceAlt, borderRadius: BorderRadius.circular(10)),
        child: Icon(icon, size: 18, color: AppColors.textSecondary),
      ),
    );
  }

  Widget _buildGrid() {
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(14, 8, 14, 14),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 0.95,
      ),
      itemCount: _characters.length,
      itemBuilder: (context, i) => _buildCard(_characters[i], i),
    );
  }

  Widget _buildCard(Character character, int index) {
    final color = AppColors.avatarColors[index % AppColors.avatarColors.length];

    return TapScale(
      onTap: () => _startChat(character),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border, width: 0.5),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(16)),
              child: Center(child: Text(character.avatar, style: const TextStyle(fontSize: 26))),
            ),
            const SizedBox(height: 10),
            Text(character.name, style: AppTextStyles.label),
            const SizedBox(height: 3),
            Text(character.description, style: AppTextStyles.bodySmall, maxLines: 1, overflow: TextOverflow.ellipsis, textAlign: TextAlign.center),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: character.tags.take(2).map((tag) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                  decoration: BoxDecoration(color: AppColors.surfaceAlt, borderRadius: BorderRadius.circular(5)),
                  child: Text(tag, style: AppTextStyles.labelSmall.copyWith(fontSize: 10)),
                ),
              )).toList(),
            ),
          ],
        ),
      ),
    );
  }

  void _startChat(Character character) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => ChatScreen(
      session: ChatSession(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        characterId: character.id,
        characterName: character.name,
        characterAvatar: character.avatar,
        messages: [],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    )));
  }
}
