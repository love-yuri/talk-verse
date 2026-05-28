import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../constants/app_colors.dart';
import 'chat_list_screen.dart';
import 'character_list_screen.dart';
import 'profile_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with TickerProviderStateMixin {
  int _idx = 0;
  late final PageController _pageCtrl;
  late final AnimationController _slideCtrl;
  late final AnimationController _glowCtrl;
  double _fromPos = 0;

  static const _items = [
    _Nav(Icons.chat_bubble_outline_rounded, Icons.chat_bubble_rounded, '聊天'),
    _Nav(Icons.explore_outlined, Icons.explore_rounded, '发现'),
    _Nav(Icons.person_outline_rounded, Icons.person_rounded, '我的'),
  ];

  @override
  void initState() {
    super.initState();
    _pageCtrl = PageController(initialPage: _idx);
    _slideCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 420));
    _glowCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 2000))..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pageCtrl.dispose();
    _slideCtrl.dispose();
    _glowCtrl.dispose();
    super.dispose();
  }

  void _switchTab(int i) {
    if (i == _idx) return;
    HapticFeedback.lightImpact();
    _fromPos = _idx.toDouble();
    setState(() => _idx = i);
    _slideCtrl.forward(from: 0);
    _pageCtrl.animateToPage(i, duration: const Duration(milliseconds: 350), curve: Curves.easeOutCubic);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: PageView(
        controller: _pageCtrl,
        physics: const NeverScrollableScrollPhysics(),
        children: const [ChatListScreen(), CharacterListScreen(), ProfileScreen()],
      ),
      bottomNavigationBar: _buildNavBar(),
    );
  }

  Widget _buildNavBar() {
    const pillW = 46.0;
    const pillH = 30.0;
    const iconTop = 13.0;
    const labelTop = 43.0;
    const navH = 64.0;

    return Padding(
      padding: EdgeInsets.only(left: 20, right: 20, bottom: MediaQuery.of(context).padding.bottom + 8),
      child: Container(
        height: navH,
        decoration: BoxDecoration(
          color: AppColors.navBackground,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.border.withValues(alpha: 0.7), width: 0.6),
          boxShadow: [
            BoxShadow(color: AppColors.cardShadow, blurRadius: 24, offset: const Offset(0, 8)),
            BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 8, offset: const Offset(0, 2)),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final itemW = constraints.maxWidth / _items.length;

              return AnimatedBuilder(
                animation: Listenable.merge([_slideCtrl, _glowCtrl]),
                builder: (context, _) {
                  final t = Curves.easeOutCubic.transform(_slideCtrl.value);
                  final cur = _fromPos + (_idx - _fromPos) * t;
                  // 用同一个中心点计算所有元素位置
                  final centerX = cur * itemW + itemW / 2;
                  final glowOpacity = 0.06 + _glowCtrl.value * 0.04;

                  return Stack(
                    children: [
                      // 发光效果
                      Positioned(
                        left: centerX - 28, top: 1,
                        child: Container(
                          width: 56, height: 32,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [BoxShadow(color: AppColors.accent.withValues(alpha: glowOpacity), blurRadius: 18, spreadRadius: 4)],
                          ),
                        ),
                      ),
                      // 渐变指示器
                      Positioned(
                        left: centerX - pillW / 2, top: iconTop - 3,
                        child: Container(
                          width: pillW, height: pillH,
                          decoration: BoxDecoration(
                            gradient: AppColors.primaryGradient,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [BoxShadow(color: AppColors.accent.withValues(alpha: 0.35), blurRadius: 10, offset: const Offset(0, 3))],
                          ),
                        ),
                      ),
                      ...List.generate(_items.length, (i) {
                        final active = _idx == i;
                        return Positioned(
                          left: i * itemW,
                          top: 0,
                          child: _NavIcon(
                            item: _items[i],
                            isActive: active,
                            onTap: () => _switchTab(i),
                            itemWidth: itemW,
                            iconTop: iconTop,
                            labelTop: labelTop,
                          ),
                        );
                      }),
                      Positioned(
                        left: centerX - itemW / 2,
                        top: 0,
                        child: IgnorePointer(
                          child: SizedBox(
                            width: itemW,
                            height: navH,
                            child: Padding(
                              padding: EdgeInsets.only(top: iconTop),
                              child: Align(
                                alignment: Alignment.topCenter,
                                child: Icon(_items[_idx].active, size: 21, color: Colors.white),
                              ),
                            ),
                          ),
                        ),
                      ),
                      // 选中标签
                      AnimatedPositioned(
                        duration: const Duration(milliseconds: 320),
                        curve: Curves.easeOutCubic,
                        left: _idx * itemW,
                        top: labelTop,
                        child: SizedBox(
                          width: itemW,
                          child: Center(
                            child: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 260),
                              transitionBuilder: (child, anim) => FadeTransition(
                                opacity: anim,
                                child: SlideTransition(
                                  position: Tween<Offset>(begin: const Offset(0, 0.4), end: Offset.zero).animate(anim),
                                  child: child,
                                ),
                              ),
                              child: Text(
                                _items[_idx].label,
                                key: ValueKey(_idx),
                                style: TextStyle(
                                  fontFamily: 'MapleMono', fontSize: 10, fontWeight: FontWeight.w600,
                                  color: AppColors.navActive, letterSpacing: 0.07,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}

class _NavIcon extends StatefulWidget {
  final _Nav item;
  final bool isActive;
  final VoidCallback onTap;
  final double itemWidth;
  final double iconTop;
  final double labelTop;

  const _NavIcon({
    required this.item,
    required this.isActive,
    required this.onTap,
    required this.itemWidth,
    required this.iconTop,
    required this.labelTop,
  });

  @override
  State<_NavIcon> createState() => _NavIconState();
}

class _NavIconState extends State<_NavIcon> with SingleTickerProviderStateMixin {
  late final AnimationController _bounceCtrl;
  late final Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _bounceCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 380));
    _scaleAnim = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.78), weight: 20),
      TweenSequenceItem(tween: Tween(begin: 0.78, end: 1.18), weight: 40),
      TweenSequenceItem(tween: Tween(begin: 1.18, end: 1.0), weight: 40),
    ]).animate(CurvedAnimation(parent: _bounceCtrl, curve: Curves.easeInOut));
    if (widget.isActive) _bounceCtrl.forward();
  }

  @override
  void didUpdateWidget(_NavIcon old) {
    super.didUpdateWidget(old);
    if (widget.isActive && !old.isActive) _bounceCtrl.forward(from: 0);
  }

  @override
  void dispose() {
    _bounceCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: widget.itemWidth,
        height: 64,
        child: Stack(
          children: [
            // 图标
            Padding(
              padding: EdgeInsets.only(top: widget.iconTop),
              child: Align(
                alignment: Alignment.topCenter,
                child: AnimatedBuilder(
                  animation: _scaleAnim,
                  builder: (context, child) => Transform.scale(scale: _scaleAnim.value, child: child),
                  child: Icon(
                    widget.item.inactive,
                    size: 21,
                    color: widget.isActive ? Colors.transparent : AppColors.navInactive,
                  ),
                ),
              ),
            ),
            // 未选中标签
            if (!widget.isActive)
              Positioned(
                top: widget.labelTop,
                left: 0,
                right: 0,
                child: Center(
                  child: Text(
                    widget.item.label,
                    style: TextStyle(
                      fontFamily: 'MapleMono', fontSize: 10, fontWeight: FontWeight.w600,
                      color: AppColors.textTertiary, letterSpacing: 0.07,
                    ),
                  ),
                ),
              ),
          ],
        ),
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
