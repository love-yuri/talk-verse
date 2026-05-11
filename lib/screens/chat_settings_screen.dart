import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../models/ai_settings.dart';
import '../models/character.dart';
import '../models/message.dart';
import '../services/token_usage_service.dart';
import '../widgets/warm_background.dart';

class ChatSettingsScreen extends StatefulWidget {
  final AiSettings aiSettings;
  final void Function(int index) onSwitchConfig;
  final VoidCallback onClearChat;
  final VoidCallback onDeleteChat;
  final Character? character;
  final int characterIndex;
  final VoidCallback? onEditCharacter;
  final List<Message> messages;
  final String? systemPrompt;
  final String? sessionId;

  const ChatSettingsScreen({
    super.key,
    required this.aiSettings,
    required this.onSwitchConfig,
    required this.onClearChat,
    required this.onDeleteChat,
    this.character,
    this.characterIndex = 0,
    this.onEditCharacter,
    this.messages = const [],
    this.systemPrompt,
    this.sessionId,
  });

  @override
  State<ChatSettingsScreen> createState() => _ChatSettingsScreenState();
}

class _ChatSettingsScreenState extends State<ChatSettingsScreen> {
  late int _selectedIndex;
  int _sessionTotalTokens = 0;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.aiSettings.activeConfigIndex;
    _loadSessionTokens();
  }

  Future<void> _loadSessionTokens() async {
    if (widget.sessionId == null) return;
    final sessionRecords = await TokenUsageService().recordsForSession(widget.sessionId!);
    if (!mounted) return;
    setState(() {
      _sessionTotalTokens = sessionRecords.fold<int>(0, (sum, r) => sum + r.totalTokens);
    });
  }

  @override
  Widget build(BuildContext context) {
    final configs = widget.aiSettings.configs;
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(children: [
        _buildAppBar(),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionTitle('当前配置'),
                const SizedBox(height: 12),
                _ComboBox<ApiConfig>(
                  items: configs,
                  selectedIndex: _selectedIndex,
                  itemBuilder: (c, isActive) => _comboItem(c, isActive),
                  displayBuilder: (c) => _comboDisplay(c),
                  onChanged: (index) {
                    setState(() => _selectedIndex = index);
                    widget.onSwitchConfig(index);
                  },
                ),
                const SizedBox(height: 10),
                _buildCurrentConfigInfo(configs[_selectedIndex]),
                const SizedBox(height: 28),
                _buildSessionInfo(),
                const SizedBox(height: 28),
                _buildSectionTitle('操作'),
                const SizedBox(height: 12),
                if (widget.character != null) ...[
                  _buildEditCharacterBtn(),
                  const SizedBox(height: 10),
                ],
                _buildClearBtn(),
                const SizedBox(height: 10),
                _buildDeleteBtn(),
              ],
            ),
          ),
        ),
      ]),
    );
  }

  Widget _comboItem(ApiConfig c, bool active) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            gradient: active ? const LinearGradient(colors: [Color(0xFFE8B4F8), Color(0xFFD4BBFF)]) : null,
            color: active ? null : const Color(0xFFF5EFF8),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(Icons.smart_toy_rounded, size: 15, color: active ? Colors.white : AppColors.textTertiary),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(c.name, style: TextStyle(fontFamily: 'MapleMono', fontSize: 13, fontWeight: FontWeight.w600, color: active ? AppColors.accent : const Color(0xFF2D2D2D))),
              Text(c.model, style: TextStyle(fontFamily: 'MapleMono', fontSize: 10, color: Colors.grey[400])),
            ],
          ),
        ),
        if (active) const Icon(Icons.check, size: 16, color: AppColors.accent),
      ]),
    );
  }

  Widget _comboDisplay(ApiConfig c) {
    return Row(children: [
      Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [Color(0xFFE8B4F8), Color(0xFFD4BBFF)]),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(Icons.smart_toy_rounded, size: 15, color: Colors.white),
      ),
      const SizedBox(width: 10),
      Expanded(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(c.name, style: const TextStyle(fontFamily: 'MapleMono', fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF2D2D2D))),
            Text(c.model, style: TextStyle(fontFamily: 'MapleMono', fontSize: 11, color: Colors.grey[400])),
          ],
        ),
      ),
      const Icon(Icons.expand_more_rounded, color: AppColors.accent),
    ]);
  }

  Widget _buildAppBar() {
    return Container(
      padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.chatAppBarStart, AppColors.chatAppBarMid, AppColors.chatAppBarEnd],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(children: [
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
          const SizedBox(width: 10),
          const Text('聊天设置', style: TextStyle(fontFamily: 'MapleMono', fontSize: 17, fontWeight: FontWeight.w600, color: Colors.white, letterSpacing: -0.41)),
        ]),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(title, style: const TextStyle(fontFamily: 'MapleMono', fontSize: 15, fontWeight: FontWeight.w600, color: Color(0xFF6B4E9B)));
  }

  Widget _buildCurrentConfigInfo(ApiConfig config) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.accent.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.accent.withValues(alpha: 0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _infoRow('地址', config.baseUrl),
          const SizedBox(height: 6),
          _infoRow('模型', config.model),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(width: 40, child: Text(label, style: TextStyle(fontFamily: 'MapleMono', fontSize: 12, color: Colors.grey[500]))),
        Expanded(child: Text(value, style: const TextStyle(fontFamily: 'MapleMono', fontSize: 12, color: Color(0xFF2D2D2D)))),
      ],
    );
  }

  static int _estimateTokens(String text) => (text.length / 2).ceil();

  Widget _buildSessionInfo() {
    final realMessages = widget.messages.where((m) => m.type == MessageType.user || m.type == MessageType.ai).toList();
    final totalCount = realMessages.length;

    // 单轮请求预估输入：system prompt + 所有历史消息内容
    final allContent = realMessages.fold<String>('', (s, m) => '$s${m.content}');
    final promptText = widget.systemPrompt ?? '';
    final estimatedInput = _estimateTokens('$promptText$allContent');

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.accent.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.accent.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('会话信息', style: TextStyle(fontFamily: 'MapleMono', fontSize: 15, fontWeight: FontWeight.w600, color: Color(0xFF6B4E9B))),
          const SizedBox(height: 12),
          _sessionInfoRow('总对话数', '$totalCount 条'),
          const SizedBox(height: 6),
          _sessionInfoRow('单轮预估', '输入 ~$estimatedInput tokens'),
          const SizedBox(height: 6),
          _sessionInfoRow('累计已用', '$_sessionTotalTokens tokens'),
        ],
      ),
    );
  }

  Widget _sessionInfoRow(String label, String value) {
    return Row(
      children: [
        SizedBox(width: 72, child: Text(label, style: TextStyle(fontFamily: 'MapleMono', fontSize: 12, color: Colors.grey[500]))),
        Expanded(child: Text(value, style: const TextStyle(fontFamily: 'MapleMono', fontSize: 12, color: Color(0xFF2D2D2D)))),
      ],
    );
  }

  Widget _buildEditCharacterBtn() {
    return TapScale(
      onTap: () {
        Navigator.pop(context);
        widget.onEditCharacter?.call();
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(color: AppColors.accent.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(14)),
        child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(Icons.edit_rounded, size: 18, color: AppColors.accent),
          SizedBox(width: 8),
          Text('编辑角色', style: TextStyle(fontFamily: 'MapleMono', fontSize: 15, fontWeight: FontWeight.w500, color: AppColors.accent)),
        ]),
      ),
    );
  }

  Widget _buildClearBtn() {
    return TapScale(
      onTap: () {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: const Text('清空聊天记录'),
            content: const Text('确定要清空当前聊天记录吗？'),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('取消')),
              TextButton(onPressed: () { Navigator.pop(ctx); widget.onClearChat(); }, child: const Text('清空', style: TextStyle(color: Color(0xFFE65100)))),
            ],
          ),
        );
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(color: const Color(0xFFFFF3E0), borderRadius: BorderRadius.circular(14)),
        child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(Icons.cleaning_services_rounded, size: 18, color: Color(0xFFFF9800)),
          SizedBox(width: 8),
          Text('清空聊天记录', style: TextStyle(fontFamily: 'MapleMono', fontSize: 15, fontWeight: FontWeight.w500, color: Color(0xFFE65100))),
        ]),
      ),
    );
  }

  Widget _buildDeleteBtn() {
    return TapScale(
      onTap: () {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: const Text('删除聊天'),
            content: const Text('确定要删除该聊天吗？此操作不可撤销。'),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('取消')),
              TextButton(onPressed: () { Navigator.pop(ctx); widget.onDeleteChat(); }, child: const Text('删除', style: TextStyle(color: AppColors.error))),
            ],
          ),
        );
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(color: AppColors.error.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(14)),
        child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(Icons.delete_outline_rounded, size: 18, color: AppColors.error),
          SizedBox(width: 8),
          Text('删除聊天', style: TextStyle(fontFamily: 'MapleMono', fontSize: 15, fontWeight: FontWeight.w500, color: AppColors.error)),
        ]),
      ),
    );
  }
}

