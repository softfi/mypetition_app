import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_petition_app/controllers/saved_insights_controller.dart';
import 'package:my_petition_app/core/constants/app_colors.dart';
import 'package:my_petition_app/core/utils/custom_text.dart';
import 'package:my_petition_app/core/models/insight_model.dart';
import 'package:my_petition_app/features/discover/insight_detail_screen.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:my_petition_app/core/config/app_urls.dart';
import 'package:my_petition_app/core/utils/date_formatter.dart';
import 'package:shimmer/shimmer.dart';
import 'package:my_petition_app/core/routes/app_routes.dart';

class SavedInsightsScreen extends StatelessWidget {
  const SavedInsightsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(SavedInsightsController());

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
          title: 'Saved Insights',
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return _buildShimmerLoading();
        }

        if (controller.savedInsightsList.isEmpty) {
          return _buildEmptyState();
        }

        return RefreshIndicator(
          onRefresh: () => controller.fetchSavedInsights(isRefresh: true),
          child: GridView.builder(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 16,
              childAspectRatio: 0.6,
            ),
            itemCount: controller.savedInsightsList.length + (controller.hasMore.value ? 1 : 0),
            itemBuilder: (context, index) {
              if (index == controller.savedInsightsList.length) {
                controller.loadMore();
                return const Center(child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: CircularProgressIndicator(strokeWidth: 2),
                ));
              }

              final insight = controller.savedInsightsList[index];
              return _buildInsightCard(context, insight, index);
            },
          ),
        );
      }),
    );
  }

  Widget _buildInsightCard(BuildContext context, InsightModel insight, int index) {
    String imageUrl = '';
    if (insight.files.isNotEmpty) {
      imageUrl = '${AppUrls.s3BaseUrl}${insight.files.first.s3ImageUrl}';
    }

    return GestureDetector(
      onTap: () => Get.toNamed(AppRoutes.insightReels, arguments: {
        'index': index, 
        'slug': insight.slug,
        'source': 'saved',
      }),
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
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: imageUrl.isNotEmpty
              ? CachedNetworkImage(
                  imageUrl: imageUrl,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(color: Colors.grey[200]),
                  errorWidget: (context, url, error) => Container(
                    color: Colors.grey[200],
                    child: const Icon(Icons.lightbulb, size: 40, color: Colors.grey),
                  ),
                )
              : Container(
                  color: Colors.grey[200],
                  child: const Icon(Icons.lightbulb, size: 40, color: Colors.grey),
                ),
        ),
      ),
    );
  }

  Widget _buildShimmerLoading() {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 16,
        childAspectRatio: 0.6,
      ),
      itemCount: 6,
      itemBuilder: (context, index) => Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: Container(
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
            child: Icon(Icons.bookmark_border_rounded, size: 64, color: AppColors.grey400),
          ),
          const SizedBox(height: 24),
          const AppText(
            title: 'No saved insights yet',
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
          const SizedBox(height: 8),
          AppText(
            title: 'Insights you bookmark will appear here.',
            fontSize: 14,
            color: AppColors.textSecondary,
          ),
        ],
      ),
    );
  }
}
