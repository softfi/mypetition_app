import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_petition_app/controllers/saved_petitions_controller.dart';
import 'package:my_petition_app/core/constants/app_colors.dart';
import 'package:my_petition_app/core/utils/custom_text.dart';
import 'package:my_petition_app/core/models/petition_model.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:my_petition_app/core/config/app_urls.dart';
import 'package:my_petition_app/core/utils/date_formatter.dart';
import 'package:shimmer/shimmer.dart';
import 'package:my_petition_app/core/routes/app_routes.dart';

class SavedPetitionsScreen extends StatelessWidget {
  const SavedPetitionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(SavedPetitionsController());

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
          title: 'Saved Petitions',
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
      ),
      body: SafeArea(
        top: false,
        bottom: true,
        child: Obx(() {
        if (controller.isLoading.value) return _buildShimmerLoading();
        if (controller.savedPetitionsList.isEmpty) return _buildEmptyState();

        return RefreshIndicator(
          onRefresh: () => controller.fetchSavedPetitions(isRefresh: true),
          child: ListView.separated(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            itemCount: controller.savedPetitionsList.length + (controller.hasMore.value ? 1 : 0),
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              if (index == controller.savedPetitionsList.length) {
                controller.loadMore();
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                );
              }
              return _buildPetitionCard(context, controller.savedPetitionsList[index]);
            },
          ),
        );
      }),
      ),
    );
  }

  Widget _buildPetitionCard(BuildContext context, PetitionModel petition) {
    return GestureDetector(
      onTap: () => Get.toNamed(AppRoutes.petitionDetail, arguments: petition.slug),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(
                Theme.of(context).brightness == Brightness.light ? 0.05 : 0.2,
              ),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thumbnail
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                bottomLeft: Radius.circular(16),
              ),
              child: CachedNetworkImage(
                imageUrl: '${AppUrls.s3BaseUrl}${petition.s3ImageUrl}',
                width: 100,
                height: 110,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: Theme.of(context).dividerColor,
                ),
                errorWidget: (context, url, error) => Container(
                  width: 100,
                  height: 110,
                  color: Theme.of(context).dividerColor,
                  child: const Icon(Icons.campaign_outlined, size: 32, color: AppColors.grey400),
                ),
              ),
            ),
            // Content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Category badge
                    if (petition.category != null)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: AppText(
                          title: petition.category!.name.toUpperCase(),
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                    const SizedBox(height: 6),
                    // Title
                    AppText(
                      title: petition.title,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      maxLines: 2,
                      height: 1.3,
                    ),
                    const SizedBox(height: 8),
                    // Date row
                    Row(
                      children: [
                        Icon(Icons.calendar_today_outlined, size: 12, color: AppColors.grey500),
                        const SizedBox(width: 4),
                        AppText(
                          title: AppDateFormatter.formatDate(petition.createdAt),
                          fontSize: 11,
                          color: AppColors.grey500,
                        ),
                      ],
                    ),
                  ],
                ),
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
      itemCount: 6,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) => Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: Container(
          height: 110,
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
            decoration: const BoxDecoration(
              color: AppColors.grey100,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.bookmark_border_rounded, size: 64, color: AppColors.grey400),
          ),
          const SizedBox(height: 24),
          const AppText(
            title: 'No saved petitions yet',
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
          const SizedBox(height: 8),
          const AppText(
            title: 'Petitions you bookmark will appear here.',
            fontSize: 14,
            color: AppColors.textSecondary,
          ),
        ],
      ),
    );
  }
}
