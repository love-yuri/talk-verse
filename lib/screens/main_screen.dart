import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import 'chat_list_screen.dart';
import 'character_list_screen.dart';
import 'profile_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _idx = 0;

  static const _items = [
    _Nav(Icons.chat_bubble_outline_rounded, Icons.chat_bubble_rounded, '聊天'),
    _Nav(Icons.explore_outlined, Icons.explore_rounded, '发现'),
    _Nav(Icons.person_outline_rounded, Icons.person_rounded, '我的'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _idx, children: const [
        ChatListScreen(),
        CharacterListScreen(),
        ProfileScreen(),
      ]),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: AppColors.navBackground,
          border: Border(top: BorderSide(color: AppColors.border, width: 0.5)),
        ),
        child: SafeArea(
          child: SizedBox(
            height: 52,
            child: Row(children: List.generate(_items.length, (i) => Expanded(child: _navItem(i, _items[i])))),
          ),
        ),
      ),
    );
  }

  Widget _navItem(int i, _Nav item) {
    final active = _idx == i;
    return GestureDetector(
      onTap: () { if (i != _idx) setState(() => _idx = i); },
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
            decoration: BoxDecoration(
              color: active ? AppColors.accentLight : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(active ? item.active : item.inactive, size: 22, color: active ? AppColors.navActive : AppColors.navInactive),
          ),
          const SizedBox(height: 2),
          AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 200),
            style: TextStyle(fontSize: 10, fontWeight: active ? FontWeight.w600 : FontWeight.w400, color: active ? AppColors.navActive : AppColors.navInactive),
            child: Text(item.label),
          ),
        ],
      ),
    );
  }
}

class _Nav {
  final IconData inactive;
  final IconData active;
  final String label;
  const _Nav(this.inactive, this.active, this.label);
}
