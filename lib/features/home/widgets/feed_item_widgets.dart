import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:my_petition_app/core/utils/share_helper.dart';
import 'package:shimmer/shimmer.dart';
import 'package:my_petition_app/core/constants/app_colors.dart';
import 'package:my_petition_app/core/constants/app_strings.dart';
import 'package:my_petition_app/core/utils/custom_text.dart';
import 'package:my_petition_app/core/utils/date_formatter.dart';
import 'package:my_petition_app/core/config/app_urls.dart';
import 'package:my_petition_app/core/models/news_model.dart';
import 'package:my_petition_app/core/models/insight_model.dart';
import 'package:my_petition_app/core/models/petition_model.dart';
import 'package:my_petition_app/core/routes/app_routes.dart';
import 'package:my_petition_app/controllers/auth_controller.dart';
import 'package:my_petition_app/controllers/profile_controller.dart';
import 'package:my_petition_app/core/utils/guest_dialog.dart';
import 'package:my_petition_app/core/utils/animated_sign_button.dart';
import 'package:my_petition_app/core/utils/custom_button.dart';
import 'package:my_petition_app/controllers/discover_controller.dart';
import 'package:my_petition_app/core/utils/app_shimmer.dart';
import 'dart:ui';

class NewsFeedItem extends StatelessWidget {
  final NewsModel news;
  const NewsFeedItem({super.key, required this.news});

  @override
  Widget build(BuildContext context) {
    final imageUrl = '${AppUrls.s3BaseUrl}${news.s3ImageUrl}';
    final screenHeight = MediaQuery.of(context).size.height;

    return GestureDetector(
      onTap: () {
        final discoverController = Get.find<DiscoverController>();
        if (!discoverController.newsList.any((e) => e.slug == news.slug)) {
          discoverController.newsList.insert(0, news);
        }
        final index = discoverController.newsList.indexWhere((e) => e.slug == news.slug);
        Get.toNamed(AppRoutes.newsDetail, arguments: {'index': index, 'slug': news.slug});
      },
      child: Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 10),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
          bottomLeft: Radius.zero,
          bottomRight: Radius.zero,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 42,
            child: Stack(
              fit: StackFit.expand,
              clipBehavior: Clip.none,
              children: [
                // Full Show Image
                CachedNetworkImage(
                  imageUrl: imageUrl,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => AppShimmer.fromColors(
                    context: context,
                    child: Container(color: Colors.white),
                  ),
                ),

                // Top Gradient for Icon Visibility
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.center,
                      colors: [
                        Colors.black.withOpacity(0.4),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),



                // Floating Chips (Logo and Actions)
                Positioned(
                  bottom: -16,
                  left: 12,
                  right: 12,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Logo Chip
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Image.asset(
                              'assets/images/logo.png',
                              height: 14,
                              errorBuilder: (c, e, s) => const Icon(
                                Icons.newspaper,
                                size: 14,
                                color: Colors.red,
                              ),
                            ),
                            const SizedBox(width: 6),
                            const AppText(
                              title: 'myPetition',
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: Colors.black87,
                            ),
                          ],
                        ),
                      ),

                      // Actions Chip
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onTap: () => Get.find<DiscoverController>()
                                  .toggleSaveNews(news),






                              child: Padding(
                                padding: const EdgeInsets.all(6.0),
                                child: Icon(
                                  news.isSaved
                                      ? Icons.bookmark
                                      : Icons.bookmark_border,
                                  color: news.isSaved
                                      ? AppColors.accent
                                      : Colors.black87,
                                  size: 18,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onTap: () {
                                ShareHelper.shareNews(
                                  title: news.title,
                                  url: '${AppUrls.webBaseUrl}/news/${news.slug}',
                                  description: news.description,
                                );
                              },
                              child: const Padding(
                                padding: EdgeInsets.all(6.0),
                                child: Icon(
                                  Icons.share_outlined,
                                  color: Colors.black87,
                                  size: 18,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Content Section
          Expanded(
            flex: 58,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 24), // Space for overlapping chips
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: AppText(
                    title: news.title,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Colors.black,
                    height: 1.25,
                    maxLines: 3,
                  ),
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: AppText(
                    title: news.description,
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: Colors.grey[700],
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: AppText(
                    title:
                        '${AppDateFormatter.formatDateTime(news.createdAt)} • MyPetition News',
                    fontSize: 11,
                    fontWeight: FontWeight.w400,
                    color: Colors.grey[500],
                  ),
                ),
                const Spacer(),
                // "Tap to read more" footer
                Container(
                  width: double.infinity,
                  height: 50,
                  decoration: const BoxDecoration(color: Color(0xFFF1F1F1)),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      const Icon(Icons.link, size: 18, color: Colors.blue),
                      const SizedBox(width: 8),
                      AppText(
                        title: 'Tap to read more at MyPetition',
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.blue[800],
                      ),
                      const Spacer(),
                      const Icon(
                        Icons.arrow_forward_ios,
                        size: 14,
                        color: Colors.grey,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ));
  }
}

class InsightFeedItem extends StatelessWidget {
  final InsightModel insight;
  const InsightFeedItem({super.key, required this.insight});

  @override
  Widget build(BuildContext context) {
    String? imageUrl;
    if (insight.files.isNotEmpty) {
      imageUrl = '${AppUrls.s3BaseUrl}${insight.files[0].s3ImageUrl}';
    }
    final screenHeight = MediaQuery.of(context).size.height;

    return GestureDetector(
      onTap: () {
        final discoverController = Get.find<DiscoverController>();
        if (!discoverController.insightsList.any((e) => e.slug == insight.slug)) {
          discoverController.insightsList.insert(0, insight);
        }
        final index = discoverController.insightsList.indexWhere((e) => e.slug == insight.slug);
        Get.toNamed(AppRoutes.insightReels, arguments: {'index': index, 'slug': insight.slug});
      },
      child: Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 10),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
          bottomLeft: Radius.zero,
          bottomRight: Radius.zero,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (imageUrl != null)
            CachedNetworkImage(
              imageUrl: imageUrl,
              fit: BoxFit.cover,
              placeholder: (context, url) => AppShimmer.fromColors(
                context: context,
                child: Container(color: Colors.white),
              ),
            ),

          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.4),
                  Colors.transparent,
                  Colors.black.withOpacity(0.9),
                ],
              ),
            ),
          ),

