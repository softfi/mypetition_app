import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_petition_app/controllers/discover_controller.dart';
import 'package:my_petition_app/core/constants/app_colors.dart';
import 'package:my_petition_app/core/utils/custom_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import 'package:my_petition_app/core/utils/date_formatter.dart';
import 'package:my_petition_app/core/config/app_urls.dart';
import 'package:my_petition_app/core/routes/app_routes.dart';
import 'package:intl/intl.dart';

class InsightsViewAllScreen extends GetView<DiscoverController> {
  const InsightsViewAllScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const AppText(
          title: 'Insights',
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
        if (controller.isInsightsLoading.value && controller.insightsList.isEmpty) {
          return _buildLoadingGrid();
        }

        if (controller.insightsList.isEmpty) {
          return const Center(child: AppText(title: 'No insights available'));
        }

        return RefreshIndicator(
          onRefresh: () => controller.fetchInsights(),
          child: GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 0.8,
            ),
            itemCount: controller.insightsList.length,
            itemBuilder: (context, index) {
              final insight = controller.insightsList[index];
              String? imageUrl;
              if (insight.files.isNotEmpty) {
                imageUrl = '${AppUrls.s3BaseUrl}${insight.files[0].s3ImageUrl}';
              }

              return InkWell(
                onTap: () => Get.toNamed(AppRoutes.insightReels, arguments: {'index': index, 'slug': insight.slug}),
                 child: Container(
                   decoration: BoxDecoration(
                     color: Theme.of(context).cardColor,
                   borderRadius: BorderRadius.circular(16),
                   boxShadow: [
                     BoxShadow(
                       color: Colors.black.withOpacity(Theme.of(context).brightness == Brightness.light ? 0.05 : 0.4),
                       blurRadius: 10,
                       offset: const Offset(0, 2),
                     ),
                   ],
                 ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                        child: imageUrl != null
                            ? CachedNetworkImage(
                                imageUrl: imageUrl,
                                width: double.infinity,
                                fit: BoxFit.cover,
                                 placeholder: (context, url) => Shimmer.fromColors(
                                   baseColor: Theme.of(context).brightness == Brightness.light ? AppColors.grey200 : Colors.grey[800]!,
                                   highlightColor: Theme.of(context).brightness == Brightness.light ? AppColors.grey100 : Colors.grey[700]!,
                                   child: Container(color: Theme.of(context).cardColor),
                                 ),
                                 errorWidget: (context, url, error) => Container(
                                   color: Theme.of(context).dividerColor,
                                   child: const Icon(Icons.error),
                                 ),
                              )
                            : Container(
                                color: Theme.of(context).dividerColor,
                                child: const Icon(Icons.image, color: AppColors.grey400),
                              ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AppText(
                            title: insight.title,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            maxLines: 1,
                            textOverflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(Icons.access_time, size: 10, color: AppColors.textHint),
                              const SizedBox(width: 4),
                              AppText(
                                title: AppDateFormatter.formatDateTime(insight.createdAt),
                                fontSize: 9,
                                color: AppColors.textHint,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ));
            },
          ),
        );
      }),
    );
  }

  Widget _buildLoadingGrid() {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.8,
      ),
      itemCount: 6,
      itemBuilder: (context, index) => Shimmer.fromColors(
        baseColor: Theme.of(context).brightness == Brightness.light ? AppColors.grey200 : Colors.grey[800]!,
        highlightColor: Theme.of(context).brightness == Brightness.light ? AppColors.grey100 : Colors.grey[700]!,
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }
}
