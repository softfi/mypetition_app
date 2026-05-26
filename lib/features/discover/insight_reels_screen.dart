import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:my_petition_app/controllers/discover_controller.dart';
import 'package:my_petition_app/core/utils/custom_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:my_petition_app/core/config/app_urls.dart';
import 'package:my_petition_app/core/utils/share_helper.dart';
import 'package:my_petition_app/core/models/insight_model.dart';
import 'package:my_petition_app/core/service/api/api_services.dart';
import 'package:my_petition_app/controllers/saved_insights_controller.dart';

class InsightReelsScreen extends StatefulWidget {
  const InsightReelsScreen({super.key});

  @override
  State<InsightReelsScreen> createState() => _InsightReelsScreenState();
}

class _InsightReelsScreenState extends State<InsightReelsScreen> {
  late DiscoverController discoverController;
  late SavedInsightsController savedInsightsController;
  late PageController _pageController;
  late int initialIndex;
  late String source;
  double _currentPageValue = 0.0;
  final Map<String, GlobalKey> _reelKeys = {};

  List<InsightModel> get insightsList => source == 'saved' ? savedInsightsController.savedInsightsList : discoverController.insightsList;

  GlobalKey _getReelKey(String slug) {
    _reelKeys.putIfAbsent(slug, () => GlobalKey(debugLabel: slug));
    return _reelKeys[slug]!;
  }

