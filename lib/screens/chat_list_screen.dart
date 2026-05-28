import 'dart:io';

import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';
import '../models/chat_session.dart';
import '../services/chat_storage_service.dart';
import '../widgets/glass_header.dart';
import '../widgets/warm_background.dart';
import 'chat_screen.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  final _storage = ChatStorageService();
  List<ChatSession> _sessions = [];
  bool _isSelectionMode = false;
  final Set<int> _selectedIds = {};

  @override
  void initState() {
    super.initState();
    _loadSessions();
  }

  Future<void> _loadSessions() async {
    final sessions = await _storage.load();
    if (mounted) setState(() => _sessions = sessions);
  }

  void _toggleSelectionMode() {
    setState(() {
      _isSelectionMode = !_isSelectionMode;
      if (!_isSelectionMode) _selectedIds.clear();
    });
  }

  void _toggleSelect(int id) {
    setState(() {
      if (_selectedIds.contains(id)) {
        _selectedIds.remove(id);
        if (_selectedIds.isEmpty) _isSelectionMode = false;
      } else {
        _selectedIds.add(id);
      }
    });
  }

  void _selectAll() {
    setState(() {
      if (_selectedIds.length == _sessions.length) {
        _selectedIds.clear();
      } else {
        _selectedIds.addAll(_sessions.map((s) => s.id));
      }
    });
  }

  Future<void> _deleteSelected() async {
    if (_selectedIds.isEmpty) return;
    final selected = _sessions.where((s) => _selectedIds.contains(s.id)).toList();
    final count = selected.length;
    final names = selected.map((s) => s.characterName).join('、');

    await _storage.deleteSessions(_selectedIds.toList());
    setState(() {
      _sessions.removeWhere((s) => _selectedIds.contains(s.id));
      _selectedIds.clear();
      _isSelectionMode = false;
    });

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('已删除 $count 个对话（$names）'),
      action: SnackBarAction(label: '撤销', onPressed: () {
        for (final s in selected) {
          _storage.saveSession(s);
        }
        _loadSessions();
      }),
    ));
  }

  Future<void> _deleteAll() async {
    if (_sessions.isEmpty) return;
    final backup = List<ChatSession>.from(_sessions);
    final ids = _sessions.map((s) => s.id).toList();

    await _storage.deleteSessions(ids);
    setState(() {
      _sessions.clear();
      _selectedIds.clear();
      _isSelectionMode = false;
    });

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('已清空全部 ${backup.length} 个对话'),
      action: SnackBarAction(label: '撤销', onPressed: () {
        for (final s in backup) {
          _storage.saveSession(s);
        }
        _loadSessions();
      }),
    ));
  }

  void _showDeleteConfirm() {
    if (_selectedIds.isEmpty) return;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('确认删除'),
        content: Text('确定删除选中的 ${_selectedIds.length} 个对话？'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('取消')),
          TextButton(
            onPressed: () { Navigator.pop(ctx); _deleteSelected(); },
            child: const Text('删除', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }

  void _showDeleteAllConfirm() {
    if (_sessions.isEmpty) return;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('清空全部对话'),
        content: Text('确定删除全部 ${_sessions.length} 个对话？此操作不可撤销。'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('取消')),
          TextButton(
            onPressed: () { Navigator.pop(ctx); _deleteAll(); },
            child: const Text('清空', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            child: _isSelectionMode ? _buildSelectionHeader() : _buildNormalHeader(),
          ),
          Expanded(child: _sessions.isEmpty ? _buildEmpty() : _buildList()),
          AnimatedSize(
            duration: const Duration(milliseconds: 280),
            curve: Curves.easeOutCubic,
            child: _isSelectionMode ? _buildBottomBar() : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  Widget _buildNormalHeader() {
    return GlassHeader(
      key: const ValueKey('normal'),
      subtitle: _getGreeting(),
      title: '对话',
      badge: '${_sessions.length}',
      actions: [
        GlassHeader.iconBtn(Icons.search_rounded, onTap: () {}),
        const SizedBox(width: 8),
        GlassHeader.iconBtn(Icons.edit_square, onTap: _sessions.isEmpty ? null : _toggleSelectionMode),
      ],
    );
  }

  Widget _buildSelectionHeader() {
    return GlassHeader(
      key: const ValueKey('selection'),
      subtitle: '已选',
      title: '${_selectedIds.length}',
      badge: '/${_sessions.length}',
      actions: [
        GlassHeader.iconBtn(
          _selectedIds.length == _sessions.length ? Icons.deselect : Icons.select_all,
          onTap: _selectAll,
        ),
        const SizedBox(width: 8),
        GlassHeader.iconBtn(Icons.close, onTap: _toggleSelectionMode),
      ],
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('🌸', style: TextStyle(fontFamily: 'MapleMono', fontSize: 48)),
          const SizedBox(height: 16),
          const Text('还没有对话', style: TextStyle(fontFamily: 'MapleMono', fontSize: 17, fontWeight: FontWeight.w600, color: AppColors.accent, letterSpacing: -0.41)),
          const SizedBox(height: 6),
          const Text('去发现页面，找到你的第一个聊天伙伴', style: TextStyle(fontFamily: 'MapleMono', fontSize: 13, fontWeight: FontWeight.w400, color: AppColors.textTertiary, letterSpacing: -0.08)),
        ],
      ),
    );
  }

  Widget _buildList() {
    return ListView.builder(
      padding: EdgeInsets.fromLTRB(16, 12, 16, _isSelectionMode ? 8 : 6),
      itemCount: _sessions.length,
      itemBuilder: (context, i) => _buildItem(_sessions[i]),
    );
  }

  Widget _buildItem(ChatSession session) {
    final colorIdx = session.characterId % AppColors.avatarColors.length;
    final color = AppColors.avatarColors[colorIdx];
    final isSelected = _selectedIds.contains(session.id);

    final content = GestureDetector(
      onLongPress: _isSelectionMode ? null : () {
        setState(() {
          _isSelectionMode = true;
          _selectedIds.add(session.id);
        });
      },
      child: TapScale(
        onTap: _isSelectionMode ? () => _toggleSelect(session.id) : () => _openChat(session),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.accentLight : AppColors.surfaceGlass,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected ? AppColors.accent.withValues(alpha: 0.38) : AppColors.border.withValues(alpha: 0.7),
              width: 0.8,
            ),
            boxShadow: [
              BoxShadow(color: AppColors.cardShadow, blurRadius: 16, offset: const Offset(0, 6)),
            ],
          ),
          child: Row(
            children: [
              AnimatedSize(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeOutCubic,
                child: _isSelectionMode
                    ? Padding(
                        padding: const EdgeInsets.only(right: 10),
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 200),
                          child: Icon(
                            isSelected ? Icons.check_circle : Icons.radio_button_unchecked,
                            key: ValueKey(isSelected),
                            size: 22,
                            color: isSelected ? AppColors.accent : AppColors.textTertiary,
                          ),
                        ),
                      )
                    : const SizedBox.shrink(),
              ),
              Hero(
                tag: 'avatar_${session.id}',
                transitionOnUserGestures: true,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(25),
                  child: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [color.withValues(alpha: 0.42), AppColors.surface.withValues(alpha: 0.75)],
                      ),
                    ),
                    child: session.characterAvatar.startsWith('/')
                        ? Image.file(File(session.characterAvatar), fit: BoxFit.cover, errorBuilder: (c, e, s) => const Icon(Icons.person, size: 26, color: Colors.grey))
                        : Image.asset(session.characterAvatar, fit: BoxFit.cover, errorBuilder: (c, e, s) => const Icon(Icons.person, size: 26, color: Colors.grey)),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(session.characterName, style: AppTextStyles.label),
                    const SizedBox(height: 4),
                    Text('点击继续对话 ♡', style: AppTextStyles.bodySmall, maxLines: 1, overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );

    // 选择模式下不显示滑动删除
    if (_isSelectionMode) return content;

    return Dismissible(
      key: Key('${session.id}'),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(color: AppColors.error, borderRadius: BorderRadius.circular(16)),
        child: const Icon(Icons.delete_outline_rounded, color: Colors.white, size: 20),
      ),
      onDismissed: (_) => _deleteSession(session),
      child: content,
    );
  }

  Widget _buildBottomBar() {
    final hasSelection = _selectedIds.isNotEmpty;
    return Container(
      padding: EdgeInsets.only(
        left: 16, right: 16, top: 10,
        bottom: MediaQuery.of(context).padding.bottom + 10,
      ),
      decoration: BoxDecoration(
        color: AppColors.surfaceGlass,
        border: Border(top: BorderSide(color: AppColors.border.withValues(alpha: 0.7), width: 0.6)),
        boxShadow: [
          BoxShadow(color: AppColors.cardShadow, blurRadius: 16, offset: const Offset(0, -6)),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _bottomBarBtn(
              icon: Icons.delete_sweep,
              label: '删除全部',
              color: AppColors.error,
              onTap: _showDeleteAllConfirm,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _bottomBarBtn(
              icon: Icons.delete_outline,
              label: hasSelection ? '删除选中 (${_selectedIds.length})' : '删除选中',
              color: hasSelection ? AppColors.accent : AppColors.textTertiary,
              onTap: hasSelection ? _showDeleteConfirm : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _bottomBarBtn({
    required IconData icon,
    required String label,
    required Color color,
    VoidCallback? onTap,
  }) {
    return TapScale(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.3), width: 0.5),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(width: 6),
            Text(label, style: TextStyle(fontFamily: 'MapleMono', fontSize: 13, fontWeight: FontWeight.w500, color: color)),
          ],
        ),
      ),
    );
  }

  String _getGreeting() {
    final h = DateTime.now().hour;
    if (h < 6) return '夜深了';
    if (h < 12) return '早上好';
    if (h < 14) return '中午好';
    if (h < 18) return '下午好';
    return '晚上好';
  }

  void _deleteSession(ChatSession session) {
    setState(() => _sessions.remove(session));
    _storage.deleteSession(session.id);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('已删除与${session.characterName}的对话'),
      action: SnackBarAction(label: '撤销', onPressed: () {
        setState(() => _sessions.add(session));
        _storage.saveSession(session);
      }),
    ));
  }

  Future<void> _openChat(ChatSession session) async {
    await Navigator.push(context, _chatRoute(session));
    _loadSessions();
  }
}

Route _chatRoute(ChatSession session) {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => ChatScreen(session: session, heroTag: 'avatar_${session.id}'),
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
