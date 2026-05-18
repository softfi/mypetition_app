import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:my_petition_app/core/constants/app_assets.dart';
import 'package:my_petition_app/core/constants/app_colors.dart';
import 'package:my_petition_app/core/constants/app_strings.dart';
import 'package:my_petition_app/core/constants/app_text_styles.dart';
import 'package:my_petition_app/core/routes/app_routes.dart';
import 'package:my_petition_app/core/utils/custom_button.dart';
import 'package:my_petition_app/core/utils/custom_text.dart';
import 'package:my_petition_app/controllers/discover_controller.dart';
import 'package:my_petition_app/core/utils/date_formatter.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:my_petition_app/core/models/news_model.dart';
import 'package:my_petition_app/core/models/insight_model.dart';
import 'package:my_petition_app/core/models/petition_model.dart';
import 'package:my_petition_app/core/models/category_model.dart';
import 'package:shimmer/shimmer.dart';
import 'package:my_petition_app/core/config/app_urls.dart';
import 'package:my_petition_app/controllers/auth_controller.dart';
import 'package:my_petition_app/controllers/profile_controller.dart';
import 'package:my_petition_app/core/utils/guest_dialog.dart';
import 'package:my_petition_app/core/utils/animated_border_button.dart';
import 'package:my_petition_app/core/utils/app_shimmer.dart';
import 'package:shimmer/shimmer.dart';

class DiscoverScreen extends GetView<DiscoverController> {
  const DiscoverScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            await controller.fetchNews();
            await controller.fetchInsights();
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      AppText(
                        title: AppStrings.create,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                      AppText(
                        title: AppStrings.discover,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                      AppText(
                        title: 'My Feed >',
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ],
                  ),
                ),

