import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../constants/app_dimensions.dart';
import '../models/character.dart';
import '../services/character_import_service.dart';
import '../services/character_storage_service.dart';
import '../services/role_card_sync_service.dart';
import '../widgets/character_card.dart';
import '../widgets/glass_header.dart';
import 'character_detail_screen.dart';
import 'character_edit_screen.dart';

class CharacterListScreen extends StatefulWidget {
  const CharacterListScreen({super.key});

  @override
  State<CharacterListScreen> createState() => _CharacterListScreenState();
}

class _CharacterListScreenState extends State<CharacterListScreen>
    with SingleTickerProviderStateMixin {
  final _storage = CharacterStorageService();
  final _roleCardSync = RoleCardSyncService();
  final _selectedIds = <int>{};

  late final TabController _tabCtrl;

  List<DiscoverCharacterItem> _localCharacters = [];
  List<DiscoverCharacterItem> _remoteCharacters = [];
  bool _loading = true;
  bool _syncing = false;
  bool _selectionMode = false;
  int _activeIndex = 0;

  int get _totalCount => _localCharacters.length + _remoteCharacters.length;

  List<DiscoverCharacterItem> get _activeItems =>
      _activeIndex == 0 ? _localCharacters : _remoteCharacters;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 2, vsync: this);
    _tabCtrl.addListener(_onTabChanged);
    _loadCharacters();
  }

  @override
  void dispose() {
    _tabCtrl
      ..removeListener(_onTabChanged)
      ..dispose();
    super.dispose();
  }

  void _onTabChanged() {
    if (_tabCtrl.indexIsChanging) return;
    if (_activeIndex != _tabCtrl.index) {
      setState(() {
        _activeIndex = _tabCtrl.index;
        _selectionMode = false;
        _selectedIds.clear();
      });
    }
  }

  Future<void> _loadCharacters() async {
    final list = await _storage.loadForDiscover();
    if (!mounted) return;

    setState(() {
      _localCharacters = list.where((item) => !item.isRemote).toList();
      _remoteCharacters = list.where((item) => item.isRemote).toList();
      _loading = false;
    });

    _hasSelectionConsistency();
  }

  Future<void> _deleteCharacters(List<int> ids) async {
    if (ids.isEmpty) return;

    try {
      await _roleCardSync.deleteRemoteCardsByLocalIds(ids);
    } catch (e) {
      debugPrint('删除共享角色卡失败: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('本地删除成功，但远程同步失败：$e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }

    await _storage.deleteMany(ids);
    await _loadCharacters();
    if (!mounted) return;

    setState(() {
      _selectedIds.removeWhere((id) => ids.contains(id));
      _selectionMode = _selectedIds.isNotEmpty;
    });
  }

  void _hasSelectionConsistency() {
    final activeIds = _activeItems.map((item) => item.character.id).toSet();
    _selectedIds.retainWhere(activeIds.contains);

    setState(() {
      _selectionMode = _selectedIds.isNotEmpty;
    });
  }

  void _toggleSelectionMode() {
    setState(() {
      _selectionMode = !_selectionMode;
      if (!_selectionMode) {
        _selectedIds.clear();
      }
    });
  }

  void _toggleSelect(int id) {
    setState(() {
      if (_selectedIds.contains(id)) {
        _selectedIds.remove(id);
      } else {
        _selectedIds.add(id);
      }
      _selectionMode = _selectedIds.isNotEmpty;
    });
  }

  void _selectAll() {
    final activeIds = _activeItems.map((item) => item.character.id).toSet();
    setState(() {
      if (_selectedIds.length == activeIds.length) {
        _selectedIds.clear();
        _selectionMode = false;
      } else {
        _selectedIds
          ..clear()
          ..addAll(activeIds);
        _selectionMode = true;
      }
    });
  }

  Future<void> _deleteSelected() async {
    if (_selectedIds.isEmpty) return;

    final active = _activeItems
        .where((item) => _selectedIds.contains(item.character.id))
        .toList();
    final names = active.map((item) => item.character.name).join('、');

    if (!mounted) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('确认删除'),
        content: Text(
          '确定删除选中的 ${_selectedIds.length} 个角色？${names.isNotEmpty ? '\n$names' : ''}',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('删除', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    final ids = _selectedIds.toList();
    _selectedIds.clear();
    await _deleteCharacters(ids);
    if (!mounted) return;
    setState(() => _selectionMode = false);
  }

  Future<void> _deleteActiveAll() async {
    if (_activeItems.isEmpty) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(_activeIndex == 0 ? '清空本地角色' : '清空远程角色'),
        content: const Text('确定删除当前列表全部角色？此操作不可撤销。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('清空', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    final ids = _activeItems.map((item) => item.character.id).toList();
    _selectedIds.removeWhere((id) => ids.contains(id));

    await _deleteCharacters(ids);
    if (!mounted) return;
    setState(() {
      _selectionMode = false;
      _selectedIds.clear();
    });
  }

  Future<void> _syncWebDavCharacter() async {
    if (_syncing) return;

    setState(() => _syncing = true);
    try {
      final result = await _roleCardSync.syncRemoteToLocal();
      await _loadCharacters();
      if (!mounted) return;

      _showSnack(
        result.total == 0
            ? '共享区暂无新角色'
            : [
                if (result.inserted > 0) '新增 ${result.inserted}',
                if (result.updated > 0) '更新 ${result.updated}',
                if (result.localized > 0) '转为本地 ${result.localized}',
                if (result.removed > 0) '移除 ${result.removed}',
              ].join('，'),
        backgroundColor: AppColors.success,
      );
    } catch (e) {
      debugPrint('同步角色卡失败: $e');
      if (mounted) _showSnack(e.toString(), backgroundColor: AppColors.error);
    } finally {
      if (mounted) setState(() => _syncing = false);
    }
  }

  Future<void> _importCharacter() async {
    try {
      final result = await CharacterImportService.importFromFile();
      if (result == null || !mounted) return;

      // 跳转编辑页让用户确认/修改
      final newChar = await Navigator.push<Character>(
        context,
        MaterialPageRoute(
          builder: (_) => CharacterEditScreen(
            character: result.character,
            index: _totalCount,
            isCreating: true,
          ),
        ),
      );

      if (newChar != null) {
        await _storage.save(newChar);
        if (mounted) {
          _loadCharacters();
          _showSnack(
            '已导入「${newChar.name}」',
            backgroundColor: AppColors.success,
          );
        }
      }
    } catch (e) {
      debugPrint('导入角色卡失败: $e');
      if (mounted) _showSnack('导入失败：$e', backgroundColor: AppColors.error);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      floatingActionButton: FloatingActionButton(
        onPressed: _addCharacter,
        backgroundColor: AppColors.accent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        child: const Icon(Icons.add_rounded, color: Colors.white, size: 24),
      ),
      body: Column(
        children: [
          _buildHeader(),
          _buildSourceTabs(),
          Expanded(
            child: _loading
                ? _buildLoading()
                : TabBarView(
                    controller: _tabCtrl,
                    children: [
                      _buildGrid(
                        _localCharacters,
                        emptyTitle: '还没有本地角色',
                        emptySubtitle: '点击右下角按钮创建第一个角色吧',
                      ),
                      _buildGrid(
                        _remoteCharacters,
                        emptyTitle: '还没有远程角色',
                        emptySubtitle: '点击右上角同步共享角色吧',
                      ),
                    ],
                  ),
          ),
          if (_selectionMode) _buildBottomBar(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    if (_selectionMode) return _buildSelectionHeader();

    return GlassHeader(
      subtitle: '$_totalCount 个角色可选',
      title: '发现',
      badge: '$_totalCount',
      actions: [
        GlassHeader.iconBtn(Icons.image_outlined, onTap: _importCharacter),
        const SizedBox(width: 10),
        GlassHeader.iconBtn(
          _syncing ? Icons.sync_rounded : Icons.cloud_download_rounded,
          onTap: _syncing ? null : _syncWebDavCharacter,
        ),
        const SizedBox(width: 10),
        GlassHeader.iconBtn(Icons.search_rounded, onTap: () {}),
      ],
    );
  }

  Widget _buildSelectionHeader() {
    final activeCount = _activeItems.length;
    return GlassHeader(
      subtitle: '已选',
      title: '${_selectedIds.length}',
      badge: '/$activeCount',
      actions: [
        GlassHeader.iconBtn(
          _selectedIds.length == activeCount
              ? Icons.deselect
              : Icons.select_all,
          onTap: _selectAll,
        ),
        const SizedBox(width: 10),
        GlassHeader.iconBtn(Icons.close_rounded, onTap: _toggleSelectionMode),
      ],
    );
  }

  Widget _buildLoading() {
    return const Center(
      child: CircularProgressIndicator(color: AppColors.accent),
    );
  }

  Widget _buildSourceTabs() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 10, 16, 0),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        border: Border.all(color: const Color(0xFFF0E6F6), width: 0.5),
      ),
      child: TabBar(
        controller: _tabCtrl,
        indicator: BoxDecoration(
          color: AppColors.accent,
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        labelColor: Colors.white,
        unselectedLabelColor: AppColors.textSecondary,
        labelStyle: const TextStyle(
          fontFamily: 'MapleMono',
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: const TextStyle(
          fontFamily: 'MapleMono',
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
        tabs: [
          Tab(text: '本地角色（${_localCharacters.length}）'),
          Tab(text: '远程角色（${_remoteCharacters.length}）'),
        ],
      ),
    );
  }

  Widget _buildGrid(
    List<DiscoverCharacterItem> items, {
    required String emptyTitle,
    required String emptySubtitle,
  }) {
    if (items.isEmpty) {
      return _buildEmpty(emptyTitle, emptySubtitle);
    }

    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 80),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 0.9,
      ),
      itemCount: items.length,
      itemBuilder: (context, i) {
        final character = items[i].character;
        final isSelected = _selectedIds.contains(character.id);

        final card = Stack(
          children: [
            CharacterCard(
              character: character,
              index: i,
              onTap: () => _selectionMode
                  ? _toggleSelect(character.id)
                  : _openDetail(character, i),
            ),
            if (_selectionMode)
              Positioned(
                right: 8,
                top: 8,
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 180),
                  child: Icon(
                    isSelected
                        ? Icons.check_circle_rounded
                        : Icons.radio_button_unchecked_rounded,
                    key: ValueKey(isSelected),
                    color: isSelected ? AppColors.accent : Colors.white,
                    size: 22,
                  ),
                ),
              ),
          ],
        );

        final wrapped = GestureDetector(
          onLongPress: _selectionMode
              ? null
              : () {
                  setState(() {
                    _selectionMode = true;
                    _selectedIds.add(character.id);
                  });
                },
          child: card,
        );

        if (_selectionMode) {
          return wrapped;
        }

        return Dismissible(
          key: ValueKey(character.id),
          direction: DismissDirection.endToStart,
          confirmDismiss: (_) async {
            return await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    title: const Text('删除角色'),
                    content: Text('确定要删除「${character.name}」吗？'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx, false),
                        child: const Text('取消'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(ctx, true),
                        child: const Text(
                          '删除',
                          style: TextStyle(color: AppColors.error),
                        ),
                      ),
                    ],
                  ),
                ) ??
                false;
          },
          onDismissed: (_) {
            _deleteCharacters([character.id]);
          },
          background: Container(
            margin: const EdgeInsets.symmetric(vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.error.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
            ),
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20),
            child: const Icon(
              Icons.delete_outline,
              color: AppColors.error,
              size: 22,
            ),
          ),
          child: wrapped,
        );
      },
    );
  }

  Widget _buildEmpty(String title, String subtitle) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('✨', style: TextStyle(fontSize: 48)),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(
              fontFamily: 'MapleMono',
              fontSize: 15,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: const TextStyle(
              fontFamily: 'MapleMono',
              fontSize: 12,
              color: AppColors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openDetail(Character character, int index) async {
    await Navigator.push<void>(
      context,
      MaterialPageRoute(
        builder: (_) => CharacterDetailScreen(
          character: character,
          index: index,
          onDelete: () async {
            await _deleteCharacters([character.id]);
          },
          onCharacterUpdated: (updated) async {
            await _storage.save(updated);
          },
        ),
      ),
    );

    if (!mounted) return;
    _loadCharacters();
  }

  Widget _buildBottomBar() {
    final hasSelection = _selectedIds.isNotEmpty;

    return Container(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 10,
        bottom: MediaQuery.of(context).padding.bottom + 10,
      ),
      decoration: BoxDecoration(
        color: AppColors.surfaceGlass,
        border: Border(
          top: BorderSide(
            color: AppColors.border.withValues(alpha: 0.7),
            width: 0.6,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.cardShadow,
            blurRadius: 16,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _bottomBarBtn(
              icon: Icons.delete_sweep,
              label: '清空当前页',
              color: AppColors.error,
              onTap: _deleteActiveAll,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _bottomBarBtn(
              icon: Icons.delete_outline,
              label: hasSelection ? '删除选中 (${_selectedIds.length})' : '删除选中',
              color: hasSelection ? AppColors.accent : AppColors.textTertiary,
              onTap: hasSelection ? _deleteSelected : null,
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
    return GestureDetector(
      onTap: onTap,
      child: Opacity(
        opacity: onTap == null ? 0.5 : 1,
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
              Text(
                label,
                style: TextStyle(
                  fontFamily: 'MapleMono',
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _addCharacter() async {
    final newChar = await Navigator.push<Character>(
      context,
      MaterialPageRoute(
        builder: (_) =>
            CharacterEditScreen(index: _totalCount, isCreating: true),
      ),
    );

    if (newChar != null) {
      await _storage.save(newChar);
      if (mounted) _loadCharacters();
    }
  }

  void _showSnack(String message, {Color? backgroundColor}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: backgroundColor),
    );
  }
}
