import 'package:flutter/material.dart';
import 'package:my_petition_app/core/constants/app_colors.dart';
import 'package:my_petition_app/core/constants/app_strings.dart';
import '../discover/discover_screen.dart';
import '../home/home_screen.dart';
import '../home/petition_detail_screen.dart';
import '../profile/profile_screen.dart';
import 'package:my_petition_app/core/utils/custom_text.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell>
    with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  bool _isNavHidden = false;

  late final AnimationController _navController;
  late final Animation<double> _navOffset; // 0=visible, 1=hidden

  final List<Widget> _screens = [
    const DiscoverScreen(),
    const HomeScreen(),
    const HomeScreen(),
    const PetitionDetailScreen(),
    const ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _navController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _navOffset = CurvedAnimation(
      parent: _navController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _navController.dispose();
    super.dispose();
  }

  bool _handleScrollNotification(ScrollNotification notification) {
    if (notification.depth != 0) return false;
    if (notification is ScrollUpdateNotification) {
      final delta = notification.scrollDelta ?? 0;
      // Scroll DOWN → hide
      if (delta > 4 && !_isNavHidden) {
        _isNavHidden = true;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) _navController.forward();
        });
      }
      // Scroll UP → show
      else if (delta < -4 && _isNavHidden) {
        _isNavHidden = false;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) _navController.reverse();
        });
      }
    }
    return false;
  }

  void _switchTab(int index) {
    setState(() => _currentIndex = index);
    if (_isNavHidden) {
      _isNavHidden = false;
      _navController.reverse();
    }
  }


  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    // Total nav bar visual height (item row + safe area bottom)
    const double navRowHeight = 88.0;
    final double navTotalHeight = navRowHeight + bottomPadding;

    return Scaffold(
      backgroundColor: AppColors.white,
      // No bottomNavigationBar — avoids the blank-space-reservation issue
      body: NotificationListener<ScrollNotification>(
        onNotification: _handleScrollNotification,
        child: Stack(
          children: [
            // Main content — full screen, content goes behind nav overlay
            IndexedStack(
              index: _currentIndex,
              children: _screens,
            ),

            // Bottom nav bar as overlay — slides out without leaving white space
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: AnimatedBuilder(
                animation: _navOffset,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(0, navTotalHeight * _navOffset.value),
                    child: child,
                  );
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.black.withValues(alpha: 0.08),
                        blurRadius: 12,
                        offset: const Offset(0, -3),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        height: navRowHeight,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildNavItem(Icons.explore_outlined, Icons.explore,
                                AppStrings.discover, 0),
                            _buildNavItem(Icons.article_outlined, Icons.article,
                                AppStrings.news, 1),
                            _buildHomeNavItem(),
                            _buildNavItem(Icons.description_outlined,
                                Icons.description, AppStrings.petition, 3),
                            _buildNavItem(Icons.person_outline, Icons.person,
                                AppStrings.profile, 4),
                          ],
                        ),
                      ),
                      // Safe area bottom space (also slides out with nav)
                      SizedBox(height: bottomPadding),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(
      IconData icon, IconData activeIcon, String label, int index) {
    final isActive = _currentIndex == index;
    return GestureDetector(
      onTap: () => _switchTab(index),
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 60,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isActive ? activeIcon : icon,
              color: isActive ? AppColors.accent : AppColors.grey500,
              size: 22,
            ),
            const SizedBox(height: 3),
            AppText(
              title: label,
              fontSize: 10,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
              color: isActive ? AppColors.accent : AppColors.grey500,
            ),
            const SizedBox(height: 4),
            // Orange indicator line below text
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              height: 3,
              width: isActive ? 70 : 0,
              decoration: BoxDecoration(
                color: AppColors.accent,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHomeNavItem() {
    final isActive = _currentIndex == 2;
    return GestureDetector(
      onTap: () => _switchTab(2),
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 60,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isActive ? Icons.home : Icons.home_outlined,
              color: isActive ? AppColors.accent : AppColors.grey500,
              size: 28,
            ),
            const SizedBox(height: 3),
            AppText(
              title: AppStrings.home,
              fontSize: 10,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
              color: isActive ? AppColors.accent : AppColors.grey500,
            ),
            const SizedBox(height: 4),
            // Orange indicator line below text
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              height: 3,
              width: isActive ? 70 : 0,
              decoration: BoxDecoration(
                color: AppColors.accent,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
