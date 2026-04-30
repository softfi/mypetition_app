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
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        title: const AppText(
          title: 'Insights',
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.textPrimary, size: 20),
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
                onTap: () => Get.toNamed(AppRoutes.insightDetail, arguments: insight.slug),
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.black.withOpacity(0.05),
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
                                  baseColor: AppColors.grey200,
                                  highlightColor: AppColors.grey100,
                                  child: Container(color: AppColors.white),
                                ),
                                errorWidget: (context, url, error) => const Icon(Icons.error),
                              )
                            : Container(
                                color: AppColors.grey200,
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
        baseColor: AppColors.grey200,
        highlightColor: AppColors.grey100,
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }
}