// ─── 通用 ComboBox 组件 ───

class _ComboBox<T> extends StatefulWidget {
  final List<T> items;
  final int selectedIndex;
  final Widget Function(T item, bool active) itemBuilder;
  final Widget Function(T item) displayBuilder;
  final ValueChanged<int> onChanged;

  const _ComboBox({
    required this.items,
    required this.selectedIndex,
    required this.itemBuilder,
    required this.displayBuilder,
    required this.onChanged,
  });

  @override
  State<_ComboBox<T>> createState() => _ComboBoxState<T>();
}

class _ComboBoxState<T> extends State<_ComboBox<T>> {
  final _triggerKey = GlobalKey();
  OverlayEntry? _overlay;
  bool _isOpen = false;

  @override
  void dispose() {
    _removeOverlay();
    super.dispose();
  }

  void _toggle() {
    if (_isOpen) {
      _removeOverlay();
    } else {
      _showOverlay();
    }
  }

  void _showOverlay() {
    final renderBox = _triggerKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return;
    final pos = renderBox.localToGlobal(Offset.zero);
    final size = renderBox.size;

    final overlay = Overlay.of(context);
    _overlay = OverlayEntry(builder: (ctx) => _DropdownOverlay(
      top: pos.dy + size.height + 4,
      left: pos.dx,
      width: size.width,
      items: widget.items,
      selectedIndex: widget.selectedIndex,
      itemBuilder: widget.itemBuilder,
      onSelect: (i) {
        widget.onChanged(i);
        _removeOverlay();
      },
      onDismiss: _removeOverlay,
    ));
    overlay.insert(_overlay!);
    setState(() => _isOpen = true);
  }

