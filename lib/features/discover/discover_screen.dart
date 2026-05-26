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
import 'package:my_petition_app/core/utils/share_helper.dart';
import 'package:my_petition_app/features/navigation/main_shell.dart';

class DiscoverScreen extends GetView<DiscoverController> {
  const DiscoverScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            await controller.refreshAll();
          },
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                // Dynamic Premium Header
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AppText(
                            title: _getGreeting(),
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            color: Theme.of(context).colorScheme.onSurface,
                            letterSpacing: -0.5,
                          ),
                          const SizedBox(height: 4),
                          AppText(
                            title: DateFormat('EEEE, d MMMM').format(DateTime.now()),
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textHint,
                          ),
                        ],
                      ),
                      GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () {
                          context.findAncestorStateOfType<MainShellState>()?.switchTab(2);
                        },
                        child: Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Theme.of(context).brightness == Brightness.light ? AppColors.grey100 : const Color(0xFF1A1A1A),
                            border: Border.all(
                              color: Theme.of(context).dividerColor.withOpacity(0.5),
                            ),
                          ),
                          child: Center(
                            child: Icon(
                              Icons.dynamic_feed_rounded,
                              size: 20,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),





              

              // Sticky Search Bar
              SliverPersistentHeader(
                pinned: true,
                delegate: _StickySearchBarDelegate(
                  child: Container(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    padding: const EdgeInsets.only(bottom: 12),
                    child: GestureDetector(
                      onTap: () => Get.toNamed(AppRoutes.search),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          height: 52,
                          decoration: BoxDecoration(
                            color: Theme.of(context).brightness == Brightness.light
                                ? AppColors.grey100
                                : const Color(0xFF1A1A1A),
                            borderRadius: BorderRadius.circular(26), // Perfect pill shape
                            border: Border.all(
                              color: Theme.of(context).dividerColor.withOpacity(0.4),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.search_rounded,
                                color: Theme.of(context).brightness == Brightness.light
                                    ? AppColors.grey500
                                    : AppColors.grey400,
                                size: 22,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: AppText(
                                  title: 'Search news, petitions, stories...',
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: Theme.of(context).brightness == Brightness.light
                                      ? AppColors.grey500
                                      : AppColors.grey400,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).brightness == Brightness.light
                                      ? Colors.white
                                      : const Color(0xFF2A2A2A),
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.04),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  Icons.tune_rounded,
                                  color: Theme.of(context).colorScheme.onSurface,
                                  size: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 12),

                // Category tabs
                // Padding(
                //   padding: const EdgeInsets.symmetric(horizontal: 16),
                //   child: Row(
                //     mainAxisAlignment: MainAxisAlignment.spaceAround,
                //     children: [
                //       _buildCategoryTab(context, Icons.dynamic_feed_outlined, AppStrings.myFeed, true),
                //       _buildCategoryTab(context, Icons.add_box_outlined, AppStrings.petitions, false),
                //       _buildCategoryTab(context, Icons.auto_stories_outlined, AppStrings.story, false),
                //       _buildCategoryTab(context, Icons.trending_up, AppStrings.trending, false),
                //     ],
                //   ),
                // ),
                //
                // const SizedBox(height: 24),

                // Petitions section block
                Obx(() {
                  if (controller.isPetitionsLoading.value && controller.petitionsList.isEmpty) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionHeader(context, AppStrings.petitions, () {
                          Get.toNamed(AppRoutes.petitionsViewAll);
                        }),
                        const SizedBox(height: 12),
                        Shimmer.fromColors(
                          baseColor: Theme.of(context).brightness == Brightness.light ? AppColors.grey200 : Colors.grey[800]!,
                          highlightColor: Theme.of(context).brightness == Brightness.light ? AppColors.grey100 : Colors.grey[700]!,
                          child: Container(
                            height: 200,
                            margin: const EdgeInsets.symmetric(horizontal: 16),
                            decoration: BoxDecoration(
                              color: Theme.of(context).cardColor,
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),
                      ],
                    );
                  }



                  if (controller.petitionsList.isEmpty) {
                    return const SizedBox.shrink();
                  }




                  


                  final petition = controller.petitionsList.first;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionHeader(context, AppStrings.petitions, () {
                        Get.toNamed(AppRoutes.petitionsViewAll);
                      }),
                      const SizedBox(height: 12),
                      GestureDetector(
                        onTap: () => Get.toNamed(AppRoutes.petitionDetail, arguments: petition.slug),
                        child: _buildPetitionCard(context, petition),
                      ),
                      const SizedBox(height: 32),
                    ],
                  );
                }),


                // Stories (Insights) section block
                Obx(() {
                  if (controller.isInsightsLoading.value && controller.insightsList.isEmpty) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionHeader(context, AppStrings.insights, () {
                          Get.toNamed(AppRoutes.insightsViewAll);
                        }),
                        const SizedBox(height: 16),
                        SizedBox(
                          height: 220,
                          child: _buildInsightShimmer(context),
                        ),
                        const SizedBox(height: 32),
                      ],
                    );
                  }

                  if (controller.insightsList.isEmpty) {
                    return const SizedBox.shrink();
                  }

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionHeader(context, AppStrings.insights, () {
                        Get.toNamed(AppRoutes.insightsViewAll);
                      }),
                      const SizedBox(height: 16),
                      SizedBox(
                        height: 220,
                        child: ListView.builder(
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
                        ),
                      ),
                      const SizedBox(height: 32),
                    ],
                  );
                }),

                // Topics Header and Slider
                Obx(() {
                  if (controller.categoriesList.isEmpty) {
                    return const SizedBox.shrink();
                  }
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionHeader(context, 'Latest News', () {
                        Get.toNamed(AppRoutes.newsViewAll);
                      }),
                      const SizedBox(height: 12),
                      CategorySliderWidget(
                        categories: [
                          CategoryModel(
                            id: -1,
                            name: 'All',
                            slug: 'all',
                            isActive: true,
                            createdAt: DateTime.now(),
                            updatedAt: DateTime.now(),
                          ),
                          ...controller.categoriesList
                        ],
                        selectedCategoryId: controller.selectedNewsCategoryId.value,
                        onCategorySelected: (id) => controller.setNewsCategory(id),
                      ),
                      const SizedBox(height: 16),
                    ],
                  );
                }),

                // Latest News Items
                Obx(() {
                  if (controller.isNewsLoading.value) {
                    return Column(
                      children: [
                        _buildNewsShimmer(context),
                        const SizedBox(height: 20),
                      ],
                    );
                  }

                  if (controller.newsList.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                      child: Center(
                        child: AppText(
                          title: 'No news found for this topic.',
                          color: AppColors.grey500,
                        ),
                      ),
                    );
                  }

                  return Column(
                    children: [
                      ...controller.newsList.asMap().entries.take(5).map((entry) {
                        final index = entry.key;
                        final news = entry.value;
                        return _buildNewsListItem(context, news, index);
                      }).toList(),
                      const SizedBox(height: 20),
                    ],
                  );
                }),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
        ),
      ),
    );
  }

  String _getGreeting() {
    var hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good Morning';
    } else if (hour < 17) {
      return 'Good Afternoon';
    }
    return 'Good Evening';
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
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image with Badge
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                child: SizedBox(
                  width: double.infinity,
                  height: 180,
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
              // Category Badge
              // if (petition.category != null)
              //   Positioned(
              //     top: 14,
              //     left: 14,
              //     child: Container(
              //       padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              //       decoration: BoxDecoration(
              //         color: AppColors.accent,
              //         borderRadius: BorderRadius.circular(20),
              //         boxShadow: [
              //           BoxShadow(
              //             color: Colors.black.withOpacity(0.2),
              //             blurRadius: 4,
              //             offset: const Offset(0, 2),
              //           ),
              //         ],
              //       ),
              //       child: AppText(
              //         title: petition.category!.name.toUpperCase(),
              //         fontSize: 10,
              //         fontWeight: FontWeight.w800,
              //         color: Colors.white,
              //         letterSpacing: 0.5,
              //       ),
              //     ),
              //   ),
            ],
          ),

          Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(
                  title: petition.title,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Theme.of(context).colorScheme.onSurface,
                  height: 1.3,
                  maxLines: 2,
                  textOverflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                AppText(
                  title: petition.description,
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                  color: AppColors.textHint,
                  height: 1.4,
                  maxLines: 2,
                  textOverflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 18),

                // Progress / Date Row
                Row(
                  children: [
                    if (petition.voteCount >= 50000) ...[
                      const Icon(Icons.how_to_vote_rounded, size: 16, color: AppColors.accent),
                      const SizedBox(width: 6),
                      AppText(
                        title: '${petition.voteCount} signatures',
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.accent,
                      ),
                      const Spacer(),
                    ] else ...[
                      const Icon(Icons.calendar_today_rounded, size: 14, color: AppColors.grey500),
                      const SizedBox(width: 6),
                    ],
                    AppText(
                      title: AppDateFormatter.formatDateTime(petition.createdAt),
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: AppColors.grey500,
                    ),
                  ],
                ),

                // Sign Button
                Obx(() {
                  final authController = Get.find<AuthController>();
                  final profileController = Get.find<ProfileController>();
                  final user = profileController.currentUser;
                  
                  // If verified, hide these buttons as per request
                  if (user != null && user.isEmailVerified) {
                    return const SizedBox.shrink();
                  }

                  return Padding(
                    padding: const EdgeInsets.only(top: 18),
                    child: AnimatedSaffronGreenButton(
                      text: 'Sign a Petition',
                      onPressed: () {
                        if (authController.isGuest) {
                          GuestDialog.showLoginPrompt();
                        } else {
                          Get.toNamed(AppRoutes.emailVerify);
                        }
                      },
                    ),
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInsightImage(BuildContext context, String? imageUrl, String title, DateTime date) {
    return Container(
      width: 160,
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
                          /*
                          const Icon(Icons.access_time, size: 10),
                          const SizedBox(width: 4),
                          AppText(
                            title: AppDateFormatter.formatDateTime(news.createdAt),
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                          ),
                          const Spacer(),
                          */
                          // Bookmark Button
                          GestureDetector(
                            onTap: () => controller.toggleSaveNews(news),
                            child: Icon(
                              news.isSaved ? Icons.bookmark : Icons.bookmark_border,
                              color: news.isSaved ? AppColors.accent : AppColors.grey500,
                              size: 16,
                            ),
                          ),
                          const SizedBox(width: 12),
                          // Share Button
                          GestureDetector(
                            onTap: () {
                              ShareHelper.shareNews(
                                title: news.title,
                                url: '${AppUrls.webBaseUrl}/news/${news.slug}',
                                description: news.description,
                              );
                            },
                            child: const Icon(
                              Icons.share_outlined,
                              color: AppColors.grey500,
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
          width: 160,
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

class AnimatedSaffronGreenButton extends StatefulWidget {
  final String text;
  final VoidCallback onPressed;
  final double height;
  final double borderRadius;
  final double fontSize;

  const AnimatedSaffronGreenButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.height = 48,
    this.borderRadius = 14,
    this.fontSize = 15,
  });

  @override
  State<AnimatedSaffronGreenButton> createState() => _AnimatedSaffronGreenButtonState();
}

class _AnimatedSaffronGreenButtonState extends State<AnimatedSaffronGreenButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const saffron = Color(0xFFFF9933);
    const green = Color(0xFF138808);

    return GestureDetector(
      onTap: widget.onPressed,
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          final glowOffset = _animation.value * 4 + 2;
          
          return Container(
            height: widget.height,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(widget.borderRadius),
              boxShadow: [
                BoxShadow(
                  color: saffron.withOpacity(0.3 * (1 - _animation.value)),
                  blurRadius: glowOffset,
                  spreadRadius: _animation.value * 2,
                  offset: const Offset(-2, 2),
                ),
                BoxShadow(
                  color: green.withOpacity(0.3 * _animation.value),
                  blurRadius: glowOffset,
                  spreadRadius: _animation.value * 2,
                  offset: const Offset(2, 2),
                ),
              ],
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: const [
                  saffron,
                  Color(0xFFFFAE59),
                  Color(0xFF38A129),
                  green,
                ],
                stops: [
                  0.0,
                  _animation.value * 0.4,
                  0.6 + (1 - _animation.value) * 0.4,
                  1.0,
                ],
              ),
            ),
            child: Center(
              child: AppText(
                title: widget.text,
                fontSize: widget.fontSize,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                letterSpacing: 0.5,
              ),
            ),
          );
        },
      ),
    );
  }
}

