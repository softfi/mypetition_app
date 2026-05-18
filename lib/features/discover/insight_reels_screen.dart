import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_petition_app/controllers/discover_controller.dart';
import 'package:my_petition_app/core/constants/app_colors.dart';
import 'package:my_petition_app/core/utils/custom_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:my_petition_app/core/utils/date_formatter.dart';
import 'package:my_petition_app/core/config/app_urls.dart';
import 'package:shimmer/shimmer.dart';

class InsightReelsScreen extends StatefulWidget {
  const InsightReelsScreen({super.key});

  @override
  State<InsightReelsScreen> createState() => _InsightReelsScreenState();
}

class _InsightReelsScreenState extends State<InsightReelsScreen> {
  final controller = Get.find<DiscoverController>();
  late PageController _pageController;
  late int initialIndex;

  @override
  void initState() {
    super.initState();
    final args = Get.arguments as Map<String, dynamic>;
    initialIndex = args['index'] ?? 0;
    _pageController = PageController(initialPage: initialIndex);
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
      body: Stack(
        children: [
          PageView.builder(
            scrollDirection: Axis.vertical,
            controller: _pageController,
            itemCount: controller.insightsList.length,
            itemBuilder: (context, index) {
              return InsightReelItem(insight: controller.insightsList[index]);
            },
          ),
          // Back Button
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            left: 10,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.35),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white, size: 24),
                onPressed: () => Get.back(),
              ),
            ),
          ),
          
          // Header Text
          Positioned(
            top: MediaQuery.of(context).padding.top + 15,
            left: 0,
            right: 0,
            child: Center(
              child: AppText(
                title: 'Insights',
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
          ),

          // Go to First (Top) Button
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            right: 10,
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
                tooltip: 'Go to first',
                onPressed: () {
                  _pageController.animateToPage(
                    0,
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.easeOut,
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class InsightReelItem extends StatefulWidget {
  final dynamic insight;
  const InsightReelItem({super.key, required this.insight});

  @override
  State<InsightReelItem> createState() => _InsightReelItemState();
}

class _InsightReelItemState extends State<InsightReelItem> {
  int _currentImageIndex = 0;
  late PageController _horizontalController;

  @override
  void initState() {
    super.initState();
    _horizontalController = PageController();
  }

  @override
  void dispose() {
    _horizontalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final insight = widget.insight;
    final hasMultipleImages = insight.files.length > 1;

    return Stack(
      fit: StackFit.expand,
      children: [
        // Horizontal PageView for Multiple Images
        PageView.builder(
          scrollDirection: Axis.horizontal,
          controller: _horizontalController,
          itemCount: insight.files.length,
          onPageChanged: (index) {
            setState(() => _currentImageIndex = index);
          },
          itemBuilder: (context, imgIndex) {
            final imageUrl = '${AppUrls.s3BaseUrl}${insight.files[imgIndex].s3ImageUrl}';
            return CachedNetworkImage(
              imageUrl: imageUrl,
              fit: BoxFit.cover,
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

        // Dot Indicator for Multiple Images
        if (hasMultipleImages)
          Positioned(
            top: MediaQuery.of(context).padding.top + 60,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                insight.files.length,
                (index) => Container(
                  width: 6,
                  height: 6,
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _currentImageIndex == index
                        ? Colors.white
                        : Colors.white.withOpacity(0.4),
                  ),
                ),
              ),
            ),
          ),

        // Content Overlay
        Positioned(
          left: 16,
          right: 70,
          bottom: 40,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(2),
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [Colors.yellow, Colors.orange, Colors.red, Colors.purple],
                      ),
                    ),
                    child: const CircleAvatar(
                      radius: 16,
                      backgroundColor: Colors.white,
                      child: Icon(Icons.person, size: 20, color: Colors.grey),
                    ),
                  ),
                  const SizedBox(width: 10),
                  const AppText(
                    title: 'My Petition App',
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.white, width: 1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const AppText(
                      title: 'Follow',
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              AppText(
                title: insight.title,
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Colors.white,
                maxLines: 2,
                textOverflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.music_note, size: 14, color: Colors.white),
                  const SizedBox(width: 6),
                  const AppText(
                    title: 'Original Audio • Insight News',
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: Colors.white,
                  ),
                ],
              ),
            ],
          ),
        ),

        // Right Side Actions
        Positioned(
          right: 12,
          bottom: 60,
          child: Column(
            children: [
              _buildActionButton(Icons.favorite_border, '1.2K'),
              const SizedBox(height: 20),
              _buildActionButton(Icons.mode_comment_outlined, '456'),
              const SizedBox(height: 20),
              _buildActionButton(Icons.send_outlined, ''),
              const SizedBox(height: 20),
              const Icon(Icons.more_vert, color: Colors.white, size: 28),
              const SizedBox(height: 20),
              if (insight.files.isNotEmpty)
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.white, width: 2),
                    borderRadius: BorderRadius.circular(8),
                    image: DecorationImage(
                      image: CachedNetworkImageProvider('${AppUrls.s3BaseUrl}${insight.files[0].s3ImageUrl}'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton(IconData icon, String label) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 32),
        if (label.isNotEmpty) ...[
          const SizedBox(height: 4),
          AppText(
            title: label,
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ],
      ],
    );
  }
}
