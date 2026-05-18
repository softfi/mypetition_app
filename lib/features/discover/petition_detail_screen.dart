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
import 'package:url_launcher/url_launcher.dart';
import 'package:my_petition_app/core/utils/animated_border_button.dart';
import 'package:my_petition_app/core/utils/share_helper.dart';
import 'widgets/font_size_controls.dart';
import 'package:my_petition_app/core/models/petition_model.dart';

class PetitionDetailScreen extends StatefulWidget {
  const PetitionDetailScreen({super.key});

  @override
  State<PetitionDetailScreen> createState() => _PetitionDetailScreenState();
}

class _PetitionDetailScreenState extends State<PetitionDetailScreen> {
  final controller = Get.find<DiscoverController>();
  late String slug;
  bool _commentsExpanded = false;

  @override
  void initState() {
    super.initState();
    final args = Get.arguments;
    if (args is String) {
      slug = args;
      controller.fetchPetitionDetail(slug);
    } else if (args is PetitionModel) {
      slug = args.slug;
      controller.selectedPetition.value = args;
      // We don't call fetchPetitionDetail here because user said there is no API for My Petitions detail
      // This ensures 'pending' petitions from "My Petitions" list show up correctly.
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Theme.of(context).colorScheme.onSurface, size: 20),
          onPressed: () => Get.back(),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.share_outlined, color: Theme.of(context).colorScheme.onSurface),
            onPressed: () {
              final petition = controller.selectedPetition.value;
              if (petition != null) {
                ShareHelper.sharePetition(
                  title: petition.title,
                  url: '${AppUrls.webBaseUrl}/petition/${petition.slug}',
                  description: petition.description,
                );
              }
            },
          ),
          IconButton(
            icon: Icon(Icons.bookmark_border, color: Theme.of(context).colorScheme.onSurface),
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
                placeholder: (context, url) => Shimmer.fromColors(
                  baseColor: Theme.of(context).dividerColor,
                  highlightColor: Theme.of(context).cardColor,
                  child: Container(color: Theme.of(context).cardColor),
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
                        if (petition.views > 0) ...[
                          const SizedBox(width: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.grey100,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.remove_red_eye_outlined, size: 12, color: AppColors.grey500),
                                const SizedBox(width: 4),
                                AppText(
                                  title: _formatNumber(petition.views),
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.grey500,
                                ),
                              ],
                            ),
                          ),
                        ],
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
                    if (petition.voteCount >= 50000)
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardColor,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.03),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    AppText(
                                      title: '${petition.voteCount} total votes',
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                      color: Theme.of(context).colorScheme.onSurface,
                                    ),
                                    const SizedBox(height: 2),
                                    AppText(
                                      title: 'Community Consensus',
                                      fontSize: 11,
                                      color: AppColors.textHint,
                                    ),
                                  ],
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: AppColors.accent.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.trending_up, size: 12, color: AppColors.accent),
                                      const SizedBox(width: 4),
                                      AppText(
                                        title: 'TRENDING',
                                        fontSize: 10,
                                        fontWeight: FontWeight.w800,
                                        color: AppColors.accent,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: (petition.voteCount / 100000).clamp(0.05, 1.0), // Goal 100k if threshold 50k
                                backgroundColor: Theme.of(context).dividerColor,
                                color: AppColors.accent,
                                minHeight: 8,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: _buildVoteCountStat(
                                    context,
                                    icon: Icons.thumb_up_alt_rounded,
                                    label: 'Support',
                                    count: petition.yesCount,
                                    color: Colors.green,
                                  ),
                                ),
                                Container(
                                  width: 1,
                                  height: 30,
                                  color: Theme.of(context).dividerColor,
                                  margin: const EdgeInsets.symmetric(horizontal: 12),
                                ),
                                Expanded(
                                  child: _buildVoteCountStat(
                                    context,
                                    icon: Icons.thumb_down_alt_rounded,
                                    label: 'Object',
                                    count: petition.noCount,
                                    color: AppColors.error,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      )
                    else
                      SizedBox.shrink(),
                      // Container(
                      //   padding: const EdgeInsets.all(16),
                      //   decoration: BoxDecoration(
                      //     color: AppColors.accent.withOpacity(0.05),
                      //     borderRadius: BorderRadius.circular(12),
                      //     border: Border.all(color: AppColors.accent.withOpacity(0.1)),
                      //   ),
                      //   child: Row(
                      //     children: [
                      //       const Icon(Icons.info_outline_rounded, size: 20, color: AppColors.accent),
                      //       const SizedBox(width: 12),
                      //       Expanded(
                      //         child: AppText(
                      //           title: 'Vote statistics will be visible after 50,000 votes.',
                      //           fontSize: 13,
                      //           fontWeight: FontWeight.w500,
                      //           color: AppColors.accent,
                      //         ),
                      //       ),
                      //     ],
                      //   ),
                      // ),

                    // const SizedBox(height: 24),

                    // Description
                    if (petition.description.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardColor,
                          borderRadius: BorderRadius.circular(12),
                          border: const Border(
                            left: BorderSide(color: AppColors.accent, width: 4),
                          ),
                        ),
                        child: AppText(
                          title: petition.description,
                          fontSize: 16 * controller.fontSizeFactor.value,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).colorScheme.onSurface,
                          height: 1.5,
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
                                    onTapUrl: (url) async {
                                      try {
                                        final uri = Uri.parse(url);
                                        await launchUrl(uri, mode: LaunchMode.platformDefault);
                                        return true;
                                      } catch (e) {
                                        debugPrint('Error launching URL: $e');
                                        return true;
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
                          textStyle: TextStyle(
                            fontSize: 16 * controller.fontSizeFactor.value,
                            height: 1.6,
                            color: Theme.of(context).colorScheme.onSurface,
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
                          borderRadius: 14,
                          fontSize: 15,
                          backgroundColor: AppColors.accent,
                          onPressed: () => _showVoteBottomSheet(context),
                        );
                      }

                      // Otherwise show Sign/Object
                        return Row(
                          children: [
                            Expanded(
                              child: AnimatedBorderButton(
                                text: AppStrings.signPetition,
                                height: 48,
                                borderRadius: 14,
                                fontSize: 15,
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
                                borderRadius: 14,
                                borderColor: Theme.of(context).dividerColor,
                                textColor: Theme.of(context).colorScheme.onSurface,
                                fontSize: 15,
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
                    
                    const SizedBox(height: 32),
                    
                    // Comments Section
                    _buildCommentsSection(context, petition),

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

  Widget _buildCommentsSection(BuildContext context, PetitionModel petition) {
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
            padding: const EdgeInsets.fromLTRB(0, 20, 0, 16),
            child: Row(
              children: [
                const Icon(Icons.comment_outlined, size: 20),
                const SizedBox(width: 8),
                const AppText(
                  title: 'Comments',
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
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
          crossFadeState: _commentsExpanded ? CrossFadeState.showFirst : CrossFadeState.showSecond,
          firstChild: Column(
            children: [
              // Comment Input Box (Simulated)
              Row(
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
                              style: TextStyle(fontSize: 14, color: Theme.of(context).colorScheme.onSurface),
                              decoration: InputDecoration(
                                hintText: 'Add a comment...',
                                hintStyle: TextStyle(fontSize: 13, color: AppColors.textHint),
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
                                decoration: BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
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
              const SizedBox(height: 20),
              // Dummy Comments
              _buildCommentItem(context, avatar: 'M', name: 'Manish Verma', time: '1 hour ago', text: 'Great initiative! Fully supporting this.', likes: 5),
              _buildCommentItem(context, avatar: 'S', name: 'Sonal Jha', time: '3 hours ago', text: 'This is much needed in our community.', likes: 2),
            ],
          ),
          secondChild: const SizedBox.shrink(),
        ),
      ],
    );
  }

  Widget _buildCommentItem(BuildContext context, {required String avatar, required String name, required String time, required String text, required int likes}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: AppColors.primary.withOpacity(0.1),
            child: AppText(title: avatar, fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    AppText(title: name, fontSize: 13, fontWeight: FontWeight.w700),
                    const Spacer(),
                    AppText(title: time, fontSize: 11, color: AppColors.textHint),
                  ],
                ),
                const SizedBox(height: 4),
                AppText(title: text, fontSize: 13, color: AppColors.textSecondary),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(Icons.thumb_up_alt_outlined, size: 12, color: AppColors.textHint),
                    const SizedBox(width: 4),
                    AppText(title: '$likes', fontSize: 12, color: AppColors.textHint),
                    const SizedBox(width: 16),
                    AppText(title: 'Reply', fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.primary),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showVoteBottomSheet(BuildContext context) {
    final commentController = TextEditingController();
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
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
                  borderSide: BorderSide(color: Theme.of(context).dividerColor),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Theme.of(context).dividerColor),
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

  Widget _buildVoteCountStat(
    BuildContext context, {
    required IconData icon,
    required String label,
    required int count,
    required Color color,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 14, color: color),
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppText(
              title: label,
              fontSize: 11,
              color: AppColors.textSecondary,
            ),
            AppText(
              title: _formatNumber(count),
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ],
        ),
      ],
    );
  }

  String _formatNumber(int number) {
    if (number >= 1000000) return '${(number / 1000000).toStringAsFixed(1)}M';
    if (number >= 1000) return '${(number / 1000).toStringAsFixed(1)}K';
    return number.toString();
  }

  Widget _buildLoadingShimmer() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Shimmer.fromColors(
            baseColor: Theme.of(context).dividerColor,
            highlightColor: Theme.of(context).cardColor,
            child: Container(height: 240, width: double.infinity, color: Theme.of(context).cardColor),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Shimmer.fromColors(
                  baseColor: Theme.of(context).dividerColor,
                  highlightColor: Theme.of(context).cardColor,
                  child: Container(height: 20, width: 100, color: Theme.of(context).cardColor),
                ),
                const SizedBox(height: 16),
                Shimmer.fromColors(
                  baseColor: Theme.of(context).dividerColor,
                  highlightColor: Theme.of(context).cardColor,
                  child: Container(height: 30, width: double.infinity, color: Theme.of(context).cardColor),
                ),
                const SizedBox(height: 8),
                Shimmer.fromColors(
                  baseColor: Theme.of(context).dividerColor,
                  highlightColor: Theme.of(context).cardColor,
                  child: Container(height: 30, width: 200, color: Theme.of(context).cardColor),
                ),
                const SizedBox(height: 24),
                Shimmer.fromColors(
                  baseColor: Theme.of(context).dividerColor,
                  highlightColor: Theme.of(context).cardColor,
                  child: Container(height: 200, width: double.infinity, color: Theme.of(context).cardColor),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