  void _removeOverlay() {
    _overlay?.remove();
    _overlay = null;
    _isOpen = false;
  }

  @override
  Widget build(BuildContext context) {
    final current = widget.items[widget.selectedIndex];
    return TapScale(
      key: _triggerKey,
      onTap: _toggle,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [BoxShadow(color: AppColors.shadow, blurRadius: 10, offset: const Offset(0, 4))],
          border: Border.all(
            color: _isOpen ? AppColors.accent : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: widget.displayBuilder(current),
      ),
    );
  }
}

class _DropdownOverlay<T> extends StatelessWidget {
  final double top;
  final double left;
  final double width;
  final List<T> items;
  final int selectedIndex;
  final Widget Function(T, bool) itemBuilder;
  final ValueChanged<int> onSelect;
  final VoidCallback onDismiss;

  const _DropdownOverlay({
    required this.top,
    required this.left,
    required this.width,
    required this.items,
    required this.selectedIndex,
    required this.itemBuilder,
    required this.onSelect,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final maxDropdownHeight = screenHeight - top - 40;

    return Stack(
      children: [
        // 点击遮罩层关闭
        Positioned.fill(
          child: GestureDetector(onTap: onDismiss, child: Container(color: Colors.transparent)),
        ),
        // 下拉列表
        Positioned(
          top: top,
          left: left,
          width: width,
          child: Material(
            elevation: 12,
            borderRadius: BorderRadius.circular(14),
            color: Colors.white,
            surfaceTintColor: Colors.white,
            child: Container(
              constraints: BoxConstraints(maxHeight: maxDropdownHeight.clamp(60, 320)),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
              ),
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 6),
                shrinkWrap: true,
                children: items.asMap().entries.map((e) {
                  final isActive = e.key == selectedIndex;
                  return _HoverItem(
                    onTap: () => onSelect(e.key),
                    builder: (hovered) => Container(
                      margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                      decoration: BoxDecoration(
                        color: isActive
                            ? AppColors.accent.withValues(alpha: 0.1)
                            : hovered
                                ? const Color(0xFFF5EFF8)
                                : Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: itemBuilder(e.value, isActive),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ─── 悬停高亮组件 ───

class _HoverItem extends StatefulWidget {
  final VoidCallback onTap;
  final Widget Function(bool hovered) builder;

  const _HoverItem({required this.onTap, required this.builder});

  @override
  State<_HoverItem> createState() => _HoverItemState();
}

class _HoverItemState extends State<_HoverItem> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: widget.onTap,
      onTapDown: (_) => setState(() => _hovered = true),
      onTapUp: (_) => setState(() => _hovered = false),
      onTapCancel: () => setState(() => _hovered = false),
      child: MouseRegion(
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        cursor: SystemMouseCursors.click,
        child: widget.builder(_hovered),
      ),
    );
  }
}
