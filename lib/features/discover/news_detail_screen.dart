import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_petition_app/controllers/discover_controller.dart';
import 'package:my_petition_app/core/constants/app_colors.dart';
import 'package:my_petition_app/core/utils/app_shimmer.dart';
import 'package:my_petition_app/core/utils/custom_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:my_petition_app/core/utils/date_formatter.dart';
import 'package:shimmer/shimmer.dart';
import 'package:my_petition_app/core/config/app_urls.dart';
import 'package:my_petition_app/controllers/auth_controller.dart';
import 'package:my_petition_app/core/utils/guest_dialog.dart';
import 'package:my_petition_app/core/utils/custom_button.dart';
import 'package:url_launcher/url_launcher.dart';
import 'widgets/font_size_controls.dart';
import 'package:my_petition_app/core/utils/share_helper.dart';

class NewsDetailScreen extends StatefulWidget {
  const NewsDetailScreen({super.key});

  @override
  State<NewsDetailScreen> createState() => _NewsDetailScreenState();
}

class _NewsDetailScreenState extends State<NewsDetailScreen> {
  final controller = Get.find<DiscoverController>();
  late PageController _pageController;
  late int _currentIndex;
  bool _commentsExpanded = false;

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
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Theme.of(context).colorScheme.onSurface, size: 20),
          onPressed: () => Get.back(),
        ),
        title: Obx(() => AppText(
          title: 'News ${_currentIndex + 1}/${controller.newsList.length}',
          fontSize: 14,
          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
        )),
        actions: [
          IconButton(
            icon: Icon(Icons.share_outlined, color: Theme.of(context).colorScheme.onSurface),
            onPressed: () {
              final news = controller.selectedNews.value;
              if (news != null) {
                ShareHelper.shareNews(
                  title: news.title,
                  url: '${AppUrls.webBaseUrl}/news/${news.slug}',
                  description: news.description,
                );
              }
            },
          ),
          Obx(() {
            final news = controller.selectedNews.value;
            if (news == null) return const SizedBox.shrink();
            return IconButton(
              icon: Icon(
                news.isSaved ? Icons.bookmark : Icons.bookmark_border,
                color: news.isSaved ? AppColors.accent : Theme.of(context).colorScheme.onSurface,
              ),
              onPressed: () => controller.toggleSaveNews(news),
            );
          }),
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
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                ),
                const Spacer(),
                if (news.views >= 100000)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.local_fire_department_rounded, size: 13, color: Colors.orange),
                        const SizedBox(width: 4),
                        AppText(
                          title: _formatViews(news.views),
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: Colors.orange,
                        ),
                      ],
                    ),
                  )
                else
                  SizedBox.shrink()
                  // Container(
                  //   padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  //   decoration: BoxDecoration(
                  //     color: AppColors.primary.withOpacity(0.08),
                  //     borderRadius: BorderRadius.circular(6),
                  //   ),
                  //   child: Row(
                  //     children: [
                  //       Icon(Icons.info_outline_rounded, size: 12, color: AppColors.primary),
                  //       const SizedBox(width: 4),
                  //       AppText(
                  //         title: 'Stats visible after 100K views',
                  //         fontSize: 9,
                  //         fontWeight: FontWeight.w600,
                  //         color: AppColors.primary,
                  //       ),
                  //     ],
                  //   ),
                  // ),
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
              baseColor: Theme.of(context).brightness == Brightness.light ? AppColors.grey200 : Colors.grey[800]!,
              highlightColor: Theme.of(context).brightness == Brightness.light ? AppColors.grey100 : Colors.grey[700]!,
              child: Container(color: Theme.of(context).cardColor),
            ),
            errorWidget: (context, url, error) => Container(
              height: 240,
              color: Theme.of(context).dividerColor,
              child: const Icon(Icons.image, size: 50, color: AppColors.grey400),
            ),
          ),
          // if (news.imageLinkUrl != null && news.imageLinkUrl!.isNotEmpty)
          //   Padding(
          //     padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          //     child: GestureDetector(
          //       onTap: () async {
          //         try {
          //           final url = Uri.parse(news.imageLinkUrl!);
          //           if (await canLaunchUrl(url)) {
          //             await launchUrl(url, mode: LaunchMode.platformDefault);
          //           } else {
          //             await launchUrl(url, mode: LaunchMode.platformDefault);
          //           }
          //         } catch (e) {
          //           debugPrint('Error launching URL: $e');
          //         }
          //       },
          //       child: AppText(
          //         title: 'Source: ${news.imageLinkUrl}',
          //         fontSize: 10,
          //         color: AppColors.primary,
          //         fontStyle: FontStyle.italic,
          //         decoration: TextDecoration.underline,
          //       ),
          //     ),
          //   ),


          // Description
          if (news.description.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border(
                    left: BorderSide(color: AppColors.accent, width: 4),
                  ),
                ),
                child: AppText(
                  title: "${news.description }",
                  fontSize: 16 * controller.fontSizeFactor.value,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onSurface,
                  height: 1.5,
                ),
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
                          onTapUrl: (url) async {
                            try {
                              final uri = Uri.parse(url);
                              await launchUrl(uri, mode: LaunchMode.platformDefault);
                              return true;
                            } catch (e) {
                              debugPrint('Error launching URL: $e');
                              return false;
                            }
                          },
                          customStylesBuilder: (element) {
                            if (element.localName == 'a') {
                              return {'text-decoration': 'none', 'color': '#007AFF'}; // Blue color but no underline
                            }
                            return null;
                          },
                            textStyle: TextStyle(
                              fontSize: 16 * controller.fontSizeFactor.value,
                              height: 1.6,
                              color: Theme.of(context).colorScheme.onSurface,
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
                          Theme.of(context).scaffoldBackgroundColor.withOpacity(0.0),
                          Theme.of(context).scaffoldBackgroundColor.withOpacity(0.8),
                          Theme.of(context).scaffoldBackgroundColor,
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
                onTapUrl: (url) async {
                  try {
                    final uri = Uri.parse(url);
                    await launchUrl(uri, mode: LaunchMode.platformDefault);
                    return true;
                  } catch (e) {
                    debugPrint('Error launching URL: $e');
                    return false;
                  }
                },
                customStylesBuilder: (element) {
                  if (element.localName == 'a') {
                    return {'text-decoration': 'none', 'color': '#007AFF'};
                  }
                  return null;
                },
                textStyle: TextStyle(
                  fontSize: 16 * controller.fontSizeFactor.value,
                  height: 1.6,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ),

          // Comments Section
          _buildCommentsSection(news),

          const SizedBox(height: 80),
        ],
      ),
    );
  }

  String _formatViews(int views) {
    if (views >= 1000000) return '${(views / 1000000).toStringAsFixed(1)}M views';
    if (views >= 1000) return '${(views / 1000).toStringAsFixed(0)}K views';
    return '$views views';
  }

  Widget _buildCommentsSection(dynamic news) {
    final TextEditingController commentCtrl = TextEditingController();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        Container(
          height: 8,
          color: Theme.of(context).brightness == Brightness.light
              ? AppColors.grey100
              : const Color(0xFF1A1A1A),
        ),
        // Collapsible Header
        GestureDetector(
          onTap: () => setState(() => _commentsExpanded = !_commentsExpanded),
          child: Container(
            color: Colors.transparent,
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
            child: Row(
              children: [
                const Icon(Icons.comment_outlined, size: 20),
                const SizedBox(width: 8),
                const AppText(
                  title: 'Comments',
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                ),
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: AppText(
                    title: '3',
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
                const Spacer(),
                AnimatedRotation(
                  turns: _commentsExpanded ? 0.5 : 0.0,
                  duration: const Duration(milliseconds: 300),
                  child: const Icon(Icons.keyboard_arrow_down_rounded, size: 24),
                ),
              ],
            ),
          ),
        ),
        // Animated Expandable Content
        AnimatedCrossFade(
          duration: const Duration(milliseconds: 350),
          crossFadeState: _commentsExpanded
              ? CrossFadeState.showFirst
              : CrossFadeState.showSecond,
          firstChild: Column(
            children: [
              // Comment Input Box
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.person, size: 20, color: AppColors.primary),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardColor,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: Theme.of(context).dividerColor),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: commentCtrl,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Theme.of(context).colorScheme.onSurface,
                                ),
                                decoration: InputDecoration(
                                  hintText: 'Write a comment...',
                                  hintStyle: TextStyle(
                                    fontSize: 13,
                                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
                                  ),
                                  border: InputBorder.none,
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(right: 6),
                              child: GestureDetector(
                                onTap: () {},
                                child: Container(
                                  width: 32,
                                  height: 32,
                                  decoration: BoxDecoration(
                                    color: AppColors.primary,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.send_rounded, color: Colors.white, size: 16),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _buildCommentItem(
                avatar: 'R',
                name: 'Rahul Sharma',
                time: '2 hours ago',
                text: 'Very informative article. Thanks for sharing this!',
                likes: 12,
              ),
              _buildCommentItem(
                avatar: 'P',
                name: 'Priya Singh',
                time: '5 hours ago',
                text: 'Great coverage on this topic. Keep it up!',
                likes: 7,
              ),
              _buildCommentItem(
                avatar: 'A',
                name: 'Amit Kumar',
                time: '1 day ago',
                text: 'This is exactly what I was looking for. Very well explained.',
                likes: 24,
              ),
              const SizedBox(height: 8),
            ],
          ),
          secondChild: const SizedBox.shrink(),
        ),
      ],
    );
  }



  Widget _buildCommentItem({
    required String avatar,
    required String name,
    required String time,
    required String text,
    required int likes,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: AppText(
                title: avatar,
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(16),
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      AppText(
                        title: name,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                      const Spacer(),
                      AppText(
                        title: time,
                        fontSize: 11,
                        color: AppColors.grey500,
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  AppText(
                    title: text,
                    fontSize: 13,
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.85),
                    height: 1.4,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.thumb_up_outlined, size: 14, color: AppColors.grey500),
                      const SizedBox(width: 4),
                      AppText(
                        title: '$likes',
                        fontSize: 12,
                        color: AppColors.grey500,
                      ),
                      const SizedBox(width: 16),
                      AppText(
                        title: 'Reply',
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
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
            child: AppShimmer.fromColors(
              context: context,
              child: Container(height: 20, width: 150, color: Theme.of(context).cardColor),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: AppShimmer.fromColors(
              context: context,
              child: Container(height: 80, width: double.infinity, color: Theme.of(context).cardColor),
            ),
          ),
          const SizedBox(height: 20),
          AppShimmer.fromColors(
            context: context,
            child: Container(height: 240, width: double.infinity, color: Theme.of(context).cardColor),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: List.generate(
                5,
                (index) => Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: AppShimmer.fromColors(
                    context: context,
                    child: Container(height: 16, width: double.infinity, color: Theme.of(context).cardColor),
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
