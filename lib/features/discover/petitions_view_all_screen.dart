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
import 'package:my_petition_app/core/utils/custom_button.dart';
import 'package:my_petition_app/core/constants/app_strings.dart';
import 'package:my_petition_app/controllers/auth_controller.dart';
import 'package:my_petition_app/controllers/profile_controller.dart';
import 'package:my_petition_app/core/utils/guest_dialog.dart';

class PetitionsViewAllScreen extends StatefulWidget {
  const PetitionsViewAllScreen({super.key});

  @override
  State<PetitionsViewAllScreen> createState() => _PetitionsViewAllScreenState();
}

class _PetitionsViewAllScreenState extends State<PetitionsViewAllScreen> {
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
      controller.loadMorePetitions();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        title: const AppText(
          title: 'All Petitions',
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
        if (controller.isPetitionsLoading.value && controller.petitionsList.isEmpty) {
          return _buildLoadingList();
        }

        if (controller.petitionsList.isEmpty) {
          return const Center(child: AppText(title: 'No petitions available'));
        }

        return RefreshIndicator(
          onRefresh: () => controller.fetchPetitions(),
          child: ListView.separated(
            controller: _scrollController,
            padding: const EdgeInsets.symmetric(vertical: 0),
            itemCount: controller.petitionsList.length + (controller.hasMorePetitions.value ? 1 : 0),
            separatorBuilder: (context, index) => const Divider(height: 1, color: AppColors.grey200),
            itemBuilder: (context, index) {
              if (index == controller.petitionsList.length) {
                return _buildMoreLoadingIndicator();
              }

              final petition = controller.petitionsList[index];
              final imageUrl = '${AppUrls.s3BaseUrl}${petition.s3ImageUrl}';
              
              return InkWell(
                onTap: () => Get.toNamed(AppRoutes.petitionDetail, arguments: petition.slug),
                child: Container(
                  color: AppColors.white,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CachedNetworkImage(
                        imageUrl: imageUrl,
                        height: 200,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Shimmer.fromColors(
                          baseColor: AppColors.grey200,
                          highlightColor: AppColors.grey100,
                          child: Container(color: AppColors.white),
                        ),
                        errorWidget: (context, url, error) => Container(
                          color: AppColors.grey200,
                          child: const Icon(Icons.image, size: 40, color: AppColors.grey400),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (petition.category != null)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 4),
                                child: AppText(
                                  title: petition.category!.name.toUpperCase(),
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.accent,
                                ),
                              ),
                            AppText.title(
                              title: petition.title,
                              fontSize: 15,
                              maxLines: 2,
                              textOverflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 8),
                            AppText(
                              title: petition.description,
                              fontSize: 12,
                              color: AppColors.textSecondary,
                              maxLines: 2,
                              textOverflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 16),
                            Obx(() {
                              final authController = Get.find<AuthController>();
                              final profileController = Get.find<ProfileController>();
                              final user = profileController.currentUser;
                              
                              if (user != null && user.isEmailVerified) {
                                return const SizedBox.shrink();
                              }

                              return Row(
                                children: [
                                  Expanded(
                                    child: CustomButton(
                                      text: AppStrings.signPetition,
                                      height: 36,
                                      borderRadius: 18,
                                      backgroundColor: AppColors.accent,
                                      fontSize: 12,
                                      onPressed: () {
                                        if (authController.isGuest) {
                                          GuestDialog.showLoginPrompt();
                                        } else {
                                          Get.toNamed(AppRoutes.emailVerify);
                                        }
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: CustomButton(
                                      text: AppStrings.objectPetition,
                                      type: CustomButtonType.outlined,
                                      height: 36,
                                      borderRadius: 18,
                                      borderColor: AppColors.grey300,
                                      textColor: AppColors.textPrimary,
                                      fontSize: 12,
                                      onPressed: () {
                                        if (authController.isGuest) {
                                          GuestDialog.showLoginPrompt();
                                        } else {
                                          Get.toNamed(AppRoutes.emailVerify);
                                        }
                                      },
                                    ),
                                  ),
                                ],
                              );
                            }),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                const Icon(Icons.how_to_vote, size: 14, color: AppColors.textHint),
                                const SizedBox(width: 6),
                                AppText(
                                  title: '${petition.voteCount} total votes',
                                  fontSize: 11,
                                  color: AppColors.textHint,
                                ),
                                const Spacer(),
                                AppText(
                                  title: AppDateFormatter.formatDateTime(petition.createdAt),
                                  fontSize: 11,
                                  color: AppColors.textHint,
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
            },
          ),
        );
      }),
    );
  }



  Widget _buildLoadingList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 4,
      itemBuilder: (context, index) => Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Shimmer.fromColors(
          baseColor: AppColors.grey200,
          highlightColor: AppColors.grey100,
          child: Container(
            height: 250,
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(16),
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
        child: Obx(() => controller.isMorePetitionsLoading.value
            ? const CircularProgressIndicator(strokeWidth: 2)
            : const SizedBox.shrink()),
      ),
    );
  }
}
