import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_dimensions.dart';
import '../models/character.dart';
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

class _CharacterListScreenState extends State<CharacterListScreen> {
  final _storage = CharacterStorageService();
  final _roleCardSync = RoleCardSyncService();
  List<DiscoverCharacterItem> _localCharacters = [];
  List<DiscoverCharacterItem> _remoteCharacters = [];
  bool _loading = true;
  bool _syncing = false;

  int get _totalCount => _localCharacters.length + _remoteCharacters.length;

  @override
  void initState() {
    super.initState();
    _loadCharacters();
  }

  Future<void> _loadCharacters() async {
    final list = await _storage.loadForDiscover();
    if (!mounted) return;
    setState(() {
      _localCharacters = list.where((item) => !item.isRemote).toList();
      _remoteCharacters = list.where((item) => item.isRemote).toList();
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
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
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return GlassHeader(
      subtitle: '$_totalCount 个角色可选',
      title: '发现',
      badge: '$_totalCount',
      actions: [
        GlassHeader.iconBtn(
          _syncing ? Icons.sync_rounded : Icons.cloud_download_rounded,
          onTap: _syncing ? null : _syncWebDavCharacter,
        ),
        const SizedBox(width: 10),
        GlassHeader.iconBtn(Icons.search_rounded, onTap: () {}),
      ],
    );
  }

  Widget _buildLoading() {
    return const Center(child: CircularProgressIndicator(color: AppColors.accent));
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
        indicator: BoxDecoration(
          color: AppColors.accent,
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        labelColor: Colors.white,
        unselectedLabelColor: AppColors.textSecondary,
        labelStyle: const TextStyle(fontFamily: 'MapleMono', fontSize: 13, fontWeight: FontWeight.w600),
        unselectedLabelStyle: const TextStyle(fontFamily: 'MapleMono', fontSize: 13, fontWeight: FontWeight.w500),
        tabs: [
          Tab(text: '本地角色（${_localCharacters.length}）'),
          Tab(text: '远程角色（${_remoteCharacters.length}）'),
        ],
      ),
    );
  }

  Widget _buildGrid(List<DiscoverCharacterItem> items, {required String emptyTitle, required String emptySubtitle}) {
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
        return Dismissible(
          key: ValueKey(character.id),
          direction: DismissDirection.endToStart,
          confirmDismiss: (_) async {
            return await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    title: const Text('删除角色'),
                    content: Text('确定要删除「${character.name}」吗？'),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('取消')),
                      TextButton(
                        onPressed: () => Navigator.pop(ctx, true),
                        child: const Text('删除', style: TextStyle(color: AppColors.error)),
                      ),
                    ],
                  ),
                ) ??
                false;
          },
          onDismissed: (_) {
            _storage.delete(character.id);
            _loadCharacters();
          },
          background: Container(
            margin: const EdgeInsets.symmetric(vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.error.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
            ),
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20),
            child: const Icon(Icons.delete_outline, color: AppColors.error, size: 22),
          ),
          child: CharacterCard(character: character, index: i, onTap: () => _openDetail(character, i)),
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
            style: const TextStyle(fontFamily: 'MapleMono', fontSize: 15, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: const TextStyle(fontFamily: 'MapleMono', fontSize: 12, color: AppColors.textTertiary),
          ),
        ],
      ),
    );
  }

  void _openDetail(Character character, int index) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CharacterDetailScreen(
          character: character,
          index: index,
          onDelete: () => _storage.delete(character.id),
          onCharacterUpdated: (updated) => _storage.save(updated),
        ),
      ),
    );
    _loadCharacters();
  }

  Future<void> _syncWebDavCharacter() async {
    if (_syncing) return;

    setState(() => _syncing = true);
    try {
      final result = await _roleCardSync.syncRemoteToLocal();
      await _loadCharacters();
      if (!mounted) return;

      _showSnack(
        result.total == 0 ? '共享区暂无新角色' : '已同步 ${result.inserted} 个新角色，更新 ${result.updated} 个角色',
        backgroundColor: AppColors.success,
      );
    } catch (e) {
      print('同步角色卡失败: $e');
      if (mounted) _showSnack(e.toString(), backgroundColor: AppColors.error);
    } finally {
      if (mounted) setState(() => _syncing = false);
    }
  }

  void _showSnack(String message, {Color? backgroundColor}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message), backgroundColor: backgroundColor));
  }

  void _addCharacter() async {
    final newChar = await Navigator.push<Character>(
      context,
      MaterialPageRoute(builder: (_) => CharacterEditScreen(index: _totalCount, isCreating: true)),
    );
    if (newChar != null) {
      await _storage.save(newChar);
      if (mounted) _loadCharacters();
    }
  }
}
