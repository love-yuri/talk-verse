import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_dimensions.dart';
import '../constants/app_text_styles.dart';
import '../models/character.dart';

/// 角色列表屏幕
/// 显示所有可用的AI角色
class CharacterListScreen extends StatefulWidget {
  const CharacterListScreen({super.key});

  @override
  State<CharacterListScreen> createState() => _CharacterListScreenState();
}

class _CharacterListScreenState extends State<CharacterListScreen> {
  // 临时数据，后续会从状态管理获取
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
      appBar: _buildAppBar(),
      body: _buildBody(),
    );
  }

  /// 构建应用栏
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.surface,
      elevation: 0,
      title: const Text(
        '角色列表',
        style: AppTextStyles.h3,
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.search, color: AppColors.textSecondary),
          onPressed: () {
            // TODO: 实现搜索功能
          },
        ),
      ],
    );
  }

  /// 构建主体内容
  Widget _buildBody() {
    return ListView.builder(
      padding: const EdgeInsets.all(AppDimensions.paddingLg),
      itemCount: _characters.length,
      itemBuilder: (context, index) {
        final character = _characters[index];
        return _buildCharacterCard(character);
      },
    );
  }

  /// 构建角色卡片
  Widget _buildCharacterCard(Character character) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppDimensions.spacingMd),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          onTap: () => _startChat(character),
          child: Padding(
            padding: const EdgeInsets.all(AppDimensions.paddingLg),
            child: Row(
              children: [
                _buildCharacterAvatar(character),
                const SizedBox(width: AppDimensions.spacingLg),
                Expanded(
                  child: _buildCharacterInfo(character),
                ),
                _buildStartButton(character),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 构建角色头像
  Widget _buildCharacterAvatar(Character character) {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: AppColors.primaryLight.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
      ),
      child: Center(
        child: Text(
          character.avatar,
          style: const TextStyle(fontSize: 32),
        ),
      ),
    );
  }

  /// 构建角色信息
  Widget _buildCharacterInfo(Character character) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          character.name,
          style: AppTextStyles.labelLarge,
        ),
        const SizedBox(height: AppDimensions.spacingXs),
        Text(
          character.description,
          style: AppTextStyles.bodySmall,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: AppDimensions.spacingSm),
        _buildTags(character.tags),
      ],
    );
  }

  /// 构建标签
  Widget _buildTags(List<String> tags) {
    return Wrap(
      spacing: AppDimensions.spacingSm,
      children: tags.map((tag) {
        return Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 8,
            vertical: 4,
          ),
          decoration: BoxDecoration(
            color: AppColors.primaryLight.withOpacity(0.1),
            borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
          ),
          child: Text(
            tag,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.primary,
            ),
          ),
        );
      }).toList(),
    );
  }

  /// 构建开始按钮
  Widget _buildStartButton(Character character) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
      ),
      child: const Text(
        '开始',
        style: TextStyle(
          color: Colors.white,
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  /// 开始聊天
  void _startChat(Character character) {
    // TODO: 创建新的聊天会话并跳转
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('开始与${character.name}对话'),
      ),
    );
  }
}
