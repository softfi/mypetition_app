import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import 'package:my_petition_app/controllers/search_controller.dart' as app_search;
import 'package:my_petition_app/controllers/home_controller.dart';
import 'package:my_petition_app/controllers/discover_controller.dart';
import 'package:my_petition_app/core/constants/app_colors.dart';
import 'package:my_petition_app/core/models/search_result_model.dart';
import 'package:my_petition_app/core/models/feed_model.dart';
import 'package:my_petition_app/core/models/news_model.dart';
import 'package:my_petition_app/core/models/insight_model.dart';
import 'package:my_petition_app/core/models/petition_model.dart';
import 'package:my_petition_app/core/routes/app_routes.dart';
import 'package:my_petition_app/core/utils/custom_text.dart';
import 'package:my_petition_app/core/utils/date_formatter.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  late final app_search.AppSearchController controller;
  final TextEditingController _textCtrl = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    // Always recreate controller fresh so previous search state is wiped
    Get.delete<app_search.AppSearchController>(force: true);
    controller = Get.put(app_search.AppSearchController());
    _textCtrl.clear();

    // Defer feed refresh + focus to post-frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Get.find<HomeController>().fetchFeed();
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _textCtrl.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final onSurface = theme.colorScheme.onSurface;

    final isDark = theme.brightness == Brightness.dark;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: isDark
          ? SystemUiOverlayStyle.light.copyWith(
              statusBarColor: Colors.transparent,
              statusBarIconBrightness: Brightness.light,
            )
          : SystemUiOverlayStyle.dark.copyWith(
              statusBarColor: Colors.transparent,
              statusBarIconBrightness: Brightness.dark,
            ),
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(64),
        child: Container(
          decoration: BoxDecoration(
            color: theme.scaffoldBackgroundColor,
            border: Border(
              bottom: BorderSide(color: theme.dividerColor, width: 0.8),
            ),
          ),
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 16, 8),
              child: Row(
                children: [
                  // Back button
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(24),
                      onTap: () => Get.back(),
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: Icon(Icons.arrow_back_ios_new_rounded,
                            size: 20, color: onSurface),
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  // Search field
                  Expanded(
                    child: Container(
                      height: 44,
                      decoration: BoxDecoration(
                        color: theme.brightness == Brightness.light
                            ? const Color(0xFFF3F4F6)
                            : theme.cardColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const SizedBox(width: 14),
                          Expanded(
                            child: TextField(
                              controller: _textCtrl,
                              focusNode: _focusNode,
                              style: TextStyle(
                                fontSize: 14,
                                color: onSurface,
                                fontWeight: FontWeight.w500,
                              ),
                              decoration: InputDecoration(
                                hintText: 'Search news, petitions, stories…',
                                hintStyle: TextStyle(
                                  fontSize: 14,
                                  color: onSurface.withOpacity(0.38),
                                  fontWeight: FontWeight.w400,
                                ),
                                border: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                filled: true,
                                fillColor: Colors.transparent,
                                isDense: true,
                                contentPadding: EdgeInsets.zero,
                              ),
                              textInputAction: TextInputAction.search,
                              onChanged: controller.onQueryChanged,
                            ),
                          ),
                          Obx(() => AnimatedSwitcher(
                            duration: const Duration(milliseconds: 180),
                            child: controller.query.value.isNotEmpty
                                ? GestureDetector(
                                    key: const ValueKey('clear'),
                                    onTap: () {
                                      _textCtrl.clear();
                                      controller.clearSearch();
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 10),
                                      child: Container(
                                        width: 18,
                                        height: 18,
                                        decoration: BoxDecoration(
                                          color: AppColors.grey400.withOpacity(0.3),
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(Icons.close,
                                            size: 12, color: AppColors.grey500),
                                      ),
                                    ),
                                  )
                                : const SizedBox(key: ValueKey('empty'), width: 12),
                          )),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: SafeArea(
        top: false,
        bottom: true,
        child: Obx(() {
          // Idle — nothing typed yet
          if (controller.query.value.isEmpty) {
            return _buildIdle(context);
          }

          // Loading (debounce in-flight)
          if (controller.isLoading.value) {
            return _buildShimmer();
          }

          // Error
          if (controller.errorMsg.value.isNotEmpty && controller.results.isEmpty) {
            return _buildEmpty(
              icon: Icons.search_off_rounded,
              title: 'No results found',
              subtitle: 'Try different keywords',
            );
          }

          // Results
          return _buildResults(context);
        }),
      ),
    ),   // Scaffold
    );   // AnnotatedRegion
  }

  // ── Idle state — show feed ────────────────────────────────────────────────
  Widget _buildIdle(BuildContext context) {
    final homeCtrl = Get.find<HomeController>();
    return Obx(() {
      final feed = homeCtrl.feedList;

      if (homeCtrl.isLoading.value && feed.isEmpty) {
        return _buildShimmer();
      }

      if (feed.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.manage_search_rounded, size: 72,
                  color: AppColors.grey400.withOpacity(0.6)),
              const SizedBox(height: 16),
              const AppText(title: 'Search everything', fontSize: 18, fontWeight: FontWeight.w700),
              const SizedBox(height: 8),
              const AppText(title: 'News · Petitions · Stories', fontSize: 13, color: AppColors.grey500),
            ],
          ),
        );
      }

      final allResults = feed.map(_feedItemToSearchResult).whereType<SearchResult>().toList();

      // Split insights vs news/petitions
      final insights = allResults.where((r) => r.resultType == SearchResultType.insight).toList();
      final others   = allResults.where((r) => r.resultType != SearchResultType.insight).toList();

      return RefreshIndicator(
        onRefresh: () => homeCtrl.fetchFeed(isRefresh: true),
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.zero,
          children: [
            // ── Stories grid section ──────────────────────────────────
            if (insights.isNotEmpty) ...[
              _buildSectionLabel(context, Icons.lightbulb_outline, 'Stories', Colors.amber[700]!),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 4),
                child: GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 6,
                    mainAxisSpacing: 6,
                    childAspectRatio: 0.72, // portrait cell
                  ),
                  itemCount: insights.length,
                  itemBuilder: (context, index) =>
                      _buildInsightGridCell(context, insights[index]),
                ),
              ),
              Divider(height: 16, color: Theme.of(context).dividerColor),
            ],

            // ── Trending news/petitions ───────────────────────────────
            if (others.isNotEmpty) ...[
              _buildSectionLabel(context, Icons.trending_up_rounded, 'Trending', AppColors.primary),
              ...others.asMap().entries.map((e) {
                final isLast = e.key == others.length - 1;
                return Column(
                  children: [
                    _buildResultTile(context, e.value),
                    if (!isLast)
                      Divider(
                        height: 1, indent: 16, endIndent: 16,
                        color: Theme.of(context).dividerColor,
                      ),
                  ],
                );
              }),
            ],
          ],
        ),
      );
    });
  }

  Widget _buildSectionLabel(BuildContext context, IconData icon, String label, Color color) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
      child: Row(
        children: [
          Icon(icon, size: 15, color: color),
          const SizedBox(width: 6),
          AppText(title: label, fontSize: 13, fontWeight: FontWeight.w700, color: color),
        ],
      ),
    );
  }

  Widget _buildInsightGridCell(BuildContext context, SearchResult insight) {
    return GestureDetector(
      onTap: () => _navigate(insight),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Image only — no text overlay
            insight.imageUrl != null
                ? CachedNetworkImage(
                    imageUrl: insight.imageUrl!,
                    fit: BoxFit.cover,
                    placeholder: (_, __) => Container(color: Theme.of(context).dividerColor),
                    errorWidget: (_, __, ___) => Container(
                      color: Colors.amber.withOpacity(0.08),
                      child: const Icon(Icons.lightbulb_outline, color: Colors.amber, size: 28),
                    ),
                  )
                : Container(
                    color: Colors.amber.withOpacity(0.08),
                    child: const Icon(Icons.lightbulb_outline, color: Colors.amber, size: 28),
                  ),
          ],
        ),
      ),
    );
  }


  /// Convert a FeedItem to a SearchResult for display in the same tile layout
  SearchResult? _feedItemToSearchResult(FeedItem item) {
    try {
      if (item.feedType == 'news') {
        final n = item.data as NewsModel;
        return SearchResult(
          id: n.id, title: n.title, slug: n.slug, type: 'news',
          description: n.description, s3ImageUrl: n.s3ImageUrl,
          categoryName: n.category?.name,
          createdAt: n.createdAt,
        );
      } else if (item.feedType == 'insight') {
        final ins = item.data as InsightModel;
        return SearchResult(
          id: ins.id, title: ins.title, slug: ins.slug, type: 'insight',
          insightImageUrl: ins.files.isNotEmpty ? ins.files.first.s3ImageUrl : null,
          createdAt: ins.createdAt,
        );
      } else if (item.feedType == 'petition') {
        final p = item.data as PetitionModel;
        return SearchResult(
          id: p.id, title: p.title, slug: p.slug, type: 'petition',
          description: p.description, s3ImageUrl: p.s3ImageUrl,
          categoryName: p.category?.name,
          createdAt: p.createdAt,
        );
      }
    } catch (_) {}
    return null;
  }

  // ── Results list ────────────────────────────────────────────────────────────
  Widget _buildResults(BuildContext context) {
    final results = controller.results;

    if (results.isEmpty) {
      return _buildEmpty(
        icon: Icons.search_off_rounded,
        title: 'No results for "${controller.query.value}"',
        subtitle: 'Try a different keyword',
      );
    }

    // Split insights vs news/petitions — same layout as idle feed
    final insights = results.where((r) => r.resultType == SearchResultType.insight).toList();
    final others   = results.where((r) => r.resultType != SearchResultType.insight).toList();

    return ListView(
      padding: const EdgeInsets.only(bottom: 12),
      children: [
        // ── Stories grid ──────────────────────────────────────────────
        if (insights.isNotEmpty) ...[
          _buildSectionLabel(context, Icons.lightbulb_outline, 'Stories', Colors.amber[700]!),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 4),
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 6,
                mainAxisSpacing: 6,
                childAspectRatio: 0.72,
              ),
              itemCount: insights.length,
              itemBuilder: (context, index) =>
                  _buildInsightGridCell(context, insights[index]),
            ),
          ),
          if (others.isNotEmpty)
            Divider(height: 16, color: Theme.of(context).dividerColor),
        ],

        // ── News / Petition tiles ──────────────────────────────────────
        if (others.isNotEmpty) ...[
          _buildSectionLabel(context, Icons.search_rounded, 'Results', AppColors.primary),
          ...others.asMap().entries.map((e) {
            final isLast = e.key == others.length - 1;
            return Column(
              children: [
                _buildResultTile(context, e.value),
                if (!isLast)
                  Divider(
                    height: 1, indent: 16, endIndent: 16,
                    color: Theme.of(context).dividerColor,
                  ),
              ],
            );
          }),
        ],
      ],
    );
  }

  Widget _buildResultTile(BuildContext context, SearchResult result) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: () => _navigate(result),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thumbnail
            _buildThumbnail(context, result),
            const SizedBox(width: 12),
            // Text content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Type chip + category
                  Row(
                    children: [
                      _typeChip(result.resultType),
                      if (result.categoryName != null) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(
                            color: theme.dividerColor.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: AppText(
                            title: result.categoryName!,
                            fontSize: 9,
                            color: AppColors.grey500,
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 5),
                  // Title
                  AppText(
                    title: result.title,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    maxLines: 2,
                    height: 1.35,
                    color: theme.colorScheme.onSurface,
                  ),
                  // Description (news/petition only)
                  if (result.description != null &&
                      result.description!.isNotEmpty &&
                      result.resultType != SearchResultType.insight) ...[
                    const SizedBox(height: 4),
                    AppText(
                      title: result.description!,
                      fontSize: 11,
                      color: AppColors.grey500,
                      maxLines: 1,
                      height: 1.3,
                    ),
                  ],
                  const SizedBox(height: 5),
                  // Date
                  Row(
                    children: [
                      const Icon(Icons.calendar_today_outlined,
                          size: 10, color: AppColors.grey500),
                      const SizedBox(width: 4),
                      AppText(
                        title: AppDateFormatter.formatDate(result.createdAt),
                        fontSize: 10,
                        color: AppColors.grey500,
                      ),
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

  Widget _buildThumbnail(BuildContext context, SearchResult result) {
    final imageUrl = result.imageUrl;

    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: SizedBox(
        width: 72,
        height: 60,
        child: imageUrl != null
            ? CachedNetworkImage(
                imageUrl: imageUrl,
                fit: BoxFit.cover,
                placeholder: (_, __) => Container(
                    color: Theme.of(context).dividerColor),
                errorWidget: (_, __, ___) => _thumbnailFallback(result.resultType),
              )
            : _thumbnailFallback(result.resultType),
      ),
    );
  }

  Widget _thumbnailFallback(SearchResultType type) {
    IconData icon;
    Color color;
    switch (type) {
      case SearchResultType.petition:
        icon = Icons.campaign_outlined;
        color = AppColors.primary;
        break;
      case SearchResultType.insight:
        icon = Icons.lightbulb_outline;
        color = Colors.amber;
        break;
      default:
        icon = Icons.newspaper_outlined;
        color = AppColors.accent;
    }
    return Container(
      color: color.withOpacity(0.08),
      child: Icon(icon, size: 28, color: color.withOpacity(0.6)),
    );
  }

  Widget _typeChip(SearchResultType type) {
    String label;
    Color color;
    switch (type) {
      case SearchResultType.petition:
        label = 'PETITION';
        color = AppColors.primary;
        break;
      case SearchResultType.insight:
        label = 'STORY';
        color = Colors.amber[700]!;
        break;
      default:
        label = 'NEWS';
        color = AppColors.accent;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: AppText(
        title: label,
        fontSize: 9,
        fontWeight: FontWeight.w700,
        color: color,
      ),
    );
  }

  // ── Navigation ──────────────────────────────────────────────────────────────
  void _navigate(SearchResult result) {
    switch (result.resultType) {
      case SearchResultType.news:
        Get.toNamed(AppRoutes.newsDetail, arguments: {'slug': result.slug});
        break;
      case SearchResultType.petition:
        Get.toNamed(AppRoutes.petitionDetail, arguments: result.slug);
        break;
      case SearchResultType.insight:
        final discoverCtrl = Get.find<DiscoverController>();
        final homeCtrl = Get.find<HomeController>();

        // 1. Try to resolve a full InsightModel (from feed)
        InsightModel? ins;

        final feedItem = homeCtrl.feedList.firstWhereOrNull(
          (f) => f.feedType == 'insight' &&
              (f.data as InsightModel).slug == result.slug,
        );
        if (feedItem != null) {
          ins = feedItem.data as InsightModel;
        }

        // 2. Check if already in discoverCtrl list (from a previous discover load)
        ins ??= discoverCtrl.insightsList
            .firstWhereOrNull((e) => e.slug == result.slug);

        // 3. Build a minimal stub from search result data so we always have something
        ins ??= InsightModel(
          id: result.id,
          title: result.title,
          slug: result.slug,
          isActive: true,
          createdAt: result.createdAt,
          updatedAt: result.createdAt,
          files: result.insightImageUrl != null
              ? [
                  InsightFile(
                    id: 0,
                    insightId: result.id,
                    s3ImageUrl: result.insightImageUrl!,
                    isActive: true,
                    createdAt: result.createdAt,
                    updatedAt: result.createdAt,
                  ),
                ]
              : [],
          fileCount: result.insightImageUrl != null ? 1 : 0,
        );

        // 4. Ensure it's in discoverCtrl list and get correct index
        if (!discoverCtrl.insightsList.any((e) => e.slug == ins!.slug)) {
          discoverCtrl.insightsList.insert(0, ins);
        }
        final index = discoverCtrl.insightsList.indexWhere((e) => e.slug == ins!.slug);
        Get.toNamed(AppRoutes.insightReels,
            arguments: {'index': index, 'slug': ins.slug});
        break;
    }
  }

  // ── Shimmer loading ─────────────────────────────────────────────────────────
  Widget _buildShimmer() {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 12),
      itemCount: 6,
      separatorBuilder: (_, __) => const Divider(height: 1, indent: 16, endIndent: 16),
      itemBuilder: (context, _) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Shimmer.fromColors(
              baseColor: Colors.grey[300]!,
              highlightColor: Colors.grey[100]!,
              child: Container(
                width: 72, height: 60,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Shimmer.fromColors(
                    baseColor: Colors.grey[300]!,
                    highlightColor: Colors.grey[100]!,
                    child: Container(height: 10, width: 60,
                        color: Colors.white, margin: const EdgeInsets.only(bottom: 6)),
                  ),
                  Shimmer.fromColors(
                    baseColor: Colors.grey[300]!,
                    highlightColor: Colors.grey[100]!,
                    child: Container(height: 12, color: Colors.white,
                        margin: const EdgeInsets.only(bottom: 4)),
                  ),
                  Shimmer.fromColors(
                    baseColor: Colors.grey[300]!,
                    highlightColor: Colors.grey[100]!,
                    child: Container(height: 12, width: 180, color: Colors.white),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Empty / error state ─────────────────────────────────────────────────────
  Widget _buildEmpty({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64, color: AppColors.grey400),
          const SizedBox(height: 16),
          AppText(title: title, fontSize: 16, fontWeight: FontWeight.w700),
          const SizedBox(height: 8),
          AppText(title: subtitle, fontSize: 13, color: AppColors.grey500),
        ],
      ),
    );
  }
}
