import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_petition_app/controllers/discover_controller.dart';
import 'package:my_petition_app/core/constants/app_colors.dart';
import 'package:my_petition_app/core/utils/custom_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:my_petition_app/core/utils/date_formatter.dart';
import 'package:shimmer/shimmer.dart';
import 'package:my_petition_app/core/config/app_urls.dart';
import 'package:my_petition_app/controllers/auth_controller.dart';
import 'package:my_petition_app/core/utils/guest_dialog.dart';
import 'package:my_petition_app/core/utils/custom_button.dart';
import 'widgets/font_size_controls.dart';

class NewsDetailScreen extends StatefulWidget {
  const NewsDetailScreen({super.key});

  @override
  State<NewsDetailScreen> createState() => _NewsDetailScreenState();
}

class _NewsDetailScreenState extends State<NewsDetailScreen> {
  final controller = Get.find<DiscoverController>();
  late PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    // Support both old slug-only and new index+slug arguments
    final args = Get.arguments;
    if (args is Map) {
      _currentIndex = args['index'] ?? 0;
    } else {
      // Fallback for direct slug navigation
      _currentIndex = controller.newsList.indexWhere((e) => e.slug == args);
      if (_currentIndex == -1) _currentIndex = 0;
    }

    _pageController = PageController(initialPage: _currentIndex);
    
    // Initial fetch
    if (controller.newsList.isNotEmpty) {
      controller.fetchNewsDetail(controller.newsList[_currentIndex].slug);
    } else if (args is String) {
      controller.fetchNewsDetail(args);
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentIndex = index;
    });
    
    // Fetch detail for new page
    final news = controller.newsList[index];
    controller.fetchNewsDetail(news.slug);

    // Load more if reaching end
    if (index >= controller.newsList.length - 2) {
      controller.loadMoreNews();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.textPrimary, size: 20),
          onPressed: () => Get.back(),
        ),
        title: Obx(() => AppText(
          title: 'News ${_currentIndex + 1}/${controller.newsList.length}',
          fontSize: 14,
          color: AppColors.textHint,
        )),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined, color: AppColors.textPrimary),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.bookmark_border, color: AppColors.textPrimary),
            onPressed: () {},
          ),
        ],
      ),
      floatingActionButton: const FontSizeControls(),
      body: PageView.builder(
        controller: _pageController,
        onPageChanged: _onPageChanged,
        itemCount: controller.newsList.length,
        itemBuilder: (context, index) {
          return Obx(() {
            // Only show content if this is the active page and not loading
            // We use a unique check for slug to match current fetched detail
            final news = controller.selectedNews.value;
            final isCurrentPageLoading = controller.isNewsDetailLoading.value;
            
            // If we are on this index, we show the fetched detail
            if (index == _currentIndex) {
              if (isCurrentPageLoading) return _buildLoadingShimmer();
              if (news == null) return const Center(child: AppText(title: 'News not found'));
              return _buildNewsContent(news);
            }
            
            // Placeholder for other pages to allow smooth swiping
            return _buildLoadingShimmer();
          });
        },
      ),
    );
  }

  Widget _buildNewsContent(dynamic news) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Category and Date
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                if (news.category != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.accent.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: AppText(
                      title: news.category!.name.toUpperCase(),
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: AppColors.accent,
                    ),
                  ),
                const SizedBox(width: 12),
                AppText(
                  title: AppDateFormatter.formatDateTime(news.createdAt),
                  fontSize: 11,
                  fontWeight: FontWeight.w400,
                  color: AppColors.textSecondary,
                ),
              ],
            ),
          ),

          // Title
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: AppText.title(
              title: news.title,
              fontSize: 22,
              height: 1.3,
            ),
          ),

          // Image
          const SizedBox(height: 12),
          CachedNetworkImage(
            imageUrl: '${AppUrls.s3BaseUrl}${news.s3ImageUrl}',
            width: double.infinity,
            height: 240,
            fit: BoxFit.cover,
            placeholder: (context, url) => Shimmer.fromColors(
              baseColor: AppColors.grey200,
              highlightColor: AppColors.grey100,
              child: Container(color: AppColors.white),
            ),
            errorWidget: (context, url, error) => Container(
              height: 240,
              color: AppColors.grey200,
              child: const Icon(Icons.image, size: 50, color: AppColors.grey400),
            ),
          ),
          if (news.imageLinkUrl != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: AppText(
                title: 'Source: ${news.imageLinkUrl}',
                fontSize: 10,
                color: AppColors.textHint,
                fontStyle: FontStyle.italic,
              ),
            ),

          // Content
          if (Get.find<AuthController>().isGuest)
            Stack(
              alignment: Alignment.bottomCenter,
              children: [
                SizedBox(
                  height: 250,
                  child: ClipRect(
                    child: OverflowBox(
                      maxWidth: MediaQuery.of(context).size.width,
                      minHeight: 0,
                      maxHeight: double.infinity,
                      alignment: Alignment.topCenter,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: HtmlWidget(
                          news.content,
                          textStyle: TextStyle(
                            fontSize: 16 * controller.fontSizeFactor.value,
                            height: 1.6,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    height: 200,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          AppColors.white.withOpacity(0.0),
                          AppColors.white.withOpacity(0.8),
                          AppColors.white,
                        ],
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                          child: CustomButton(
                            text: 'Read More',
                            type: CustomButtonType.outlined,
                            isFullWidth: false,
                            onPressed: () => GuestDialog.showLoginPrompt(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            )
          else
            Padding(
              padding: const EdgeInsets.all(16),
              child: HtmlWidget(
                news.content,
                textStyle: TextStyle(
                  fontSize: 16 * controller.fontSizeFactor.value,
                  height: 1.6,
                  color: AppColors.textPrimary,
                ),
              ),
            ),

          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _buildLoadingShimmer() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Shimmer.fromColors(
              baseColor: AppColors.grey200,
              highlightColor: AppColors.grey100,
              child: Container(height: 20, width: 150, color: AppColors.white),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Shimmer.fromColors(
              baseColor: AppColors.grey200,
              highlightColor: AppColors.grey100,
              child: Container(height: 80, width: double.infinity, color: AppColors.white),
            ),
          ),
          const SizedBox(height: 20),
          Shimmer.fromColors(
            baseColor: AppColors.grey200,
            highlightColor: AppColors.grey100,
            child: Container(height: 240, width: double.infinity, color: AppColors.white),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: List.generate(
                5,
                (index) => Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Shimmer.fromColors(
                    baseColor: AppColors.grey200,
                    highlightColor: AppColors.grey100,
                    child: Container(height: 16, width: double.infinity, color: AppColors.white),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
