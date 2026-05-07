import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../models/character.dart';

class CharacterListScreen extends StatefulWidget {
  const CharacterListScreen({super.key});

  @override
  State<CharacterListScreen> createState() => _CharacterListScreenState();
}

class _CharacterListScreenState extends State<CharacterListScreen> {
  final List<Character> _characters = [
    Character(
      id: 'ai_1',
      name: '小助手',
      avatar: '🤖',
      description: '你的智能AI助手，随时为你解答问题',
      personality: '友好、专业、耐心',
      greeting: '你好！我是你的智能助手，有什么可以帮你的吗？',
      tags: ['助手', '问答'],
    ),
    Character(
      id: 'ai_2',
      name: '诗人',
      avatar: '📝',
      description: '一位才华横溢的诗人，能为你创作优美的诗句',
      personality: '浪漫、文艺、感性',
      greeting: '月光如水，诗意盎然。让我们一起在文字的海洋中遨游吧。',
      tags: ['创作', '诗歌'],
    ),
    Character(
      id: 'ai_3',
      name: '朋友',
      avatar: '😊',
      description: '一个温暖的朋友，陪你聊天解闷',
      personality: '开朗、幽默、善解人意',
      greeting: '嘿！好久不见，最近怎么样？',
      tags: ['聊天', '陪伴'],
    ),
    Character(
      id: 'ai_4',
      name: '老师',
      avatar: '👨‍🏫',
      description: '一位知识渊博的老师，帮你解答学习问题',
      personality: '严谨、耐心、专业',
      greeting: '同学们好！今天想学习什么呢？',
      tags: ['教育', '学习'],
    ),
    Character(
      id: 'ai_5',
      name: '健身教练',
      avatar: '💪',
      description: '专业的健身教练，为你制定训练计划',
      personality: '积极、鼓励、专业',
      greeting: '准备好开始今天的训练了吗？让我们动起来！',
      tags: ['健身', '健康'],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(child: _buildCharacterList()),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '角色',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${_characters.length} 个角色等你探索',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textTertiary,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border, width: 0.5),
            ),
            child: Icon(Icons.search_rounded, size: 20, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildCharacterList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      itemCount: _characters.length,
      itemBuilder: (context, index) {
        return _buildCharacterCard(_characters[index], index);
      },
    );
  }

  Widget _buildCharacterCard(Character character, int index) {
    final gradient = AppColors.avatarGradients[index % AppColors.avatarGradients.length];

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: () => _startChat(character),
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border, width: 0.5),
            ),
            child: Row(
              children: [
                // 头像
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: gradient,
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(
                    child: Text(character.avatar, style: const TextStyle(fontSize: 28)),
                  ),
                ),
                const SizedBox(width: 14),
                // 信息
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        character.name,
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        character.description,
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                          height: 1.4,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          ...character.tags.map((tag) => Padding(
                            padding: const EdgeInsets.only(right: 6),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: gradient[0].withValues(alpha: 0.08),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                tag,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: gradient[0],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          )),
                        ],
                      ),
                    ],
                  ),
                ),
                // 箭头
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 16,
                  color: AppColors.textTertiary,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _startChat(Character character) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('开始与${character.name}对话')),
    );
  }
}
