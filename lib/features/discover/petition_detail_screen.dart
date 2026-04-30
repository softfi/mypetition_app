import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_petition_app/controllers/discover_controller.dart';
import 'package:my_petition_app/core/constants/app_colors.dart';
import 'package:my_petition_app/core/utils/custom_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:my_petition_app/core/utils/date_formatter.dart';
import 'package:my_petition_app/core/config/app_urls.dart';
import 'package:shimmer/shimmer.dart';
import 'package:my_petition_app/core/utils/custom_button.dart';
import 'package:my_petition_app/core/constants/app_strings.dart';
import 'package:my_petition_app/controllers/auth_controller.dart';
import 'package:my_petition_app/controllers/profile_controller.dart';
import 'package:my_petition_app/core/utils/guest_dialog.dart';
import 'package:my_petition_app/core/utils/toast_message.dart';
import 'package:my_petition_app/core/routes/app_routes.dart';
import 'widgets/font_size_controls.dart';

class PetitionDetailScreen extends StatefulWidget {
  const PetitionDetailScreen({super.key});

  @override
  State<PetitionDetailScreen> createState() => _PetitionDetailScreenState();
}

class _PetitionDetailScreenState extends State<PetitionDetailScreen> {
  final controller = Get.find<DiscoverController>();
  late String slug;