          Positioned(
            bottom: 60,
            left: 20,
            right: 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.accent,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const AppText(
                    title: 'INSIGHT STORY',
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),
                AppText(
                  title: insight.title,
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  height: 1.2,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(
                      Icons.remove_red_eye_outlined,
                      color: Colors.white70,
                      size: 14,
                    ),
                    const SizedBox(width: 6),
                    AppText(
                      title: 'Tap to view details',
                      fontSize: 12,
                      color: Colors.white.withOpacity(0.7),
                    ),
                  ],
                ),
              ],
            ),
          ),

          /* const Positioned(
              top: 60,
              right: 20,
              child: Icon(Icons.bolt, color: Colors.yellow, size: 32),
            ), */
        ],
      ),
    ));
  }
}

class PetitionFeedItem extends StatelessWidget {
  final PetitionModel petition;
  const PetitionFeedItem({super.key, required this.petition});

  @override
  Widget build(BuildContext context) {
    final imageUrl = '${AppUrls.s3BaseUrl}${petition.s3ImageUrl}';
    final screenHeight = MediaQuery.of(context).size.height;

    return GestureDetector(
      onTap: () => Get.toNamed(AppRoutes.petitionDetail, arguments: petition.slug),
      child: Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 10),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
          bottomLeft: Radius.zero,
          bottomRight: Radius.zero,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Top Image
          Expanded(
            flex: 42,
            child: Stack(
              fit: StackFit.expand,
              children: [
                CachedNetworkImage(
                  imageUrl: imageUrl,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => AppShimmer.fromColors(
                    context: context,
                    child: Container(color: Colors.white),
                  ),
                ),
                Positioned(
                  top: MediaQuery.of(context).padding.top + 10,
                  left: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const AppText(
                      title: 'LIVE PETITION',
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Content
          Expanded(
            flex: 58,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText(
                    title: petition.title,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: Colors.black,
                    height: 1.3,
                  ),
                  const SizedBox(height: 12),
                  AppText(
                    title: petition.description,
                    fontSize: 15,
                    fontWeight: FontWeight.w400,
                    color: Colors.grey[800],
                    height: 1.6,
                    maxLines: 8,
                    textOverflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 16),

                  // Sign Progress
                  Row(
                    children: [
                      const Icon(
                        Icons.people_alt_outlined,
                        size: 16,
                        color: AppColors.accent,
                      ),
                      const SizedBox(width: 8),
                      AppText(
                        title:
                            '${petition.voteCount} people signed this petition',
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.accent,
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Action Buttons
                  Obx(() {
                    final authController = Get.find<AuthController>();
                    final profileController = Get.find<ProfileController>();
                    final user = profileController.currentUser;

                    if (user != null && user.isEmailVerified) {
                      return CustomButton(
                        text: 'VOTE NOW',
                        height: 50,
                        borderRadius: 8,
                        onPressed: () => Get.toNamed(
                          AppRoutes.petitionDetail,
                          arguments: petition.slug,
                        ),
                      );
                    }

                    return Row(
                      children: [
                        Expanded(
                          child: AnimatedSignButton(
                            text: 'SIGN PETITION',
                            height: 50,
                            borderRadius: 8,
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
                            text: 'OBJECT',
                            type: CustomButtonType.outlined,
                            height: 50,
                            borderRadius: 8,
                            borderColor: Colors.grey[300],
                            textColor: Colors.black,
                            fontSize: 13,
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
                  const SizedBox(height: 10),
                ],
              ),
            ),
          ),
        ],
      ),
    ));
  }
}


