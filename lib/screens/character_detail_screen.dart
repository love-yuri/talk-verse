import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_dimensions.dart';
import '../constants/app_text_styles.dart';
import '../models/character.dart';
import '../models/chat_session.dart';
import '../services/chat_storage_service.dart';
import '../widgets/glass_header.dart';
import '../widgets/warm_background.dart';
import 'character_edit_screen.dart';
import 'chat_screen.dart';

class CharacterDetailScreen extends StatelessWidget {
  final Character character;
  final int index;
  final VoidCallback? onDelete;
  final void Function(Character updated)? onCharacterUpdated;

  const CharacterDetailScreen({
    super.key,
    required this.character,
    required this.index,
    this.onDelete,
    this.onCharacterUpdated,
  });

  @override
  Widget build(BuildContext context) {
    final color = AppColors.avatarColors[index % AppColors.avatarColors.length];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          _buildHeader(context, color),
          Expanded(child: _buildBody(context, color)),
          _buildStartButton(context),
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
          colors: [color.withValues(alpha: 0.4), AppColors.chatAppBarMid, color.withValues(alpha: 0.3)],
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
                child: const Icon(Icons.arrow_back_ios_new, size: 16, color: Colors.white),
              ),
            ),
            const Spacer(),
            GlassHeader.iconBtn(Icons.edit_rounded, onTap: () => _editCharacter(context)),
            const SizedBox(width: 8),
            GlassHeader.iconBtn(Icons.delete_outline_rounded, onTap: () => _confirmDelete(context)),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, Color color) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const SizedBox(height: 16),
          Hero(
            tag: 'avatar_${character.id}',
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [color.withValues(alpha: 0.4), color.withValues(alpha: 0.15)],
                ),
                boxShadow: [
                  BoxShadow(color: color.withValues(alpha: 0.25), blurRadius: 16, offset: const Offset(0, 6)),
                ],
              ),
              child: ClipOval(
                child: Image.asset(
                  character.avatar,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, _) => Icon(Icons.person, size: 50, color: color.withValues(alpha: 0.6)),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(character.name, style: const TextStyle(fontFamily: 'MapleMono', fontSize: 22, fontWeight: FontWeight.w600, color: AppColors.textPrimary, letterSpacing: -0.41)),
          const SizedBox(height: 8),
          Text(character.description, style: AppTextStyles.bodySmall, textAlign: TextAlign.center),
          const SizedBox(height: 20),
          _infoCard(context, color),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _infoCard(BuildContext context, Color color) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        border: Border.all(color: const Color(0xFFF0E6F6), width: 0.5),
        boxShadow: [
          BoxShadow(color: color.withValues(alpha: 0.08), blurRadius: 12, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _infoRow('性格特点', character.personality),
          const SizedBox(height: 16),
          _infoRow('开场问候', character.greeting),
          const SizedBox(height: 16),
          _infoRow('我的称呼', character.myNickname),
          const SizedBox(height: 16),
          _infoRow('AI 称呼', character.aiNickname.isNotEmpty ? character.aiNickname : character.name),
          if (character.tags.isNotEmpty) ...[
            const SizedBox(height: 16),
            const Text('标签', style: TextStyle(fontFamily: 'MapleMono', fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: character.tags.map((tag) => Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [color.withValues(alpha: 0.2), color.withValues(alpha: 0.08)],
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(tag, style: TextStyle(fontFamily: 'MapleMono', fontSize: 11, fontWeight: FontWeight.w500, color: color.withValues(alpha: 0.85))),
              )).toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontFamily: 'MapleMono', fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontFamily: 'MapleMono', fontSize: 14, fontWeight: FontWeight.w400, color: AppColors.textPrimary, height: 1.5)),
      ],
    );
  }

  Widget _buildStartButton(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
      decoration: BoxDecoration(
        color: AppColors.background,
      ),
      child: SizedBox(
        width: double.infinity,
        height: 50,
        child: ElevatedButton(
          onPressed: () => _startChat(context),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.accent,
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            textStyle: const TextStyle(fontFamily: 'MapleMono', fontSize: 16, fontWeight: FontWeight.w600),
          ),
          child: const Text('开始对话'),
        ),
      ),
    );
  }

  Future<void> _startChat(BuildContext context) async {
    final session = ChatSession(
      id: 0,
      characterId: character.id,
      characterName: character.name,
      characterAvatar: character.avatar,
      messages: [],
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    final newId = await ChatStorageService().saveSession(session);
    final savedSession = session.copyWith(id: newId);
    Navigator.push(context, _chatRoute(savedSession, character));
  }

  void _editCharacter(BuildContext context) async {
    final updated = await Navigator.push<Character>(
      context,
      MaterialPageRoute(
        builder: (_) => CharacterEditScreen(character: character, index: index),
      ),
    );
    if (updated != null && context.mounted) {
      onCharacterUpdated?.call(updated);
      Navigator.pop(context);
    }
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('删除角色'),
        content: Text('确定要删除「${character.name}」吗？此操作不可撤销。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              onDelete?.call();
              Navigator.pop(ctx);
              Navigator.pop(context);
            },
            child: const Text('删除', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
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
