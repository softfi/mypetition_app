import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_petition_app/core/constants/app_colors.dart';
import 'package:my_petition_app/core/utils/custom_text.dart';
import 'package:my_petition_app/controllers/profile_controller.dart';
import 'package:my_petition_app/core/models/petition_model.dart';
import 'package:my_petition_app/core/config/app_urls.dart';
import 'package:my_petition_app/core/routes/app_routes.dart';
import 'package:my_petition_app/core/utils/date_formatter.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';

class MyPetitionsScreen extends StatelessWidget {
  const MyPetitionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ProfileController profileController = Get.find<ProfileController>();

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        title: AppText(
          title: 'My Petitions',
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: Theme.of(context).colorScheme.onSurface,
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: Theme.of(context).colorScheme.onSurface, size: 20),
          onPressed: () => Get.back(),
        ),
      ),
      body: Obx(() {
        if (profileController.isLoadingUserPetitions && profileController.userPetitions.isEmpty) {
          return _buildShimmerList();
        }

        if (profileController.userPetitions.isEmpty) {
          return _buildEmptyState(context);
        }

        return RefreshIndicator(
          onRefresh: () => profileController.fetchUserPetitions(refresh: true),
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: profileController.userPetitions.length,
            itemBuilder: (context, index) {
              final petition = profileController.userPetitions[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: _buildPetitionCard(context, petition),
              );
            },
          ),
        );
      }),
    );
  }

  Widget _buildPetitionCard(BuildContext context, PetitionModel petition) {
    final imageUrl = '${AppUrls.s3BaseUrl}${petition.s3ImageUrl}';

    return GestureDetector(
      onTap: () => Get.toNamed(AppRoutes.petitionDetail, arguments: petition),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
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
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              child: SizedBox(
                width: double.infinity,
                height: 160,
                child: CachedNetworkImage(
                  imageUrl: imageUrl,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(color: Theme.of(context).dividerColor),
                  errorWidget: (context, url, error) => Container(
                    color: Theme.of(context).dividerColor,
                    child: const Icon(Icons.image, color: AppColors.grey400),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: _getStatusColor(petition.status).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: AppText(
                          title: petition.status.toUpperCase(),
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: _getStatusColor(petition.status),
                        ),
                      ),
                      AppText(
                        title: AppDateFormatter.formatDateTime(petition.createdAt),
                        fontSize: 10,
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  AppText(
                    title: petition.title,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurface,
                    maxLines: 2,
                    textOverflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(Icons.how_to_vote, size: 14, color: AppColors.grey400),
                      const SizedBox(width: 6),
                      AppText(
                        title: '${petition.voteCount} votes',
                        fontSize: 12,
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                      ),
                      const Spacer(),
                      const AppText(
                        title: 'View Details >',
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.accent,
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

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending': return Colors.orange;
      case 'approved': return Colors.green;
      case 'rejected': return Colors.red;
      default: return AppColors.grey500;
    }
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.description_outlined, size: 64, color: AppColors.grey400),
          const SizedBox(height: 16),
          const AppText(
            title: 'No Petitions Found',
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
          const SizedBox(height: 8),
          AppText(
            title: 'You haven\'t created any petitions yet.',
            fontSize: 14,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 3,
      itemBuilder: (context, index) => Shimmer.fromColors(
        baseColor: Theme.of(context).brightness == Brightness.light ? AppColors.grey200 : Colors.grey[800]!,
        highlightColor: Theme.of(context).brightness == Brightness.light ? AppColors.grey100 : Colors.grey[700]!,
        child: Container(
          height: 200,
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }
}
