import 'package:flutter/material.dart';
import 'package:my_petition_app/core/constants/app_assets.dart';
import 'package:my_petition_app/core/constants/app_colors.dart';
import 'package:my_petition_app/core/constants/app_strings.dart';
import 'package:my_petition_app/core/constants/app_text_styles.dart';
import 'package:my_petition_app/core/utils/custom_text.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Full-width petition image
            SizedBox(
              width: double.infinity,
              height: 300,
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

            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Author row
                  Row(
                    children: [
                      // Author avatar
                      CircleAvatar(
                        radius: 18,
                        backgroundColor: AppColors.grey300,
                        child: AppText(
                          title: 'DG',
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.grey700,
                        ),
                      ),
                      const SizedBox(width: 10),
                      // Author name
                      Expanded(
                        child: AppText(
                          title: 'Divyanshu Gupta',
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      // Time
                      AppText(
                        title: AppStrings.hrAgo,
                        fontSize: 11,
                        fontWeight: FontWeight.w400,
                        color: AppColors.grey400,
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Title
                  AppText(
                    title: 'Edinburgh pubs allowed to open late for all World Cup matches',
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                    height: 1.3,
                  ),

                  const SizedBox(height: 12),

                  // Description
                  AppText(
                    title: 'The Indian Space Research Organisation (ISRO) on Friday successfully launched Chandrayaan-3, India\'s third Moon mission. It was launched by LVM3 from the Satish Dhawan Space Centre in Sriharikota. The mission objectives of Chandrayaan-3 are to demonstrate safe and soft landing on lunar surface, to demonstrate rover roving on the moon and to conduct in-situ scientific experiments. The mission objectives of Chandrayaan-3 are to demonstrate safe and soft landing on lunar surface.',
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                    color: AppColors.textSecondary,
                    height: 1.6,
                  ),

                  const SizedBox(height: 24),

                  // Divider
                  const Divider(color: AppColors.grey200),

                  const SizedBox(height: 16),

                  // Stats row
                  Row(
                    children: [
                      _buildStatChip(Icons.visibility_outlined, '26.4K Views'),
                      const SizedBox(width: 16),
                      _buildStatChip(Icons.mode_comment_outlined, '1,638 Comments'),
                      const SizedBox(width: 16),
                      _buildStatChip(Icons.public, AppStrings.national),
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

  Widget _buildStatChip(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: AppColors.grey500),
        const SizedBox(width: 4),
        AppText(
          title: text,
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: AppColors.grey500,
        ),
      ],
    );
  }
}
