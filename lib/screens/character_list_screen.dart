import 'dart:ui';
import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../models/character.dart';
import '../models/chat_session.dart';
import '../services/chat_storage_service.dart';
import '../widgets/warm_background.dart';
import 'chat_screen.dart';

class CharacterListScreen extends StatefulWidget {
  const CharacterListScreen({super.key});

  @override
  State<CharacterListScreen> createState() => _CharacterListScreenState();
}

class _CharacterListScreenState extends State<CharacterListScreen> {
  final List<Character> _characters = [
    Character(id: 'ai_1', name: '小助手', avatar: 'assets/images/default_avatar.png', description: '你的智能AI助手，随时为你解答问题', personality: '友好、专业、耐心', greeting: '你好！有什么可以帮你的吗？', tags: ['助手', '问答']),
    Character(id: 'ai_2', name: '诗人', avatar: 'assets/images/default_avatar.png', description: '一位才华横溢的诗人，能为你创作优美的诗句', personality: '浪漫、文艺', greeting: '月光如水，诗意盎然。', tags: ['创作', '诗歌']),
    Character(id: 'ai_3', name: '朋友', avatar: 'assets/images/default_avatar.png', description: '一个温暖的朋友，陪你聊天解闷', personality: '开朗、幽默', greeting: '嘿！好久不见！', tags: ['聊天', '陪伴']),
    Character(id: 'ai_4', name: '老师', avatar: 'assets/images/default_avatar.png', description: '一位知识渊博的老师，帮你解答学习问题', personality: '严谨、耐心', greeting: '同学们好！', tags: ['教育', '学习']),
    Character(id: 'ai_5', name: '健身教练', avatar: 'assets/images/default_avatar.png', description: '专业的健身教练，为你制定训练计划', personality: '积极、鼓励', greeting: '准备好开始训练了吗？', tags: ['健身', '健康']),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          _buildHeader(),
          Expanded(child: _buildGrid()),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.72),
            border: const Border(bottom: BorderSide(color: Color(0x1A000000), width: 0.5)),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 14),
            child: Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${_characters.length} 个角色可选', style: const TextStyle(fontFamily: 'MapleMono', fontSize: 13, fontWeight: FontWeight.w400, color: AppColors.textSecondary, letterSpacing: -0.08)),
                    const SizedBox(height: 2),
                    const Text('发现', style: TextStyle(fontFamily: 'MapleMono', fontSize: 22, fontWeight: FontWeight.w600, color: AppColors.textPrimary, letterSpacing: 0.35)),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGrid() {
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 0.88,
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
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(color: color.withValues(alpha: 0.2), blurRadius: 14, offset: const Offset(0, 6)),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Hero(
              tag: 'avatar_${character.id}',
              child: ClipRRect(
                borderRadius: BorderRadius.circular(29),
                child: Container(
                  width: 58,
                  height: 58,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [color.withValues(alpha: 0.3), color.withValues(alpha: 0.1)],
                    ),
                  ),
                  child: Image.asset(
                    character.avatar,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const Icon(Icons.person, size: 32, color: Colors.grey),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Text(character.name, style: const TextStyle(fontFamily: 'MapleMono', fontSize: 15, fontWeight: FontWeight.w600, color: Color(0xFF2D2D2D), letterSpacing: -0.24)),
            const SizedBox(height: 3),
            Text(character.description, style: TextStyle(fontFamily: 'MapleMono', fontSize: 11, fontWeight: FontWeight.w400, color: Colors.grey[500], letterSpacing: 0.07), maxLines: 1, overflow: TextOverflow.ellipsis, textAlign: TextAlign.center),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: character.tags.take(2).map((tag) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 3),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [color.withValues(alpha: 0.2), color.withValues(alpha: 0.08)],
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(tag, style: TextStyle(fontFamily: 'MapleMono', fontSize: 10, fontWeight: FontWeight.w500, color: color.withValues(alpha: 0.8))),
                ),
              )).toList(),
            ),
          ],
        ),
      ),
    );
  }

  void _startChat(Character character) {
    final session = ChatSession(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      characterId: character.id,
      characterName: character.name,
      characterAvatar: character.avatar,
      messages: [],
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    ChatStorageService().saveSession(session);
    Navigator.push(context, _chatRoute(session, character));
  }
}

Route _chatRoute(ChatSession session, Character character) {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => ChatScreen(session: session, character: character),
    transitionDuration: const Duration(milliseconds: 350),
    reverseTransitionDuration: const Duration(milliseconds: 300),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final curved = CurvedAnimation(parent: animation, curve: Curves.easeOutCubic);
      return FadeTransition(
        opacity: curved,
        child: SlideTransition(
          position: Tween<Offset>(begin: const Offset(0, 0.03), end: Offset.zero).animate(curved),
          child: child,
        ),
      );
    },
  );
}
