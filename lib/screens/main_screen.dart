import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_dimensions.dart';
import 'chat_list_screen.dart';
import 'character_list_screen.dart';
import 'profile_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  static const _navItems = [
    _NavItem(Icons.chat_bubble_outline, Icons.chat_bubble, '聊天'),
    _NavItem(Icons.people_outline, Icons.people, '角色'),
    _NavItem(Icons.person_outline, Icons.person, '我的'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: const [
          ChatListScreen(),
          CharacterListScreen(),
          ProfileScreen(),
        ],
      ),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  Widget _buildBottomNavBar() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(
          top: BorderSide(color: AppColors.border, width: 0.5),
        ),
      ),
      child: SafeArea(
        child: SizedBox(
          height: AppDimensions.bottomNavHeight,
          child: Row(
            children: List.generate(
              _navItems.length,
              (i) => Expanded(child: _buildNavItem(i, _navItems[i])),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, _NavItem item) {
    final isActive = _currentIndex == index;
    return GestureDetector(
      onTap: () => _onItemTapped(index),
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
            decoration: BoxDecoration(
              color: isActive ? AppColors.primarySurface : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              isActive ? item.activeIcon : item.inactiveIcon,
              size: 22,
              color: isActive ? AppColors.primary : AppColors.textTertiary,
            ),
          ),
          const SizedBox(height: 4),
          AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 200),
            style: TextStyle(
              fontSize: 11,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
              color: isActive ? AppColors.primary : AppColors.textTertiary,
            ),
            child: Text(item.label),
          ),
        ],
      ),
    );
  }

  void _onItemTapped(int index) {
    if (index == _currentIndex) return;
    setState(() => _currentIndex = index);
  }
}

class _NavItem {
  final IconData inactiveIcon;
  final IconData activeIcon;
  final String label;

  const _NavItem(this.inactiveIcon, this.activeIcon, this.label);
}
