import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:my_petition_app/core/constants/app_colors.dart';
import 'package:my_petition_app/core/constants/app_strings.dart';
import '../discover/discover_screen.dart';
import '../home/home_screen.dart';
import '../home/petition_detail_screen.dart';
import '../profile/profile_screen.dart';
import 'package:my_petition_app/core/utils/custom_text.dart';
import 'package:get/get.dart';
import 'package:my_petition_app/controllers/home_controller.dart';

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
    if (notification.depth != 0 || _currentIndex == 2) return false;
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
    
    // Call Feed API if Home tab (index 2) is clicked
    if (index == 2) {
      if (Get.isRegistered<HomeController>()) {
        Get.find<HomeController>().fetchFeed();
      }
    }

    if (_isNavHidden) {
      _isNavHidden = false;
      _navController.reverse();
    }
  }


  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    const double navHeight = 58.0; // Slimmer height
    final double navTotalHeight = navHeight + bottomPadding;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: NotificationListener<ScrollNotification>(
        onNotification: _handleScrollNotification,
        child: Stack(
          children: [
            AnimatedBuilder(
              animation: _navOffset,
              builder: (context, child) {
                return Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  bottom: navTotalHeight * (1 - _navOffset.value),
                  child: child!,
                );
              },
              child: IndexedStack(
                index: _currentIndex,
                children: _screens,
              ),
            ),

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
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                      child: Container(
                        height: navHeight + bottomPadding,
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardColor.withOpacity(Theme.of(context).brightness == Brightness.light ? 0.85 : 0.7),
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(20),
                            topRight: Radius.circular(20),
                          ),
                          border: Border(
                            top: BorderSide(
                              color: Colors.white.withOpacity(0.1),
                              width: 0.5,
                            ),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(Theme.of(context).brightness == Brightness.light ? 0.08 : 0.4),
                              blurRadius: 10,
                              spreadRadius: 0,
                              offset: const Offset(0, -1),
                            ),
                          ],
                        ),
                        padding: EdgeInsets.only(bottom: bottomPadding),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildNavItem(Icons.explore_outlined, Icons.explore,
                                AppStrings.discover, 0),
                            _buildHomeNavItem(),
                            _buildNavItem(Icons.person_outline, Icons.person,
                                AppStrings.profile, 4),
                          ],
                        ),
                      ),
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
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isActive ? AppColors.accent.withOpacity(0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(25),
        ),
        child: Icon(
          isActive ? activeIcon : icon,
          color: isActive ? AppColors.accent : AppColors.grey500,
          size: 24,
        ),
      ),
    );
  }

  Widget _buildHomeNavItem() {
    final isActive = _currentIndex == 2;
    return GestureDetector(
      onTap: () => _switchTab(2),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isActive ? AppColors.accent.withOpacity(0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(25),
        ),
        child: Icon(
          isActive ? Icons.home : Icons.home_outlined,
          color: isActive ? AppColors.accent : AppColors.grey500,
          size: 26,
        ),
      ),
    );
  }
}
