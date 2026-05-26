import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_petition_app/controllers/saved_news_controller.dart';
import 'package:my_petition_app/core/constants/app_colors.dart';
import 'package:my_petition_app/core/utils/custom_text.dart';
import 'package:my_petition_app/core/models/news_model.dart';
import 'package:my_petition_app/features/discover/news_detail_screen.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:my_petition_app/core/config/app_urls.dart';
import 'package:my_petition_app/core/utils/date_formatter.dart';
import 'package:shimmer/shimmer.dart';

class SavedNewsScreen extends StatelessWidget {
  const SavedNewsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(SavedNewsController());

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
        centerTitle: true,
        title: const AppText(
          title: 'Saved News',
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
      ),
      body: SafeArea(
        top: false,
        bottom: true,
        child: Obx(() {
        if (controller.isLoading.value) {
          return _buildShimmerLoading();
        }

        if (controller.savedNewsList.isEmpty) {
          return _buildEmptyState();
        }

        return RefreshIndicator(
          onRefresh: () => controller.fetchSavedNews(isRefresh: true),
          child: ListView.separated(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            itemCount: controller.savedNewsList.length + (controller.hasMore.value ? 1 : 0),
            separatorBuilder: (_, __) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              if (index == controller.savedNewsList.length) {
                controller.loadMore();
                return const Center(child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: CircularProgressIndicator(strokeWidth: 2),
                ));
              }

              final news = controller.savedNewsList[index];
              return _buildNewsCard(context, news);
            },
          ),
        );
      }),
      ),
    );
  }

  Widget _buildNewsCard(BuildContext context, NewsModel news) {
    final imageUrl = news.s3ImageUrl.startsWith('http') 
        ? news.s3ImageUrl 
        : '${AppUrls.s3BaseUrl}${news.s3ImageUrl}';

    return GestureDetector(
      onTap: () => Get.to(() => const NewsDetailScreen(), arguments: news.slug),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(Theme.of(context).brightness == Brightness.light ? 0.05 : 0.2),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Section with Category Badge
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                  child: CachedNetworkImage(
                    imageUrl: imageUrl,
                    height: 180,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(color: Colors.grey[200]),
                    errorWidget: (context, url, error) => Container(
                      color: Colors.grey[200],
                      child: const Icon(Icons.newspaper, size: 40, color: Colors.grey),
                    ),
                  ),
                ),
                if (news.category != null)
                  Positioned(
                    top: 12,
                    left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.accent,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: AppText(
                        title: news.category!.name.toUpperCase(),
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
              ],
            ),
            
            // Content Section
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText(
                    title: news.title,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    maxLines: 2,
                    height: 1.3,
                  ),
                  /*
                  AppText(
                    title: news.description,
                    fontSize: 13,
                    color: AppColors.textSecondary,
                    maxLines: 2,
                    height: 1.4,
                  ),
                  */
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Icon(Icons.calendar_today_outlined, size: 12, color: AppColors.grey500),
                      const SizedBox(width: 4),
                      AppText(
                        title: AppDateFormatter.formatDateTime(news.createdAt),
                        fontSize: 12,
                        color: AppColors.grey500,
                      ),
                      const Spacer(),
                      Row(
                        children: [
                          Icon(Icons.remove_red_eye_outlined, size: 14, color: AppColors.grey500),
                          const SizedBox(width: 4),
                          AppText(
                            title: 'View Detail',
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                          Icon(Icons.arrow_forward_rounded, size: 14, color: AppColors.primary),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShimmerLoading() {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: 4,
      separatorBuilder: (_, __) => const SizedBox(height: 16),
      itemBuilder: (context, index) => Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: Container(
          height: 280,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.grey100,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.favorite_border_rounded, size: 64, color: AppColors.grey400),
          ),
          const SizedBox(height: 24),
          const AppText(
            title: 'No saved news yet',
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
          const SizedBox(height: 8),
          AppText(
            title: 'News you bookmark will appear here.',
            fontSize: 14,
            color: AppColors.textSecondary,
          ),
        ],
      ),
    );
  }
}