                // Search bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    height: 44,
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(color: Theme.of(context).dividerColor),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.search, color: AppColors.grey400, size: 20),
                        const SizedBox(width: 10),
                        AppText(
                          title: AppStrings.searchForNews,
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: AppColors.textHint,
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Category tabs
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildCategoryTab(context, Icons.dynamic_feed_outlined, AppStrings.myFeed, true),
                      _buildCategoryTab(context, Icons.add_box_outlined, AppStrings.petitions, false),
                      _buildCategoryTab(context, Icons.auto_stories_outlined, AppStrings.story, false),
                      _buildCategoryTab(context, Icons.trending_up, AppStrings.trending, false),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Petitions section header
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      AppText(
                        title: AppStrings.petitions,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                      GestureDetector(
                        onTap: () => Get.toNamed(AppRoutes.petitionsViewAll),
                        child: AppText(
                          title: AppStrings.viewAll,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.accent,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                // Petition card
                Obx(() {
                  if (controller.isPetitionsLoading.value && controller.petitionsList.isEmpty) {
                    return Shimmer.fromColors(
                    baseColor: Theme.of(context).brightness == Brightness.light ? AppColors.grey200 : Colors.grey[800]!,
                    highlightColor: Theme.of(context).brightness == Brightness.light ? AppColors.grey100 : Colors.grey[700]!,
                      child: Container(
                        height: 200,
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardColor,
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    );
                  }

                  if (controller.petitionsList.isEmpty) {
                    return const SizedBox.shrink();
                  }

                  final petition = controller.petitionsList.first;
                  return GestureDetector(
                    onTap: () => Get.toNamed(AppRoutes.petitionDetail, arguments: petition.slug),
                    child: _buildPetitionCard(context, petition),
                  );
                }),

                const SizedBox(height: 32),

                // Insights section header
                _buildSectionHeader(context, AppStrings.insights, () {
                  Get.toNamed(AppRoutes.insightsViewAll);
                }),

                const SizedBox(height: 16),

                // Insights horizontal list
                SizedBox(
                  height: 160,
                  child: Obx(() {
                    if (controller.isInsightsLoading.value && controller.insightsList.isEmpty) {
                      return _buildInsightShimmer(context);
                    }
                    if (controller.insightsList.isEmpty) {
                      return Center(
                        child: AppText(title: 'No insights available'),
                      );
                    }
                    return ListView.builder(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: controller.insightsList.length > 5 ? 5 : controller.insightsList.length,
                      itemBuilder: (context, index) {
                        final insight = controller.insightsList[index];
                        String? imageUrl;
                        if (insight.files.isNotEmpty) {
                          imageUrl = '${AppUrls.s3BaseUrl}${insight.files[0].s3ImageUrl}';
                        }
                        return Padding(
                          padding: const EdgeInsets.only(right: 12),
                          child: GestureDetector(
                            onTap: () => Get.toNamed(AppRoutes.insightReels, arguments: {'index': index, 'slug': insight.slug}),
                            child: _buildInsightImage(context, imageUrl, insight.title, insight.createdAt),
                          ),
                        );
                      },
                    );
                  }),
                ),

                const SizedBox(height: 32),

                // Latest News section header
                _buildSectionHeader(context, AppStrings.latestNews, () {
                  Get.toNamed(AppRoutes.newsViewAll);
                }),

                const SizedBox(height: 12),

                // Category Tabs for News
                SizedBox(
                  height: 40,
                  child: Obx(() {
                    // Access the value here to ensure Obx listens to changes
                    final selectedId = controller.selectedNewsCategoryId.value;
                    
                    return ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      physics: const BouncingScrollPhysics(),
                      itemCount: controller.categoriesList.length + 1,
                      itemBuilder: (context, index) {
                        final bool isAll = index == 0;
                        final category = isAll ? null : controller.categoriesList[index - 1];
                        final categoryId = isAll ? -1 : category!.id;
                        final isSelected = selectedId == categoryId;

                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: InkWell(
                            onTap: () => controller.setNewsCategory(categoryId),
                            borderRadius: BorderRadius.circular(20),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(
                                    color: isSelected ? AppColors.accent : Colors.transparent,
                                    width: 2,
                                  ),
                                ),
                              ),
                              child: AppText(
                                title: isAll ? 'All' : category!.name,
                                fontSize: 13,
                                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
                                color: isSelected ? AppColors.accent : Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  }),
                ),

                const SizedBox(height: 16),

                // News list items
                Obx(() {
                  if (controller.isNewsLoading.value && controller.newsList.isEmpty) {
                    return _buildNewsShimmer(context);
                  }
                  if (controller.newsList.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.all(20),
                      child: Center(
                        child: AppText(title: 'No news available'),
                      ),
                    );
                  }
                  return Column(
                    children: controller.newsList.asMap().entries.take(5).map((entry) {
                      final index = entry.key;
                      final news = entry.value;
                      return _buildNewsListItem(context, news, index);
                    }).toList(),
                  );
                }),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title, VoidCallback onViewAll) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppText(
                title: title,
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Theme.of(context).colorScheme.onSurface,
              ),
              const SizedBox(height: 4),
              Container(
                width: 32,
                height: 2,
                color: Theme.of(context).colorScheme.onSurface, // Underline effect
              ),
            ],
          ),
          GestureDetector(
            onTap: onViewAll,
            child: AppText(
              title: AppStrings.viewAll.toUpperCase(),
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: AppColors.accent,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryTab(BuildContext context, IconData icon, String label, bool isActive) {
    return Column(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: isActive ? AppColors.accent.withOpacity(0.1) : Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isActive ? AppColors.accent : Theme.of(context).dividerColor,
            ),
          ),
          child: Icon(
            icon,
            color: isActive ? AppColors.accent : AppColors.grey500,
            size: 24,
          ),
        ),
        const SizedBox(height: 6),
        AppText(
          title: label,
          fontSize: 11,
          fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
          color: isActive ? AppColors.accent : AppColors.grey500,
        ),
      ],
    );
  }

  Widget _buildPetitionCard(BuildContext context, PetitionModel petition) {
    final imageUrl = '${AppUrls.s3BaseUrl}${petition.s3ImageUrl}';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
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
          // Image
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: SizedBox(
              width: double.infinity,
              height: 160,
              child: CachedNetworkImage(
                imageUrl: imageUrl,
                fit: BoxFit.cover,
                placeholder: (context, url) => Shimmer.fromColors(
                  baseColor: Theme.of(context).brightness == Brightness.light ? AppColors.grey200 : Colors.grey[800]!,
                  highlightColor: Theme.of(context).brightness == Brightness.light ? AppColors.grey100 : Colors.grey[700]!,
                  child: Container(color: Theme.of(context).cardColor),
                ),
                errorWidget: (context, url, error) => Container(
                  color: Theme.of(context).dividerColor,
                  child: const Icon(Icons.image, size: 40, color: AppColors.grey400),
                ),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(
                  title: petition.title,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onSurface,
                  height: 1.4,
                  maxLines: 2,
                  textOverflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                AppText(
                  title: petition.description,
                  fontSize: 11,
                  fontWeight: FontWeight.w400,
                  color: AppColors.textHint,
                  height: 1.4,
                  maxLines: 2,
                  textOverflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 14),

                // Sign and Object buttons
                Obx(() {
                  final authController = Get.find<AuthController>();
                  final profileController = Get.find<ProfileController>();
                  final user = profileController.currentUser;
                  
                  // If verified, hide these buttons as per request
                  if (user != null && user.isEmailVerified) {
                    return const SizedBox.shrink();
                  }

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
                      const SizedBox(width: 10),
                      Expanded(
                        child: CustomButton(
                          text: AppStrings.objectPetition,
                          type: CustomButtonType.outlined,
                          height: 48,
                          borderRadius: 14,
                          borderColor: Theme.of(context).dividerColor,
                          textColor: Theme.of(context).colorScheme.onSurface,
                          fontSize: 15,
                          isFullWidth: true,
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

                // Progress indicator
                Row(
                  children: [
                    const Icon(Icons.how_to_vote, size: 14, color: AppColors.grey400),
                    const SizedBox(width: 6),
                    AppText(
                      title: '${petition.voteCount} total votes collected',
                      fontSize: 10,
                      fontWeight: FontWeight.w400,
                      color: AppColors.textHint,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInsightImage(BuildContext context, String? imageUrl, String title, DateTime date) {
    return Container(
      width: 110,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (imageUrl != null)
              CachedNetworkImage(
                imageUrl: imageUrl,
                fit: BoxFit.cover,
                placeholder: (context, url) => Shimmer.fromColors(
                  baseColor: Theme.of(context).brightness == Brightness.light ? AppColors.grey200 : Colors.grey[800]!,
                  highlightColor: Theme.of(context).brightness == Brightness.light ? AppColors.grey100 : Colors.grey[700]!,
                  child: Container(color: Theme.of(context).cardColor),
                ),
                errorWidget: (context, url, error) => const Icon(Icons.error),
              )
            else
              const Icon(Icons.image, color: AppColors.grey400),

            
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Colors.black.withOpacity(0.8),
                      Colors.transparent,
                    ],
                  ),
                ),
                child: AppText(
                  title: AppDateFormatter.formatShortDate(date),
                  fontSize: 9,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }



  Widget _buildNewsListItem(BuildContext context, NewsModel news, int index) {
    final imageUrl = '${AppUrls.s3BaseUrl}${news.s3ImageUrl}';
    return InkWell(
      onTap: () {
        Get.toNamed(AppRoutes.newsDetail, arguments: {'index': index, 'slug': news.slug});
      },





      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppText.title(
                        title: news.title,
                        maxLines: 2,
                        textOverflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Icon(Icons.access_time, size: 10),
                          const SizedBox(width: 4),
                          AppText(
                            title: AppDateFormatter.formatDateTime(news.createdAt),
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                          ),
                          const Spacer(),
                          // Bookmark Button
                          GestureDetector(
                            onTap: () => controller.toggleSaveNews(news),
                            child: Icon(
                              news.isSaved ? Icons.bookmark : Icons.bookmark_border,
                              color: news.isSaved ? AppColors.accent : AppColors.grey500,
                              size: 16,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                /// isme dekho image me dekho jo latest nes hai is row ke neeche tumhe categories api call krke show krni hai aise hi tabs form me aur inke click per jo news api hai use dekho filter query params me filte jayega jo maine diya hai to vo category ke cick pe risi me news list aani cahhiye ok api se ok ayr agar view all new me  me vha per category ko show krn ahi isi trahse aur flow bhi yahi rahega
                const SizedBox(width: 16),
                // Thumbnail
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: SizedBox(
                    width: 64,
                    height: 64,
                    child: CachedNetworkImage(
                      imageUrl: imageUrl,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Shimmer.fromColors(
                        baseColor: Theme.of(context).brightness == Brightness.light ? AppColors.grey200 : Colors.grey[800]!,
                        highlightColor: Theme.of(context).brightness == Brightness.light ? AppColors.grey100 : Colors.grey[700]!,
                        child: Container(color: Theme.of(context).cardColor),
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: Theme.of(context).dividerColor,
                        child: const Icon(Icons.image, size: 24, color: AppColors.grey400),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Divider(color: Theme.of(context).dividerColor, height: 1),
          ),
        ],
      ),
    );
  }

  Widget _buildInsightShimmer(BuildContext context) {
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: 5,
      itemBuilder: (context, index) => AppShimmer.fromColors(
        context: context,
        child: Container(
          width: 110,
          margin: const EdgeInsets.only(right: 12),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  Widget _buildNewsShimmer(BuildContext context) {
    return Column(
      children: List.generate(3, (index) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppShimmer.fromColors(
                    context: context,
                    child: Container(height: 12, color: Theme.of(context).cardColor),
                  ),
                  const SizedBox(height: 8),
                  AppShimmer.fromColors(
                    context: context,
                    child: Container(height: 12, width: 150, color: Theme.of(context).cardColor),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            AppShimmer.fromColors(
              context: context,
              child: Container(width: 64, height: 64, decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(8))),
            ),
          ],
        ),
      )),
    );
  }
}

