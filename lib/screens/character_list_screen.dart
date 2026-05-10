import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_dimensions.dart';
import '../models/character.dart';
import '../services/character_storage_service.dart';
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
  List<Character> _characters = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadCharacters();
  }

  Future<void> _loadCharacters() async {
    final list = await _storage.load();
    if (!mounted) return;
    setState(() {
      _characters = list;
      _loading = false;
    });
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
          Expanded(child: _loading ? _buildLoading() : _buildGrid()),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return GlassHeader(
      subtitle: '${_characters.length} 个角色可选',
      title: '发现',
      badge: '${_characters.length}',
      actions: [
        GlassHeader.iconBtn(Icons.search_rounded, onTap: () {}),
      ],
    );
  }

  Widget _buildLoading() {
    return const Center(
      child: CircularProgressIndicator(color: AppColors.accent),
    );
  }

  Widget _buildGrid() {
    if (_characters.isEmpty) {
      return _buildEmpty();
    }
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 80),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 0.86,
      ),
      itemCount: _characters.length,
      itemBuilder: (context, i) {
        final character = _characters[i];
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
                  TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('删除', style: TextStyle(color: AppColors.error))),
                ],
              ),
            ) ?? false;
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
          child: CharacterCard(
            character: character,
            index: i,
            onTap: () => _openDetail(character, i),
          ),
        );
      },
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('✨', style: TextStyle(fontSize: 48)),
          const SizedBox(height: 16),
          const Text('还没有角色', style: TextStyle(fontFamily: 'MapleMono', fontSize: 15, color: AppColors.textSecondary)),
          const SizedBox(height: 8),
          const Text('点击右下角按钮创建第一个角色吧', style: TextStyle(fontFamily: 'MapleMono', fontSize: 12, color: AppColors.textTertiary)),
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

  void _addCharacter() async {
    final newChar = await Navigator.push<Character>(
      context,
      MaterialPageRoute(
        builder: (_) => CharacterEditScreen(
          index: _characters.length,
          isCreating: true,
        ),
      ),
    );
    if (newChar != null) {
      await _storage.save(newChar);
      if (mounted) _loadCharacters();
    }
  }
}
