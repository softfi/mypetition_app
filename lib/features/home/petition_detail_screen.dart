import 'package:flutter/material.dart';
import 'package:my_petition_app/core/constants/app_assets.dart';
import 'package:my_petition_app/core/constants/app_colors.dart';
import 'package:my_petition_app/core/constants/app_strings.dart';
import 'package:my_petition_app/core/constants/app_text_styles.dart';
import 'package:my_petition_app/core/utils/custom_button.dart';
import 'package:my_petition_app/core/utils/custom_text.dart';
import 'package:my_petition_app/core/utils/custom_text_field.dart';

class PetitionDetailScreen extends StatefulWidget {
  const PetitionDetailScreen({super.key});

  @override
  State<PetitionDetailScreen> createState() => _PetitionDetailScreenState();
}

class _PetitionDetailScreenState extends State<PetitionDetailScreen> {
  bool _isCommentsExpanded = false;
  final _feedbackController = TextEditingController();

  @override
  void dispose() {
    _feedbackController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero image
            SizedBox(
              width: double.infinity,
              height: 260,
              child: Image.asset(
                AppAssets.homePetition,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: AppColors.grey200,
                    child: const Icon(Icons.image, size: 60, color: AppColors.grey400),
                  );
                },
              ),
            ),

            // Stats row
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              color: AppColors.grey100,
              child: Row(
                children: [
                  _buildStatBadge(Icons.visibility_outlined, '26.4K',
                      AppStrings.views, AppColors.primary),
                  const SizedBox(width: 16),
                  _buildStatBadge(Icons.mode_comment_outlined, '1,638',
                      AppStrings.comments, AppColors.accent),
                  const SizedBox(width: 16),
                  _buildStatBadge(
                      Icons.public, '', AppStrings.national, AppColors.grey600),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Petition title
                  AppText(
                    title: AppStrings.petitionTitle,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Theme.of(context).colorScheme.onSurface,
                    height: 1.3,
                  ),

                  const SizedBox(height: 16),

                  // To section
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AppText(
                              title: AppStrings.petitionTo,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: Theme.of(context).colorScheme.onSurface,
                              height: 1.4,
                            ),
                            const SizedBox(height: 4),
                            AppText(
                              title: AppStrings.petitionDate,
                              fontSize: 11,
                              fontWeight: FontWeight.w400,
                              color: AppColors.grey400,
                            ),
                          ],
                        ),
                      ),
                      // Share and save icons
                      Row(
                        children: [
                          IconButton(
                            onPressed: () {},
                            icon: const Icon(Icons.share_outlined,
                                size: 22, color: AppColors.grey500),
                            constraints: const BoxConstraints(),
                            padding: const EdgeInsets.all(8),
                          ),
                          IconButton(
                            onPressed: () {},
                            icon: const Icon(Icons.bookmark_border,
                                size: 22, color: AppColors.grey500),
                            constraints: const BoxConstraints(),
                            padding: const EdgeInsets.all(8),
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),
                  const Divider(color: AppColors.grey200),
                  const SizedBox(height: 2),

                  // ========== Comments Section (Expandable/Collapsible) ==========
                  _buildCommentsSection(),

                  const SizedBox(height: 2),
                  const Divider(color: AppColors.grey200),
                  const SizedBox(height: 16),

                  // ========== Petition Description (Text Content) ==========
                  _buildPetitionContent(),

                  const SizedBox(height: 16),
                  const Divider(color: AppColors.grey200),
                  const SizedBox(height: 16),

                  // ========== Share Section ==========
                  _buildShareSection(),

                  const SizedBox(height: 10),
                  const Divider(color: AppColors.grey200),
                  const SizedBox(height: 20),

                  // ========== Sign / Object Section ==========
                  _buildSignObjectSection(),

                  const SizedBox(height: 28),
                  const Divider(color: AppColors.grey200),
                  const SizedBox(height: 20),

                  // ========== Write Your Feedback Section ==========
                  _buildFeedbackSection(),

                  const SizedBox(height: 100),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Comments Section ────────────────────────────────────────────────────
  Widget _buildCommentsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header with expand/collapse toggle
        GestureDetector(
          onTap: () {
            setState(() {
              _isCommentsExpanded = !_isCommentsExpanded;
            });
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              AppText(
                title: '1,638 Comments',
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Theme.of(context).colorScheme.onSurface,
              ),
              AnimatedRotation(
                turns: _isCommentsExpanded ? 0.5 : 0.0,
                duration: const Duration(milliseconds: 300),
                child: const Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: AppColors.grey400,
                  size: 28,
                ),
              ),
            ],
          ),
        ),

        // Expandable comments list
        AnimatedCrossFade(
          firstChild: const SizedBox.shrink(),
          secondChild: Container(
            margin: const EdgeInsets.only(top: 16),
            constraints: const BoxConstraints(maxHeight: 400),
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: [
                  _buildComment(
                    'Divyanshu Gupta',
                    'DG',
                    AppColors.primary,
                    '2025 Report\'s - 800+ Suicides of Farmers.\n\nMaharashtra continues to suffer from the deepening agrarian crisis. In just the first six months of 2025, over 767 farmers in Marathwada alone have ended their lives–a 20% increase compared to the same period in 2024. Opposition reports further suggest that across the state, more than 850 suicides occurred between January and April 2025. This is not new. Year after year, Vidarbha and Marathwada remain epicenters.',
                    '2hr Ago',
                  ),
                  _buildComment(
                    'Mohit Sharma',
                    'MS',
                    AppColors.accent,
                    'Policy Need to Implement-\n\nMaharashtra continues to suffer from the deepening agrarian crisis. In just the first six months of 2025, over 767 farmers in Marathwada alone have ended their lives–a 20% increase compared to the same period in 2024. Opposition reports further suggest that across the state, more than 850 suicides occurred between January and April 2025. This is not new. Year after year, Vidarbha and Marathwada remain epicenters.',
                    '4hr Ago',
                  ),
                  _buildComment(
                    'Nitish Upadhyay',
                    'NU',
                    AppColors.grey600,
                    'The Indian Space Research Organisation (ISRO) on Friday successfully launched Chandrayaan-3, India\'s third Moon mission. It was launched by LVM3 from the Satish Dhawan Space Centre in Sriharikota.',
                    '6hr Ago',
                  ),
                ],
              ),
            ),
          ),
          crossFadeState: _isCommentsExpanded
              ? CrossFadeState.showSecond
              : CrossFadeState.showFirst,
          duration: const Duration(milliseconds: 300),
        ),
      ],
    );
  }

  // ─── Petition Content Section ────────────────────────────────────────────
  Widget _buildPetitionContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText(
          title: '2025 Report\'s - 800+ Suicides of Farmers.',
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: Theme.of(context).colorScheme.onSurface,
        ),
        const SizedBox(height: 8),
        AppText(
          title: 'Maharashtra continues to suffer from the deepening agrarian crisis. In just the first six months of 2025, over 767 farmers in Marathwada alone have ended their lives–a 20% increase compared to the same period in 2024. Opposition reports further suggest that across the state, more than 850 suicides occurred between January and April 2025. This is not new. Year after year, Vidarbha and Marathwada remain epicenters.',
          fontSize: 11,
          fontWeight: FontWeight.w400,
          color: AppColors.textSecondary,
          height: 1.5,
        ),
        const SizedBox(height: 20),
        AppText(
          title: 'Policy Need to Implement-',
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: Theme.of(context).colorScheme.onSurface,
        ),
        const SizedBox(height: 8),
        AppText(
          title: 'Maharashtra continues to suffer from the deepening agrarian crisis. In just the first six months of 2025, over 767 farmers in Marathwada alone have ended their lives–a 20% increase compared to the same period in 2024. Opposition reports further suggest that across the state, more than 850 suicides occurred between January and April 2025. This is not new. Year after year, Vidarbha and Marathwada remain epicenters.',
          fontSize: 11,
          fontWeight: FontWeight.w400,
          color: AppColors.textSecondary,
          height: 1.5,
        ),
      ],
    );
  }

  // ─── Share Section ───────────────────────────────────────────────────────

  Widget _buildShareSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        // const SizedBox(height: 14),
        Row(
          children: [
            AppText(
              title: 'Share :',
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: Theme.of(context).colorScheme.onSurface,
            ),
            const SizedBox(width: 10),
            _buildSocialIcon(Icons.facebook, const Color(0xFF1877F2)),
            const SizedBox(width: 10),
            _buildSocialIcon(Icons.camera_alt_outlined, const Color(0xFFE4405F)),
            const SizedBox(width: 10),
            _buildSocialIcon(Icons.alternate_email, const Color(0xFF1DA1F2)),
            const SizedBox(width: 10),
            _buildSocialCircleText('in', const Color(0xFF0A66C2)),
            const SizedBox(width: 10),
            _buildSocialIcon(Icons.close, Colors.black),
          ],
        ),
      ],
    );
  }

  Widget _buildSocialIcon(IconData icon, Color color) {
    return Container(
      width: 30,
      height: 30,
      margin: const EdgeInsets.only(right: 0),
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: AppColors.white, size: 20),
    );
  }

  Widget _buildSocialCircleText(String text, Color color) {
    return Container(
      width: 30,
      height: 30,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: AppText(
          title: text,
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: AppColors.white,
        ),
      ),
    );
  }

  // ─── Sign / Object Section ───────────────────────────────────────────────
  Widget _buildSignObjectSection() {
    return Column(
      children: [
        AppText(
          title: 'Are You Willing To Sign Petition?',
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: Theme.of(context).colorScheme.onSurface,
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: CustomButton(
                text: 'Sign',
                height: 40,
                borderRadius: 20,
                backgroundColor: AppColors.accent,
                fontSize: 13,
                isFullWidth: true,
                onPressed: () {},
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: CustomButton(
                text: 'Object',
                type: CustomButtonType.outlined,
                height: 40,
                borderRadius: 20,
                borderColor: Theme.of(context).dividerColor,
                textColor: Theme.of(context).colorScheme.onSurface,
                fontSize: 13,
                isFullWidth: true,
                onPressed: () {},
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ─── Feedback Section ────────────────────────────────────────────────────
  Widget _buildFeedbackSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText(
          title: 'Write Your Feedback?',
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: Theme.of(context).colorScheme.onSurface,
        ),
        const SizedBox(height: 14),
        CustomTextField(
          controller: _feedbackController,
          maxLines: 4,
          hint: 'Write Your Feedback Here By Describing Your Experience...',
        ),
        const SizedBox(height: 16),
        CustomButton(
          text: 'Post Comment',
          height: 42,
          borderRadius: 10,
          backgroundColor: AppColors.accent,
          fontSize: 13,
          isFullWidth: false,
          onPressed: () {
            // Post comment logic
            _feedbackController.clear();
          },
        ),
      ],
    );
  }

  // ─── Stat Badge ──────────────────────────────────────────────────────────
  Widget _buildStatBadge(
      IconData icon, String value, String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 14, color: color),
        ),
        const SizedBox(width: 6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (value.isNotEmpty)
              AppText(
                title: value,
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            AppText(
              title: label,
              fontSize: 10,
              fontWeight: FontWeight.w400,
              color: AppColors.grey500,
            ),
          ],
        ),
      ],
    );
  }

  // ─── Comment Item ────────────────────────────────────────────────────────
  Widget _buildComment(
      String name, String initials, Color avatarColor, String text, String time) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: avatarColor,
            child: AppText(
              title: initials,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.white,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    AppText(
                      title: name,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                    const SizedBox(width: 8),
                    AppText(
                      title: time,
                      fontSize: 10,
                      fontWeight: FontWeight.w400,
                      color: AppColors.textHint,
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                AppText(
                  title: text,
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
