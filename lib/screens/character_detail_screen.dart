import 'dart:io';

import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_dimensions.dart';
import '../models/character.dart';
import '../models/chat_session.dart';
import '../services/chat_storage_service.dart';
import '../services/role_card_sync_service.dart';
import '../widgets/glass_header.dart';
import '../widgets/warm_background.dart';
import 'character_edit_screen.dart';
import 'chat_screen.dart';

class CharacterDetailScreen extends StatelessWidget {
  static const int _previewTextLimit = 800;
  static const int _fullTextChunkSize = 1200;

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
                child: const Icon(
                  Icons.arrow_back_ios_new,
                  size: 16,
                  color: Colors.white,
                ),
              ),
            ),
            const Spacer(),
            GlassHeader.iconBtn(
              Icons.cloud_upload_rounded,
              onTap: () => _publishCharacter(context),
            ),
            const SizedBox(width: 8),
            GlassHeader.iconBtn(
              Icons.edit_rounded,
              onTap: () => _editCharacter(context),
            ),
            const SizedBox(width: 8),
            GlassHeader.iconBtn(
              Icons.delete_outline_rounded,
              onTap: () => _confirmDelete(context),
            ),
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
                  colors: [
                    color.withValues(alpha: 0.4),
                    color.withValues(alpha: 0.15),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: color.withValues(alpha: 0.25),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: ClipOval(child: _buildAvatar(context, color)),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            character.name,
            style: const TextStyle(
              fontFamily: 'MapleMono',
              fontSize: 22,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
              letterSpacing: -0.41,
            ),
          ),
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
          BoxShadow(
            color: color.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _infoRow(context, '性格特点', character.personality),
          const SizedBox(height: 16),
          _infoRow(
            context,
            '开场问候',
            character.greeting.isNotEmpty ? character.greeting : '无',
          ),
          const SizedBox(height: 16),
          _infoRow(context, '我的称呼', character.myNickname),
          const SizedBox(height: 16),
          _infoRow(
            context,
            'AI 称呼',
            character.aiNickname.isNotEmpty
                ? character.aiNickname
                : character.name,
          ),
        ],
      ),
    );
  }

  Widget _infoRow(BuildContext context, String label, String value) {
    final isLongText = value.length > _previewTextLimit;
    final preview = isLongText
        ? '${value.substring(0, _previewTextLimit).trimRight()}...'
        : value;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'MapleMono',
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          preview,
          style: const TextStyle(
            fontFamily: 'MapleMono',
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: AppColors.textPrimary,
            height: 1.5,
          ),
        ),
        if (isLongText) ...[
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: () => _showFullText(context, label, value),
              icon: const Icon(Icons.article_outlined, size: 16),
              label: Text('查看全部（${value.length} 字）'),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.accent,
                textStyle: const TextStyle(
                  fontFamily: 'MapleMono',
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
                visualDensity: VisualDensity.compact,
              ),
            ),
          ),
        ],
      ],
    );
  }

  void _showFullText(BuildContext context, String title, String value) {
    final chunks = _chunkText(value, _fullTextChunkSize);

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return DraggableScrollableSheet(
          initialChildSize: 0.82,
          minChildSize: 0.45,
          maxChildSize: 0.94,
          builder: (context, scrollController) {
            return Container(
              decoration: const BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 10),
                  Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.border,
                      borderRadius: BorderRadius.circular(99),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 14, 12, 10),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            style: const TextStyle(
                              fontFamily: 'MapleMono',
                              fontSize: 17,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.pop(ctx),
                          icon: const Icon(Icons.close_rounded),
                          color: AppColors.textSecondary,
                          tooltip: '关闭',
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1, color: AppColors.divider),
                  Expanded(
                    child: ListView.builder(
                      controller: scrollController,
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
                      itemCount: chunks.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: EdgeInsets.only(
                            bottom: index == chunks.length - 1 ? 0 : 12,
                          ),
                          child: Text(
                            chunks[index],
                            style: const TextStyle(
                              fontFamily: 'MapleMono',
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              color: AppColors.textPrimary,
                              height: 1.6,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  List<String> _chunkText(String text, int chunkSize) {
    final chunks = <String>[];
    var start = 0;
    while (start < text.length) {
      var end = start + chunkSize;
      if (end >= text.length) {
        end = text.length;
      } else {
        final previousCodeUnit = text.codeUnitAt(end - 1);
        if (previousCodeUnit >= 0xD800 && previousCodeUnit <= 0xDBFF) {
          end--;
        }
      }
      chunks.add(text.substring(start, end));
      start = end;
    }
    return chunks;
  }

  Widget _buildStartButton(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
      decoration: BoxDecoration(color: AppColors.background),
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
            textStyle: const TextStyle(
              fontFamily: 'MapleMono',
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
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
    );
    final newId = await ChatStorageService().saveSession(session);
    if (!context.mounted) return;
    final savedSession = session.copyWith(id: newId);
    Navigator.push(context, _chatRoute(savedSession, character));
  }

  Future<void> _publishCharacter(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('发布角色卡'),
        content: Text('将「${character.name}」发布到共享区？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('发布'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    try {
      await RoleCardSyncService().publish(character);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('角色卡已发布到共享区'),
          backgroundColor: AppColors.success,
        ),
      );
    } catch (e) {
      debugPrint('发布角色卡失败: $e');
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()), backgroundColor: AppColors.error),
      );
    }
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

  Widget _buildAvatar(BuildContext context, Color color) {
    final fallback = Icon(
      Icons.person,
      size: 50,
      color: color.withValues(alpha: 0.6),
    );
    if (character.avatar.startsWith('/')) {
      return Image.file(
        File(character.avatar),
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => fallback,
      );
    }
    return Image.asset(
      character.avatar,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) => fallback,
    );
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
    pageBuilder: (context, animation, secondaryAnimation) =>
        ChatScreen(session: session, character: character),
    transitionDuration: const Duration(milliseconds: 350),
    reverseTransitionDuration: const Duration(milliseconds: 300),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final curved = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
      );
      return FadeTransition(
        opacity: curved,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 0.03),
            end: Offset.zero,
          ).animate(curved),
          child: child,
        ),
      );
    },
  );
}