class CategorySliderWidget extends StatefulWidget {
  final List<CategoryModel> categories;
  final int selectedCategoryId;
  final Function(int) onCategorySelected;

  const CategorySliderWidget({
    Key? key,
    required this.categories,
    required this.selectedCategoryId,
    required this.onCategorySelected,
  }) : super(key: key);

  @override
  State<CategorySliderWidget> createState() => _CategorySliderWidgetState();
}

class _CategorySliderWidgetState extends State<CategorySliderWidget> {
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    int initialIndex = widget.categories.indexWhere((c) => c.id == widget.selectedCategoryId);
    if (initialIndex == -1) initialIndex = 0;

    _pageController = PageController(viewportFraction: 0.28, initialPage: initialIndex);
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.selectedCategoryId == -1 && widget.categories.isNotEmpty) {
        widget.onCategorySelected(widget.categories[initialIndex].id);
      }
    });
  }

  @override
  void didUpdateWidget(covariant CategorySliderWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedCategoryId != widget.selectedCategoryId) {
      int index = widget.categories.indexWhere((c) => c.id == widget.selectedCategoryId);
      if (index != -1 && _pageController.hasClients) {
        if (_pageController.page?.round() != index) {
          _pageController.animateToPage(
            index,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        }
      }
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.categories.isEmpty) return const SizedBox.shrink();

    return Stack(
      alignment: Alignment.center,
      children: [
        // Fixed selection indicator in the center
        Positioned(
          bottom: 0,
          child: Container(
            width: 40,
            height: 3,
            decoration: BoxDecoration(
              color: AppColors.accent,
              borderRadius: BorderRadius.circular(1.5),
            ),
          ),
        ),
        
        SizedBox(
          height: 110,
          child: PageView.builder(
            controller: _pageController,
            physics: const BouncingScrollPhysics(),
            onPageChanged: (index) {
              widget.onCategorySelected(widget.categories[index].id);
            },
            itemCount: widget.categories.length,
            itemBuilder: (context, index) {
              final category = widget.categories[index];
              final isSelected = category.id == widget.selectedCategoryId;

              return GestureDetector(
                onTap: () {
                  widget.onCategorySelected(category.id);
                  if (_pageController.hasClients) {
                    _pageController.animateToPage(
                      index,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  }
                },
                child: Container(
                  alignment: Alignment.bottomCenter,
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AnimatedOpacity(
                        duration: const Duration(milliseconds: 300),
                        opacity: isSelected ? 1.0 : 0.4,
                        child: AnimatedScale(
                          scale: isSelected ? 1.15 : 0.85,
                          duration: const Duration(milliseconds: 300),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              width: 56,
                              height: 56,
                              color: Theme.of(context).cardColor,
                              child: category.id == -1
                                  ? const Icon(Icons.grid_view_rounded, color: AppColors.grey400)
                                  : category.s3IconUrl != null
                                      ? CachedNetworkImage(
                                          imageUrl: '${AppUrls.s3BaseUrl}${category.s3IconUrl}',
                                          fit: BoxFit.cover,
                                          placeholder: (context, url) => Container(color: AppColors.grey200),
                                          errorWidget: (context, url, error) => const Icon(Icons.image, color: AppColors.grey400),
                                        )
                                      : const Icon(Icons.category, color: AppColors.grey400),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Flexible(
                        child: AppText(
                          title: category.name,
                          fontSize: isSelected ? 12 : 11,
                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                          color: isSelected ? AppColors.accent : Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _StickySearchBarDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;

  _StickySearchBarDelegate({required this.child});

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return child;
  }

  @override
  double get maxExtent => 64.0; // 52 search bar + 12 bottom padding

  @override
  double get minExtent => 64.0;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    return true;
  }
}
