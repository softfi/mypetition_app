import 'package:flutter/material.dart';
import '../../../core/constants/app_assets.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../shared/widgets/custom_button.dart';
import 'package:my_petition_app/shared/widgets/custom_text.dart';

class DiscoverScreen extends StatelessWidget {
  const DiscoverScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      body: SafeArea(
        child: SingleChildScrollView(
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
                      color: AppColors.textPrimary,
                    ),
                    AppText(
                      title: AppStrings.discover,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                    AppText(
                      title: 'My Feed >',
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary,
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
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(color: AppColors.grey200),
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
                    _buildCategoryTab(Icons.dynamic_feed_outlined, AppStrings.myFeed, true),
                    _buildCategoryTab(Icons.add_box_outlined, AppStrings.petitions, false),
                    _buildCategoryTab(Icons.auto_stories_outlined, AppStrings.story, false),
                    _buildCategoryTab(Icons.trending_up, AppStrings.trending, false),
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
                      color: AppColors.textPrimary,
                    ),
                    AppText(
                      title: AppStrings.viewAll,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.accent,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // Petition card
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _buildPetitionCard(),
              ),

              const SizedBox(height: 32),

              // Insights section header
              _buildSectionHeader(AppStrings.insights),

              const SizedBox(height: 16),

              // Insights horizontal list
              SizedBox(
                height: 160,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: [
                    _buildInsightImage(AppAssets.insightNews1),
                    const SizedBox(width: 12),
                    _buildInsightImage(AppAssets.insightNews2),
                    const SizedBox(width: 12),
                    _buildInsightImage(AppAssets.homePetition), // Placeholder
                    const SizedBox(width: 12),
                    _buildInsightImage(AppAssets.discoverPetition), // Placeholder
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Latest News section header
              _buildSectionHeader(AppStrings.latestNews),

              const SizedBox(height: 12),

              // News list items
              _buildNewsListItem(
                  'Travis Scott punches sound engineer, causes ₹10 lakh worth of damage at New York club',
                  AppAssets.insightNews1),
              _buildNewsListItem(
                  'Travis Scott punches sound engineer, causes ₹10 lakh worth of damage at New York club',
                  AppAssets.insightNews2),
              _buildNewsListItem(
                  'Travis Scott punches sound engineer, causes ₹10 lakh worth of damage at New York club',
                  AppAssets.homePetition),

              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
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
                color: AppColors.textPrimary,
              ),
              const SizedBox(height: 4),
              Container(
                width: 32,
                height: 2,
                color: AppColors.textPrimary, // Underline effect
              ),
            ],
          ),
          AppText(
            title: AppStrings.viewAll.toUpperCase(),
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: AppColors.accent,
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryTab(IconData icon, String label, bool isActive) {
    return Column(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: isActive ? AppColors.accent.withValues(alpha: 0.1) : AppColors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isActive ? AppColors.accent : AppColors.grey200,
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

  Widget _buildPetitionCard() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
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
              child: Image.asset(
                AppAssets.discoverPetition,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: AppColors.grey200,
                    child: const Icon(Icons.image, size: 40, color: AppColors.grey400),
                  );
                },
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(
                  title: 'Travis Scott punches sound engineer, causes ₹10 lakh worth of damage at New York club',
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                  height: 1.4,
                ),
                const SizedBox(height: 8),
                AppText(
                  title: 'Lorem Ipsum is simply dummy text of the printing and typesetting industry\'s. Lorem55555 New...',
                  fontSize: 11,
                  fontWeight: FontWeight.w400,
                  color: AppColors.textHint,
                  height: 1.4,
                  maxLines: 2,
                  textOverflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 14),

                // Sign and Object buttons
                Row(
                  children: [
                    Expanded(
                      child: CustomButton(
                        text: AppStrings.signPetition,
                        height: 36,
                        borderRadius: 18,
                        backgroundColor: AppColors.accent,
                        fontSize: 12,
                        isFullWidth: true,
                        onPressed: () {},
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
                        isFullWidth: true,
                        onPressed: () {},
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Progress indicator
                Row(
                  children: [
                    const Icon(Icons.flag_outlined, size: 14, color: AppColors.grey400),
                    const SizedBox(width: 6),
                    AppText(
                      title: 'Add Your 100 ER Signature to reach The...',
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

  Widget _buildInsightImage(String imagePath) {
    return Container(
      width: 110,
      decoration: BoxDecoration(
        color: AppColors.grey200,
        borderRadius: BorderRadius.circular(12),
        image: DecorationImage(
          image: AssetImage(imagePath),
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildNewsListItem(String title, String imagePath) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: AppText(
                  title: title,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                  height: 1.4,
                  maxLines: 2,
                  textOverflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 16),
              // Thumbnail
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: SizedBox(
                  width: 56,
                  height: 56,
                  child: Image.asset(
                    imagePath,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: AppColors.grey200,
                        child: const Icon(Icons.image, size: 24, color: AppColors.grey400),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Divider(color: AppColors.grey200, height: 1),
        ),
      ],
    );
  }
}
