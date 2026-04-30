import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_petition_app/controllers/discover_controller.dart';
import 'package:my_petition_app/core/constants/app_colors.dart';
import 'package:my_petition_app/core/utils/custom_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:my_petition_app/core/utils/date_formatter.dart';
import 'package:my_petition_app/core/config/app_urls.dart';
import 'package:my_petition_app/controllers/auth_controller.dart';
import 'package:my_petition_app/core/utils/guest_dialog.dart';
import 'package:my_petition_app/core/utils/custom_button.dart';
import 'package:shimmer/shimmer.dart';
import 'widgets/font_size_controls.dart';

class InsightDetailScreen extends StatefulWidget {
  const InsightDetailScreen({super.key});

  @override
  State<InsightDetailScreen> createState() => _InsightDetailScreenState();
}

class _InsightDetailScreenState extends State<InsightDetailScreen> {
  final controller = Get.find<DiscoverController>();
  late String slug;

  @override
  void initState() {
    super.initState();
    slug = Get.arguments as String;
    controller.fetchInsightDetail(slug);
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
        title: const AppText(
          title: 'Insight Details',
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
      floatingActionButton: const FontSizeControls(),
      body: Obx(() {
        if (controller.isInsightDetailLoading.value) {
          return _buildLoadingShimmer();
        }

        final insight = controller.selectedInsight.value;
        if (insight == null) {
          return const Center(child: AppText(title: 'Insight not found'));
        }

        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText.title(
                      title: insight.title,
                      fontSize: 20 * controller.fontSizeFactor.value,
                      height: 1.3,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Icon(Icons.access_time, size: 14, color: AppColors.textHint),
                        const SizedBox(width: 6),
                        AppText(
                          title: AppDateFormatter.formatDateTime(insight.createdAt),
                          fontSize: 12,
                          color: AppColors.textHint,
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const Divider(height: 1, color: AppColors.grey200),

              // Files/Images list
              if (insight.files.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(40),
                  child: Center(child: AppText(title: 'No media files available')),
                )
              else
              if (Get.find<AuthController>().isGuest)
                Stack(
                  alignment: Alignment.bottomCenter,
                  children: [
                    SizedBox(
                      height: 400,
                      child: ClipRect(
                        child: OverflowBox(
                          maxWidth: MediaQuery.of(context).size.width,
                          minHeight: 0,
                          maxHeight: double.infinity,
                          alignment: Alignment.topCenter,
                          child: ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: insight.files.length,
                            itemBuilder: (context, index) {
                              final file = insight.files[index];
                              final imageUrl = '${AppUrls.s3BaseUrl}${file.s3ImageUrl}';

                              return Padding(
                                padding: const EdgeInsets.symmetric(vertical: 8),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    CachedNetworkImage(
                                      imageUrl: imageUrl,
                                      width: double.infinity,
                                      fit: BoxFit.cover,
                                      placeholder: (context, url) => Shimmer.fromColors(
                                        baseColor: AppColors.grey200,
                                        highlightColor: AppColors.grey100,
                                        child: Container(height: 300, color: AppColors.white),
                                      ),
                                      errorWidget: (context, url, error) => Container(
                                        height: 200,
                                        color: AppColors.grey200,
                                        child: const Icon(Icons.image, size: 40, color: AppColors.grey400),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        height: 250,
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
                              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                              child: CustomButton(
                                text: 'View More Insights',
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
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: insight.files.length,
                  itemBuilder: (context, index) {
                    final file = insight.files[index];
                    final imageUrl = '${AppUrls.s3BaseUrl}${file.s3ImageUrl}';

                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CachedNetworkImage(
                            imageUrl: imageUrl,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Shimmer.fromColors(
                              baseColor: AppColors.grey200,
                              highlightColor: AppColors.grey100,
                              child: Container(height: 300, color: AppColors.white),
                            ),
                            errorWidget: (context, url, error) => Container(
                              height: 200,
                              color: AppColors.grey200,
                              child: const Icon(Icons.image, size: 40, color: AppColors.grey400),
                            ),
                          ),
                          const SizedBox(height: 8),
                        ],
                      ),
                    );
                  },
                ),
              
              const SizedBox(height: 80),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildLoadingShimmer() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Shimmer.fromColors(
                  baseColor: AppColors.grey200,
                  highlightColor: AppColors.grey100,
                  child: Container(height: 24, width: double.infinity, color: AppColors.white),
                ),
                const SizedBox(height: 8),
                Shimmer.fromColors(
                  baseColor: AppColors.grey200,
                  highlightColor: AppColors.grey100,
                  child: Container(height: 24, width: 200, color: AppColors.white),
                ),
                const SizedBox(height: 16),
                Shimmer.fromColors(
                  baseColor: AppColors.grey200,
                  highlightColor: AppColors.grey100,
                  child: Container(height: 16, width: 150, color: AppColors.white),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Shimmer.fromColors(
            baseColor: AppColors.grey200,
            highlightColor: AppColors.grey100,
            child: Container(height: 400, width: double.infinity, color: AppColors.white),
          ),
        ],
      ),
    );
  }
}