  @override
  void initState() {
    super.initState();
    slug = Get.arguments as String;
    controller.fetchPetitionDetail(slug);
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
      body: Obx(() {
        if (controller.isPetitionDetailLoading.value) {
          return _buildLoadingShimmer();
        }

        final petition = controller.selectedPetition.value;
        if (petition == null) {
          return const Center(child: AppText(title: 'Petition not found'));
        }

        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image
              CachedNetworkImage(
                imageUrl: '${AppUrls.s3BaseUrl}${petition.s3ImageUrl}',
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

              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Category and Date
                    Row(
                      children: [
                        if (petition.category != null)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.accent.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: AppText(
                              title: petition.category!.name.toUpperCase(),
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: AppColors.accent,
                            ),
                          ),
                        const Spacer(),
                        AppText(
                          title: AppDateFormatter.formatDateTime(petition.createdAt),
                          fontSize: 11,
                          color: AppColors.textSecondary,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Title
                    AppText.title(
                      title: petition.title,
                      fontSize: 22 * controller.fontSizeFactor.value,
                      height: 1.3,
                    ),
                    const SizedBox(height: 12),

                    // Location info
                    if (petition.state != null || petition.district != null)
                      Row(
                        children: [
                          const Icon(Icons.location_on_outlined, size: 14, color: AppColors.textHint),
                          const SizedBox(width: 4),
                          AppText(
                            title: '${petition.district?.name ?? ''}${petition.district != null ? ', ' : ''}${petition.state?.name ?? ''}',
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ],
                      ),
                    
                    const SizedBox(height: 20),
                    
                    // Vote Count Progress
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.grey100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              AppText(
                                title: '${petition.voteCount} total votes',
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                              AppText(
                                title: 'Goal: 10,000',
                                fontSize: 11,
                                color: AppColors.textHint,
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: (petition.voteCount / 10000).clamp(0.05, 1.0),
                              backgroundColor: AppColors.grey300,
                              color: AppColors.accent,
                              minHeight: 8,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Content
                    if (Get.find<AuthController>().isGuest)
                      Stack(
                        alignment: Alignment.bottomCenter,
                        children: [
                          SizedBox(
                            height: 200,
                            child: ClipRect(
                              child: OverflowBox(
                                maxWidth: MediaQuery.of(context).size.width,
                                minHeight: 0,
                                maxHeight: double.infinity,
                                alignment: Alignment.topCenter,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 16),
                                  child: HtmlWidget(
                                    petition.content,
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
                              height: 150,
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
                                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 10),
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
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: HtmlWidget(
                          petition.content,
                          textStyle: TextStyle(
                            fontSize: 16 * controller.fontSizeFactor.value,
                            height: 1.6,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),

                    const SizedBox(height: 32),

                    // Action Buttons
                    Obx(() {
                      final authController = Get.find<AuthController>();
                      final profileController = Get.find<ProfileController>();
                      final user = profileController.currentUser;
                      
                      // If verified, show VOTE button
                      if (user != null && user.isEmailVerified) {
                        return CustomButton(
                          text: 'Vote Now',
                          height: 48,
                          borderRadius: 24,
                          backgroundColor: AppColors.accent,
                          onPressed: () => _showVoteBottomSheet(context),
                        );
                      }

                      // Otherwise show Sign/Object
                      return Row(
                        children: [
                          Expanded(
                            child: CustomButton(
                              text: AppStrings.signPetition,
                              height: 48,
                              borderRadius: 24,
                              backgroundColor: AppColors.accent,
                              fontSize: 14,
                              onPressed: () {
                                if (authController.isGuest) {
                                  GuestDialog.showLoginPrompt();
                                } else {
                                  Get.toNamed(AppRoutes.emailVerify);
                                }
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: CustomButton(
                              text: AppStrings.objectPetition,
                              type: CustomButtonType.outlined,
                              height: 48,
                              borderRadius: 24,
                              borderColor: AppColors.grey300,
                              textColor: AppColors.textPrimary,
                              fontSize: 14,
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
                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  void _showVoteBottomSheet(BuildContext context) {
    final commentController = TextEditingController();
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const AppText(title: 'Cast Your Vote', fontSize: 18, fontWeight: FontWeight.w700),
            const SizedBox(height: 12),
            const AppText(
              title: 'Do you support this petition?',
              fontSize: 14,
              color: AppColors.textSecondary,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            TextField(
              controller: commentController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Add a comment (optional)',
                hintStyle: const TextStyle(fontSize: 13, color: AppColors.textHint),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.grey300),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.grey300),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: Obx(() => CustomButton(
                    text: 'YES',
                    backgroundColor: AppColors.green,
                    isLoading: controller.isVoting.value,
                    onPressed: () async {
                      final success = await controller.castVote(
                        petitionId: controller.selectedPetition.value!.id!,
                        vote: 'yes',
                        comment: commentController.text,
                      );
                      if (success) {
                        Get.back();
                        CommonToast.showToastSuccess('Vote cast successfully');
                      } else {
                        CommonToast.showToastError('Failed to cast vote');
                      }
                    },
                  )),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Obx(() => CustomButton(
                    text: 'NO',
                    backgroundColor: AppColors.error,
                    isLoading: controller.isVoting.value,
                    onPressed: () async {
                      final success = await controller.castVote(
                        petitionId: controller.selectedPetition.value!.id!,
                        vote: 'no',
                        comment: commentController.text,
                      );
                      if (success) {
                        Get.back();
                        CommonToast.showToastSuccess('Vote cast successfully');
                      } else {
                        CommonToast.showToastError('Failed to cast vote');
                      }
                    },
                  )),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  Widget _buildLoadingShimmer() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Shimmer.fromColors(
            baseColor: AppColors.grey200,
            highlightColor: AppColors.grey100,
            child: Container(height: 240, width: double.infinity, color: AppColors.white),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Shimmer.fromColors(
                  baseColor: AppColors.grey200,
                  highlightColor: AppColors.grey100,
                  child: Container(height: 20, width: 100, color: AppColors.white),
                ),
                const SizedBox(height: 16),
                Shimmer.fromColors(
                  baseColor: AppColors.grey200,
                  highlightColor: AppColors.grey100,
                  child: Container(height: 30, width: double.infinity, color: AppColors.white),
                ),
                const SizedBox(height: 8),
                Shimmer.fromColors(
                  baseColor: AppColors.grey200,
                  highlightColor: AppColors.grey100,
                  child: Container(height: 30, width: 200, color: AppColors.white),
                ),
                const SizedBox(height: 24),
                Shimmer.fromColors(
                  baseColor: AppColors.grey200,
                  highlightColor: AppColors.grey100,
                  child: Container(height: 200, width: double.infinity, color: AppColors.white),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
