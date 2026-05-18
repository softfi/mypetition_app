import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_petition_app/controllers/discover_controller.dart';
import 'package:my_petition_app/core/constants/app_colors.dart';
import 'package:my_petition_app/core/utils/custom_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import 'package:my_petition_app/core/routes/app_routes.dart';
import 'package:my_petition_app/core/utils/date_formatter.dart';
import 'package:my_petition_app/core/config/app_urls.dart';

class NewsViewAllScreen extends StatefulWidget {
  const NewsViewAllScreen({super.key});

  @override
  State<NewsViewAllScreen> createState() => _NewsViewAllScreenState();
}

class _NewsViewAllScreenState extends State<NewsViewAllScreen> {
  final controller = Get.find<DiscoverController>();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      controller.loadMoreNews();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const AppText(
          title: 'Latest News',
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Theme.of(context).colorScheme.onSurface, size: 20),
          onPressed: () => Get.back(),
        ),
      ),
      body: Obx(() {
        // Access the value here to ensure Obx listens to changes
        final selectedId = controller.selectedNewsCategoryId.value;

        return Column(
          children: [
            // Category Tabs
            Container(
              height: 50,
              color: Theme.of(context).scaffoldBackgroundColor,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                physics: const BouncingScrollPhysics(),
                itemCount: controller.categoriesList.length + 1,
                itemBuilder: (context, index) {
                  final bool isAll = index == 0;
                  final category = isAll ? null : controller.categoriesList[index - 1];
                  final categoryId = isAll ? -1 : category!.id;
                  final isSelected = selectedId == categoryId;

                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: InkWell(
                      onTap: () => controller.setNewsCategory(categoryId),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: isSelected ? AppColors.accent : Colors.transparent,
                              width: 2,
                            ),
                          ),
                        ),
                        child: AppText(
                          title: isAll ? 'All' : category!.name,
                          fontSize: 14,
                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
                          color: isSelected ? AppColors.accent : Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            // const Divider(height: 1), // Removed divider below tabs as requested
            
            Expanded(
              child: _buildNewsList(),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildNewsList() {
    if (controller.isNewsLoading.value && controller.newsList.isEmpty) {
      return _buildLoadingList();
    }

    if (controller.newsList.isEmpty) {
      return const Center(child: AppText(title: 'No news available'));
    }

    return RefreshIndicator(
      onRefresh: () => controller.fetchNews(),
      child: ListView.separated(
        controller: _scrollController,
        padding: const EdgeInsets.only(top: 12, bottom: 100),
        itemCount: controller.newsList.length + (controller.hasMoreNews.value ? 1 : 0),
        separatorBuilder: (context, index) => const Divider(height: 1),
        itemBuilder: (context, index) {
          if (index == controller.newsList.length) {
            return _buildMoreLoadingIndicator();
          }

          final news = controller.newsList[index];
          final imageUrl = '${AppUrls.s3BaseUrl}${news.s3ImageUrl}';
          
          return InkWell(
            onTap: () => Get.toNamed(AppRoutes.newsDetail, arguments: {'index': index, 'slug': news.slug}),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              color: Theme.of(context).cardColor,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (news.category != null)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 6),
                            child: AppText(
                              title: news.category!.name.toUpperCase(),
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: AppColors.accent,
                            ),
                          ),
                        AppText.title(
                          title: news.title,
                          fontSize: 14,
                          maxLines: 3,
                          textOverflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        AppText(
                          title: news.description,
                          fontSize: 12,
                          color: AppColors.textSecondary,
                          maxLines: 2,
                          textOverflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            const Icon(Icons.access_time, size: 12, color: AppColors.textHint),
                            const SizedBox(width: 4),
                            AppText(
                              title: AppDateFormatter.formatDateTime(news.createdAt),
                              fontSize: 10,
                              color: AppColors.textHint,
                            ),
                            const Spacer(),
                            // Bookmark Button
                            GestureDetector(
                              onTap: () => controller.toggleSaveNews(news),
                              child: Icon(
                                news.isSaved ? Icons.bookmark : Icons.bookmark_border,
                                color: news.isSaved ? AppColors.accent : AppColors.grey500,
                                size: 16,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: CachedNetworkImage(
                      imageUrl: imageUrl,
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Shimmer.fromColors(
                        baseColor: Theme.of(context).brightness == Brightness.light ? AppColors.grey200 : Colors.grey[800]!,
                        highlightColor: Theme.of(context).brightness == Brightness.light ? AppColors.grey100 : Colors.grey[700]!,
                        child: Container(color: Theme.of(context).cardColor),
                      ),
                      errorWidget: (context, url, error) => Container(
                        width: 80,
                        height: 80,
                        color: AppColors.grey200,
                        child: const Icon(Icons.image, color: AppColors.grey400),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildLoadingList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 6,
      itemBuilder: (context, index) => Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Shimmer.fromColors(
          baseColor: Theme.of(context).brightness == Brightness.light ? AppColors.grey200 : Colors.grey[800]!,
          highlightColor: Theme.of(context).brightness == Brightness.light ? AppColors.grey100 : Colors.grey[700]!,
          child: Container(
            height: 100,
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMoreLoadingIndicator() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Center(
        child: Obx(() => controller.isMoreNewsLoading.value
            ? const CircularProgressIndicator(strokeWidth: 2)
            : const SizedBox.shrink()),
      ),
    );
  }
}
