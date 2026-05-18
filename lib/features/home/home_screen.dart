import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_petition_app/controllers/discover_controller.dart';
import 'dart:math' as math;
import 'package:my_petition_app/core/constants/app_colors.dart';
import 'package:my_petition_app/controllers/home_controller.dart';
import 'package:my_petition_app/core/utils/app_shimmer.dart';
import 'package:my_petition_app/features/home/widgets/feed_item_widgets.dart';
import 'package:shimmer/shimmer.dart';
import 'package:my_petition_app/core/routes/app_routes.dart';
import 'package:my_petition_app/core/utils/custom_text.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final controller = Get.find<HomeController>();
  late PageController _pageController;
  int _currentPageIndex = 0;
  double _currentPageValue = 0.0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController()
      ..addListener(() {
        if (mounted) {
          setState(() {
            _currentPageValue = _pageController.page ?? 0.0;
          });
        }
      });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Obx(() {
        if (controller.isLoading.value && controller.feedList.isEmpty) {
          return _buildFeedShimmer(context);
        }



        if (controller.feedList.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.feed_outlined, size: 64, color: AppColors.grey400),
                const SizedBox(height: 16),
                AppText(
                  title: 'No feed items found',
                  color: AppColors.grey600,
                  fontSize: 16,
                ),
              ],
            ),
          );
        }







        // Calculate indices and animation progress
        final int currentIndex = _currentPageValue.floor();
        final int nextIndex = currentIndex + 1;
        final double percent = _currentPageValue - currentIndex;

        return Stack(
          children: [
            // 1. Next Card (Rendered first so it's BEHIND)
            if (nextIndex < controller.feedList.length)
              _buildStackItem(nextIndex, percent, isNext: true),

            // 2. Current Card (Rendered second so it's ON TOP)
            if (currentIndex < controller.feedList.length)
              _buildStackItem(currentIndex, percent, isNext: false),

            // 3. PageView (Handles gestures and serves as the interaction layer)
            PageView.builder(
              scrollDirection: Axis.vertical,
              controller: _pageController,
              physics: const PageScrollPhysics(parent: ClampingScrollPhysics()),
              itemCount: controller.feedList.length + (controller.hasMore.value ? 1 : 0),
              onPageChanged: (index) {
                setState(() {
                  _currentPageIndex = index;
                });
                if (index == controller.feedList.length - 1 && controller.hasMore.value) {
                  controller.loadMore();
                }
              },
              itemBuilder: (context, index) {
                if (index >= controller.feedList.length) return const SizedBox.expand();
                
                final item = controller.feedList[index];
                final screenHeight = MediaQuery.of(context).size.height;

                return Stack(
                  children: [
                    // Detail navigation detector
                    GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      onTap: () => _handleItemTap(item),
                      child: const SizedBox.expand(),
                    ),
                    
                    // Specific Bookmark Button hit area
                    if (item.feedType == 'news')
                      Positioned(
                        top: screenHeight * 0.42 - 30,
                        right: 20,
                        child: GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () => Get.find<DiscoverController>().toggleSaveNews(item.data),
                          child: Container(
                            width: 60,
                            height: 60,
                            color: Colors.transparent,
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),

            // Jump to Top Button
            _buildJumpToTopButton(context),
          ],
        );
      }),
    );
  }



  void _handleItemTap(dynamic item) {
    if (item.feedType == 'news') {
      final news = item.data;
      final discoverController = Get.find<DiscoverController>();
      if (!discoverController.newsList.any((e) => e.slug == news.slug)) {
        discoverController.newsList.insert(0, news);
      }
      final index = discoverController.newsList.indexWhere((e) => e.slug == news.slug);
      Get.toNamed(AppRoutes.newsDetail, arguments: {'index': index, 'slug': news.slug});
    } else if (item.feedType == 'insight') {
      final insight = item.data;
      final discoverController = Get.find<DiscoverController>();
      if (!discoverController.insightsList.any((e) => e.slug == insight.slug)) {
        discoverController.insightsList.insert(0, insight);
      }
      final index = discoverController.insightsList.indexWhere((e) => e.slug == insight.slug);
      Get.toNamed(AppRoutes.insightReels, arguments: {'index': index, 'slug': insight.slug});
    } else if (item.feedType == 'petition') {
      final petition = item.data;
      Get.toNamed(AppRoutes.petitionDetail, arguments: petition.slug);
    }
  }

  Widget _buildStackItem(int index, double percent, {required bool isNext}) {
    final item = controller.feedList[index];
    
    Widget child;
    if (item.feedType == 'news') {
      child = NewsFeedItem(news: item.data);
    } else if (item.feedType == 'insight') {
      child = InsightFeedItem(insight: item.data);
    } else if (item.feedType == 'petition') {
      child = PetitionFeedItem(petition: item.data);
    } else {
      child = const SizedBox.shrink();
    }

    if (!isNext) {
      // Current Card: Slides UP and OUT
      return Transform.translate(
        offset: Offset(0, -percent * MediaQuery.of(context).size.height),
        child: child,
      );
    } else {
      // Next Card: Stationary BEHIND and Scales UP
      double scale = (0.9 + (percent) * 0.1).clamp(0.9, 1.0);
      double opacity = (percent).clamp(0.0, 1.0);

      return Transform.scale(
        scale: scale,
        child: Opacity(
          opacity: opacity,
          child: child,
        ),
      );
    }
  }






  Widget _buildJumpToTopButton(BuildContext context) {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 10,
      right: 16,
      child: AnimatedOpacity(
        opacity: _currentPageIndex > 0 ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 300),
        child: IgnorePointer(
          ignoring: _currentPageIndex == 0,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.35),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(
                Icons.keyboard_double_arrow_up_rounded,
                color: Colors.white,
                size: 24,
              ),
              tooltip: 'Jump to Top',
              onPressed: () {
                _pageController.animateToPage(
                  0,
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.fastOutSlowIn,
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeedShimmer(BuildContext context) {
    return AppShimmer.fromColors(
      context: context,
      child: Column(
        children: [
          Expanded(
            flex: 42,
            child: Container(color: Colors.white),
          ),
          Expanded(
            flex: 58,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(height: 20, width: 100, color: Colors.white),
                  const SizedBox(height: 16),
                  Container(height: 30, width: double.infinity, color: Colors.white),
                  const SizedBox(height: 12),
                  Container(height: 20, width: double.infinity, color: Colors.white),
                  const SizedBox(height: 8),
                  Container(height: 20, width: double.infinity, color: Colors.white),
                  const Spacer(),
                  Container(height: 50, width: double.infinity, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8))),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMoreLoadingIndicator() {
    return Container(
      color: Colors.white,
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(strokeWidth: 2, color: AppColors.accent),
            SizedBox(height: 16),
            AppText(title: 'Loading more feed...', fontSize: 13, color: AppColors.grey600),
          ],
        ),
      ),
    );
  }
}
