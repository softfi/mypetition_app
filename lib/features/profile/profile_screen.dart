import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_petition_app/core/constants/app_assets.dart';
import 'package:my_petition_app/core/constants/app_colors.dart';
import 'package:my_petition_app/core/constants/app_strings.dart';
import 'package:my_petition_app/core/utils/custom_button.dart';
import 'package:my_petition_app/core/utils/custom_text.dart';
import 'package:my_petition_app/controllers/profile_controller.dart';
import 'package:my_petition_app/controllers/auth_controller.dart';
import 'package:my_petition_app/core/routes/app_routes.dart';
import 'edit_profile_screen.dart';
import 'my_petitions_screen.dart';
import 'saved_news_screen.dart';
import 'package:my_petition_app/controllers/theme_controller.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  static final _favItems = [
    (
      image: AppAssets.profileFav1,
      badge: 'SHORT NEWS',
      title: 'Joker becomes first R-rated movie to earn 1 billion worldwide',
    ),
    (
      image: AppAssets.profileFav2,
      badge: 'POLITICS',
      title: 'Iran War shock enough to turn political tide in India',
    ),
    (
      image: AppAssets.discoverPetition,
      badge: 'NATIONAL',
      title: 'Four state elections PM is compromised',
    ),
    (
      image: AppAssets.insightNews1,
      badge: 'TRENDING',
      title: 'Breaking: Historic summit changes global dynamics',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final ProfileController profileController = Get.find<ProfileController>();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        centerTitle: true,
        title: const AppText(
          title: 'My Profile',
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
      ),
      body: SafeArea(
        child: Obx(() {
          final authController = Get.find<AuthController>();
          if (authController.isGuest) {
            return _buildGuestProfile(context);
          }

          final user = profileController.currentUser;
          if (profileController.isProfileLoading && user == null) {
            return const Center(child: CircularProgressIndicator());
          }

          if (user == null) {
            return _buildErrorState(profileController);
          }

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),

                // Profile Header
                Center(child: _buildProfileHeader(user)),

                const SizedBox(height: 28),

                // ── Favourites Section ──
                // _buildSectionHeader(AppStrings.favourites),
                // const SizedBox(height: 12),
                // SizedBox(
                //   height: 190,
                //   child: ListView.separated(
                //     scrollDirection: Axis.horizontal,
                //     padding: const EdgeInsets.symmetric(horizontal: 20),
                //     itemCount: _favItems.length,
                //     separatorBuilder: (_, __) => const SizedBox(width: 10),
                //     itemBuilder: (context, index) {
                //       final item = _favItems[index];
                //       return _buildFavCard(item.image, item.badge, item.title);
                //     },
                //   ),
                // ),
                const SizedBox(height: 16),

                // ── File A Petition & Launch News Section ──
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    // _buildSectionHeader(context, AppStrings.fileAPetition),
                    // const SizedBox(height: 20),
                    // _buildStaticPlaceholder(
                    //   Icons.edit_document,
                    //   AppStrings.createYourOwnPetition,
                    // ),
                    //
                    // const SizedBox(height: 28),
                    //
                    // _buildSectionHeader(context, AppStrings.launchNews),
                    //     const SizedBox(height: 20),
                    //     _buildStaticPlaceholder(Icons.rocket_launch_outlined, AppStrings.launchYourNews),
                    //   ],
                    // ),
                    //
                    // const SizedBox(height: 32),

                    // ── Navigation Options List ──
                    _buildOptionItem(
                      icon: Icons.campaign_outlined,
                      title: 'File a Petition',
                      onTap: () => null,
                    ),

                    _buildOptionItem(
                      icon: Icons.newspaper_outlined,
                      title: 'Launch News',
                      onTap: () => null,
                    ),

                    _buildOptionItem(
                      icon: Icons.bookmark_add_outlined,
                      title: 'Saved News',
                      onTap: () => Get.to(() => const SavedNewsScreen()),
                    ),
                    /////////
                    _buildOptionItem(
                      icon: Icons.person_outline_rounded,
                      title: 'Edit Profile',
                      onTap: () => Get.to(() => const EditProfileScreen()),
                    ),
                    _buildOptionItem(
                      icon: Icons.description_outlined,
                      title: 'My Petitions',
                      onTap: () {
                        profileController.fetchUserPetitions(refresh: true);
                        Get.to(() => const MyPetitionsScreen());
                      },
                    ),
                    _buildOptionItem(
                      icon: Icons.gavel_outlined,
                      title: 'Terms & Conditions',
                      onTap: () {},
                    ),
                    _buildOptionItem(
                      icon: Icons.privacy_tip_outlined,
                      title: 'Privacy Policy',
                      onTap: () {},
                    ),
                    _buildOptionItem(
                      icon: Icons.info_outline_rounded,
                      title: 'About Us',
                      onTap: () {},
                    ),
                    _buildOptionItem(
                      icon: Icons.contact_support_outlined,
                      title: 'Contact Us',
                      onTap: () {},
                    ),

                    // Dark Mode Toggle (temporarily disabled)
                    // GetBuilder<ThemeController>(
                    //   init: ThemeController(),
                    //   builder: (themeController) {
                    //     final controller = themeController!;
                    //     return _buildOptionItem(
                    //       icon: controller.isDark
                    //           ? Icons.dark_mode_rounded
                    //           : Icons.light_mode_rounded,
                    //       title: 'Dark Mode',
                    //       trailing: _buildPremiumToggle(context, controller),
                    //       onTap: () => controller.switchTheme(),
                    //     );
                    //   },
                    // ),

                    const SizedBox(height: 20),

                    // Logout Button
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      child: CustomButton(
                        text: 'Logout',
                        backgroundColor: AppColors.error.withOpacity(0.15),
                        textColor: AppColors.error,
                        height: 50,
                        borderRadius: 12,
                        prefixIcon: Icons.logout_rounded,
                        onPressed: () =>
                            _showLogoutDialog(context, profileController),
                      ),
                    ),

                    const SizedBox(height: 10),
                    Center(
                      child: AppText(
                        title: "v 1.0.0",
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.grey400,
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildPremiumToggle(BuildContext context, ThemeController controller) {
    final bool isDark = controller.isDark;
    return GestureDetector(
      onTap: () => controller.switchTheme(),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: 54,
        height: 28,
        padding: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: isDark ? AppColors.primary.withOpacity(0.2) : AppColors.grey200,
          border: Border.all(
            color: isDark ? AppColors.primary.withOpacity(0.5) : AppColors.grey300,
            width: 1,
          ),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Track Icons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(Icons.wb_sunny_rounded, size: 12, color: !isDark ? AppColors.accent : Colors.transparent),
                Icon(Icons.nightlight_round, size: 12, color: isDark ? AppColors.primary : Colors.transparent),
              ],
            ),
            // Thumb
            AnimatedAlign(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOutBack,
              alignment: isDark ? Alignment.centerRight : Alignment.centerLeft,
              child: Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isDark ? AppColors.primary : Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(
                  isDark ? Icons.nightlight_round : Icons.wb_sunny_rounded,
                  size: 10,
                  color: isDark ? Colors.white : AppColors.accent,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(dynamic user) {
    String initials = "";
    if (user.name != null && user.name!.isNotEmpty) {
      List<String> names = user.name!.trim().split(RegExp(r'\s+'));
      if (names.length > 1) {
        initials = (names[0][0] + names[names.length - 1][0]).toUpperCase();
      } else if (names.isNotEmpty) {
        initials = names[0][0].toUpperCase();
      }
    }

    return Column(
      children: [
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            color: const Color(0xFF8B0000),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Center(
            child: AppText(
              title: initials.isEmpty ? 'U' : initials,
              fontSize: 36,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 16),
        AppText(
          title: user.name ?? 'User',
          fontSize: 22,
          fontWeight: FontWeight.w700,
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.phone_forwarded_outlined,
              size: 14,
              color: AppColors.textHint,
            ),
            SizedBox(width: 6),
            AppText(
              title: user.mobile ?? '',
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ],
        ),
        // AppText(title: "User ID: ${user.id}", fontSize: 12, color: AppColors.textHint),
      ],
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText(
            title: title,
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Theme.of(context).colorScheme.onSurface,
            decoration: TextDecoration.underline,
          ),
        ],
      ),
    );
  }

  Widget _buildStaticPlaceholder(IconData icon, String title) {
    return Center(
      child: Column(
        children: [
          Icon(icon, size: 36, color: AppColors.grey500),
          const SizedBox(height: 8),
          AppText(title: title, fontSize: 13, color: AppColors.textSecondary),
        ],
      ),
    );
  }

  Widget _buildOptionItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Widget? trailing,
  }) {
    return Builder(
      builder: (context) {
        return ListTile(
          onTap: onTap,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 2,
          ),
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Theme.of(context).brightness == Brightness.light
                  ? AppColors.grey100
                  : AppColors.cardBackgroundDark,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: Theme.of(context).colorScheme.onSurface,
              size: 20,
            ),
          ),
          title: AppText(
            title: title,
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
          trailing:
              trailing ??
              const Icon(
                Icons.arrow_forward_ios_rounded,
                color: AppColors.grey400,
                size: 14,
              ),
        );
      },
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
            Image.asset(imagePath, fit: BoxFit.cover),
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: [0.0, 0.4, 1.0],
                  colors: [
                    Colors.transparent,
                    Colors.transparent,
                    Colors.black87,
                  ],
                ),
              ),
            ),
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
                  ),
                ),
              ),
            ),
            Positioned(
              left: 6,
              right: 6,
              bottom: 8,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 4,
                    style: const TextStyle(
                      fontSize: 9,
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
                      child: const Icon(
                        Icons.play_arrow_rounded,
                        color: Colors.white,
                        size: 16,
                      ),
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

  Widget _buildErrorState(ProfileController controller) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 48, color: AppColors.error),
          const SizedBox(height: 16),
          const AppText(
            title: 'Failed to load profile',
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
          const SizedBox(height: 12),
          CustomButton(
            text: 'Retry',
            isFullWidth: false,
            onPressed: () => controller.fetchProfile(),
          ),
        ],
      ),
    );
  }

  Widget _buildGuestProfile(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.account_circle_outlined,
              size: 100,
              color: AppColors.grey400,
            ),
            const SizedBox(height: 24),
            const AppText(
              title: 'Welcome!',
              fontSize: 22,
              fontWeight: FontWeight.w700,
            ),
            const SizedBox(height: 40),
            CustomButton(
              text: 'Sign In / Register',
              onPressed: () => Get.offAllNamed(AppRoutes.login),
            ),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, ProfileController controller) {
    Get.dialog(
      Dialog(
        backgroundColor: Theme.of(context).cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: AppColors.error.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.logout_rounded,
                  color: AppColors.error,
                  size: 36,
                ),
              ),
              const SizedBox(height: 24),

              // Title
              AppText(
                title: 'Logout Confirmation',
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Theme.of(context).colorScheme.onSurface,
              ),
              const SizedBox(height: 12),

              // Message
              const AppText(
                title:
                    'Are you sure you want to log out? You will need to verify your OTP again to access your account.',
                fontSize: 13,
                fontWeight: FontWeight.w400,
                color: AppColors.textSecondary,
                textAlign: TextAlign.center,
                height: 1.5,
              ),
              const SizedBox(height: 32),

              // Buttons
              Row(
                children: [
                  Expanded(
                    child: CustomButton(
                      text: 'Cancel',
                      type: CustomButtonType.outlined,
                      height: 46,
                      borderRadius: 12,
                      borderColor: Theme.of(context).dividerColor,
                      textColor: Theme.of(context).colorScheme.onSurface,
                      onPressed: () => Get.back(),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: CustomButton(
                      text: 'Log Out',
                      height: 46,
                      borderRadius: 12,
                      backgroundColor: AppColors.error,
                      onPressed: () {
                        Get.back();
                        controller.logout();
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
