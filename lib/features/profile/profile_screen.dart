import 'package:flutter/material.dart';
import '../../../core/constants/app_assets.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../shared/widgets/custom_button.dart';
import 'package:my_petition_app/shared/widgets/custom_text.dart';
import 'edit_profile_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  static const _favItems = [
    (image: AppAssets.profileFav1,       badge: 'SHORT NEWS', title: 'Joker becomes first R-rated movie to earn \$1 billion worldwide'),
    (image: AppAssets.profileFav2,       badge: 'POLITICS',   title: 'Iran War shock enough to turn political tide in India'),
    (image: AppAssets.discoverPetition,  badge: 'NATIONAL',   title: 'Four state elections PM is compromised'),
    (image: AppAssets.insightNews1,      badge: 'TRENDING',   title: 'Breaking: Historic summit changes global dynamics'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 24),

              // Profile avatar
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  color: const Color(0xFF8B0000),
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.grey200, width: 3),
                ),
                child: Center(
                  child: AppText(
                    title: 'DG',
                    fontSize: 32,
                    fontWeight: FontWeight.w700,
                    color: AppColors.white,
                  ),
                ),
              ),

              const SizedBox(height: 14),

              // Name
              AppText(
                title: 'Divyanshu Gupta',
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),

              const SizedBox(height: 6),

              // Bio
              AppText(
                title: AppStrings.iDontReadNews,
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: AppColors.textSecondary,
              ),
              AppText(
                title: AppStrings.iConquerWords,
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: AppColors.textSecondary,
              ),

              const SizedBox(height: 14),

              // Edit Profile button
              CustomButton(
                text: AppStrings.editProfile,
                type: CustomButtonType.outlined,
                height: 32,
                borderRadius: 16,
                borderColor: AppColors.grey300,
                textColor: AppColors.textPrimary,
                fontSize: 12,
                fontWeight: FontWeight.w500,
                prefixIcon: Icons.edit,
                iconSize: 14,
                isFullWidth: false,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const EditProfileScreen()),
                  );
                },
              ),

              const SizedBox(height: 28),

              // ── Favourites ──
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: AppText(
                    title: AppStrings.favourites,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
              const SizedBox(height: 12),

              SizedBox(
                height: 190,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: _favItems.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 10),
                  itemBuilder: (context, index) {
                    final item = _favItems[index];
                    return _buildFavCard(item.image, item.badge, item.title);
                  },
                ),
              ),

              const SizedBox(height: 28),

              // ── File A Petition ──
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText(
                      title: AppStrings.fileAPetition,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                      decoration: TextDecoration.underline,
                    ),
                    const SizedBox(height: 20),
                    Center(
                      child: Column(
                        children: [
                          Icon(Icons.edit_document, size: 36, color: AppColors.grey500),
                          const SizedBox(height: 8),
                          AppText(
                            title: AppStrings.createYourOwnPetition,
                            fontSize: 13,
                            fontWeight: FontWeight.w400,
                            color: AppColors.textSecondary,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 28),

                    // ── Launch News ──
                    AppText(
                      title: AppStrings.launchNews,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                      decoration: TextDecoration.underline,
                    ),
                    const SizedBox(height: 20),
                    Center(
                      child: Column(
                        children: [
                          Icon(Icons.rocket_launch_outlined, size: 36, color: AppColors.grey500),
                          const SizedBox(height: 8),
                          AppText(
                            title: AppStrings.launchYourNews,
                            fontSize: 13,
                            fontWeight: FontWeight.w400,
                            color: AppColors.textSecondary,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFavCard(String imagePath, String badge, String title) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(
        width: 115,
        height: 190,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Background image
            Image.asset(
              imagePath,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                color: AppColors.grey300,
                child: const Icon(Icons.image, color: AppColors.grey500, size: 36),
              ),
            ),

            // Bottom gradient overlay
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: [0.0, 0.4, 1.0],
                  colors: [Colors.transparent, Colors.transparent, Colors.black87],
                ),
              ),
            ),

            // Top badge
            Positioned(
              top: 8,
              left: 6,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.accent,
                  borderRadius: BorderRadius.circular(3),
                ),
                child: Text(
                  badge,
                  style: const TextStyle(
                    fontSize: 7,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
            ),

            // Bottom: title + play button
            Positioned(
              left: 6,
              right: 6,
              bottom: 8,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    maxLines: 4,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Container(
                      width: 22,
                      height: 22,
                      decoration: const BoxDecoration(
                        color: AppColors.accent,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 16),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