  @override
  void initState() {
    super.initState();
    discoverController = Get.find<DiscoverController>();
    if (Get.isRegistered<SavedInsightsController>()) {
      savedInsightsController = Get.find<SavedInsightsController>();
    } else {
      savedInsightsController = Get.put(SavedInsightsController());
    }

    final args = Get.arguments as Map<String, dynamic>?;
    initialIndex = args?['index'] ?? 0;
    source = args?['source'] ?? 'discover';
    _currentPageValue = initialIndex.toDouble();
    _pageController = PageController(initialPage: initialIndex)
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

  Widget _buildStackItem(int index, double percent) {
    if (index >= insightsList.length) return const SizedBox.shrink();
    final insight = insightsList[index];
    final child = InsightReelItem(
      key: _getReelKey(insight.slug),
      insight: insight,
      source: source,
    );

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

  @override
  Widget build(BuildContext context) {
    // Calculate indices and animation progress
    final int currentIndex = _currentPageValue.floor();
    final int nextIndex = currentIndex + 1;
    final double percent = _currentPageValue - currentIndex;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.black, // Set explicitly to black
        statusBarIconBrightness: Brightness.light, // White icons for battery, time, etc.
      ),
      child: Scaffold(
        backgroundColor: Colors.black,
        body: SafeArea(
          bottom: true,
          child: Column(
            children: [
              // Custom App Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Get.back(),
                      behavior: HitTestBehavior.opaque,
                      child: const Row(
                        children: [
                          Icon(Icons.arrow_back_ios, color: Colors.white, size: 18),
                          SizedBox(width: 4),
                          AppText(
                            title: 'Stories',
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),



              // The Reels Area
              Expanded(
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                  child: RefreshIndicator(
                    onRefresh: () async {
                      if (source == 'saved') {
                        await savedInsightsController.fetchSavedInsights(isRefresh: true);
                      } else {
                        await discoverController.fetchInsights();
                      }
                    },
                    child: Stack(
                      children: [
                        // 1. Next Card (Rendered first so it's BEHIND)
                        if (nextIndex < insightsList.length)
                          _buildStackItem(nextIndex, percent),

                        // 2. PageView (Handles gestures, renders the current card, and handles horizontal scroll)
                        PageView.builder(
                          scrollDirection: Axis.vertical,
                          controller: _pageController,
                          physics: const PageScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                          itemCount: insightsList.length,
                          itemBuilder: (context, index) {
                            int renderIndex = _currentPageValue.floor();
                            if (renderIndex < 0) renderIndex = 0;
                            if (renderIndex >= insightsList.length) renderIndex = insightsList.length - 1;
                            
                            if (index == renderIndex) {
                              final insight = insightsList[index];
                              return InsightReelItem(
                                key: _getReelKey(insight.slug),
                                insight: insight,
                                source: source,
                              );
                            }
                            // Return transparent box for other indices so the underlying scaling card is visible
                            return const SizedBox.expand();
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class InsightReelItem extends StatefulWidget {
  final dynamic insight;
  final String source;
  const InsightReelItem({super.key, required this.insight, this.source = 'discover'});

  @override
  State<InsightReelItem> createState() => _InsightReelItemState();
}

class _InsightReelItemState extends State<InsightReelItem> {
  final controller = Get.find<DiscoverController>();
  int _currentImageIndex = 0;
  late PageController _horizontalController;
  List<dynamic> _loadedFiles = [];

  @override
  void initState() {
    super.initState();
    _horizontalController = PageController();
    _loadedFiles = widget.insight.files;
    _fetchFullDetails();
  }

  @override
  void didUpdateWidget(InsightReelItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.insight.slug != oldWidget.insight.slug) {
      _currentImageIndex = 0;
      _loadedFiles = widget.insight.files;
      _fetchFullDetails();
    }
  }

  Future<void> _fetchFullDetails() async {
    final slug = widget.insight.slug;
    try {
      final response = await ApiService().get('${AppUrls.insights}/$slug');
      if (response != null && response.data != null && response.data['success'] == true) {
        final detailData = response.data['data'];
        final List filesJson = detailData['files'] ?? [];
        final parsedFiles = filesJson.map((i) => InsightFile.fromJson(i)).toList();
        if (mounted) {
          // Prevent unnecessary rebuilds (and blinking) if the files are the same length
          if (_loadedFiles.length != parsedFiles.length) {
            setState(() {
              _loadedFiles = parsedFiles;
            });
          }
        }
      }
    } catch (e) {
      debugPrint('Error fetching full details for insight $slug: $e');
    }
  }

  void _showNextImage() {
    if (_currentImageIndex < _loadedFiles.length - 1) {
      _horizontalController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _showPreviousImage() {
    if (_currentImageIndex > 0) {
      _horizontalController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  void dispose() {
    _horizontalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final insight = widget.insight;
    final hasMultipleImages = _loadedFiles.length > 1;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onHorizontalDragEnd: (details) {
        if (details.primaryVelocity == null) return;
        if (details.primaryVelocity! < -100) {
          // Swipe Left -> Next Image
          _showNextImage();
        } else if (details.primaryVelocity! > 100) {
          // Swipe Right -> Previous Image
          _showPreviousImage();
        }
      },
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Horizontal PageView for Multiple Images
          PageView.builder(
            scrollDirection: Axis.horizontal,
            controller: _horizontalController,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _loadedFiles.length,
            onPageChanged: (index) {
              setState(() => _currentImageIndex = index);
            },
            itemBuilder: (context, imgIndex) {
              final imageUrl = '${AppUrls.s3BaseUrl}${_loadedFiles[imgIndex].s3ImageUrl}';
              return CachedNetworkImage(
                imageUrl: imageUrl,
                fit: BoxFit.fill,
                placeholder: (context, url) => Container(
                  color: Colors.black,
                  child: const Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  ),
                ),
                errorWidget: (context, url, error) => const Icon(Icons.error, color: Colors.white),
              );
            },
          ),

        // Gradient Overlay
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withOpacity(0.3),
                Colors.transparent,
                Colors.transparent,
                Colors.black.withOpacity(0.8),
              ],
              stops: const [0.0, 0.2, 0.7, 1.0],
            ),
          ),
        ),

        // Logo and Dot Indicator Row
        Positioned(
          top: 60,
          left: 16,
          right: 16,
          child: Row(
            children: [
              // Logo
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.lightbulb, color: Colors.yellow, size: 20),
                  const SizedBox(width: 4),
                  const Text(
                    'insights',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              // Dot Indicator for Multiple Images
              if (hasMultipleImages)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(
                    _loadedFiles.length,
                    (index) => Container(
                      width: 10,
                      height: 10,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _currentImageIndex == index
                            ? Colors.yellow
                            : Colors.white.withOpacity(0.4),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),

        // Bookmark Button (Bottom Center)
        Positioned(
          bottom: 30,
          left: 0,
          right: 0,
          child: Center(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                final discoverController = Get.find<DiscoverController>();
                SavedInsightsController? savedController;
                if (widget.source == 'saved' && Get.isRegistered<SavedInsightsController>()) {
                  savedController = Get.find<SavedInsightsController>();
                }
                
                final List<InsightModel> list = widget.source == 'saved' && savedController != null 
                    ? savedController.savedInsightsList 
                    : discoverController.insightsList;

                final currentInsight = list.firstWhere(
                  (e) => e.id == widget.insight.id,
                  orElse: () => widget.insight,
                );
                
                // Toggle via DiscoverController to hit API
                discoverController.toggleSaveInsight(currentInsight);
                
                // If we are in saved list, manually toggle local state for immediate feedback
                if (widget.source == 'saved' && savedController != null) {
                  final idx = savedController.savedInsightsList.indexWhere((e) => e.id == widget.insight.id);
                  if (idx != -1) {
                    savedController.savedInsightsList[idx] = 
                        savedController.savedInsightsList[idx].copyWith(isSaved: !currentInsight.isSaved);
                  }
                }
              },
              child: Container(
                padding: const EdgeInsets.all(12),
                color: Colors.transparent,
                child: Obx(() {
                  final discoverController = Get.find<DiscoverController>();
                  SavedInsightsController? savedController;
                  if (widget.source == 'saved' && Get.isRegistered<SavedInsightsController>()) {
                    savedController = Get.find<SavedInsightsController>();
                  }
                  
                  final List<InsightModel> list = widget.source == 'saved' && savedController != null 
                      ? savedController.savedInsightsList 
                      : discoverController.insightsList;

                  final currentInsight = list.firstWhere(
                    (e) => e.id == widget.insight.id,
                    orElse: () => widget.insight,
                  );
                  final isSaved = currentInsight.isSaved;
                  return Icon(
                    isSaved ? Icons.bookmark : Icons.bookmark_border,
                    color: Colors.white,
                    size: 28,
                  );
                }),
              ),
            ),
          ),
        ),

        // Share Button (Bottom Right)
        Positioned(
          bottom: 80,
          right: 16,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              ShareHelper.shareNews(
                title: insight.title,
                url: '${AppUrls.webBaseUrl}/insight/${insight.slug}',
                description: insight.title,
              );
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.rotationY(3.14159),
                    child: const Icon(Icons.reply, size: 18, color: Colors.black),
                  ),
                  const SizedBox(width: 6),
                  const Text(
                    'Share',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    ),
  );
}
}
