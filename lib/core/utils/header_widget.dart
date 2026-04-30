import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

import 'package:my_petition_app/core/constants/app_colors.dart';
import 'package:my_petition_app/core/utils/custom_text.dart';

class AppHeader extends StatelessWidget {
  final String? title;
  final String? subtitle;
  final String? searchValue;

  final VoidCallback? onBack;
  final ValueChanged<String>? onSearchChanged;
  final VoidCallback? onClearSearch;

  /// 🔥 NEW
  final Widget? trailing;      // filter icons
  final Widget? bottomWidget;  // chips / extra UI

  const AppHeader({
    super.key,
    this.title,
    this.subtitle,
    this.searchValue,
    this.onBack,
    this.onSearchChanged,
    this.onClearSearch,
    this.trailing,
    this.bottomWidget,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 50, 16, 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary,
            AppColors.primary.withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// TITLE ROW
          Row(
            children: [
              if (onBack != null)
                InkWell(
                  borderRadius: BorderRadius.circular(24),
                  onTap: onBack,
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Iconsax.arrow_left_2,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              if (onBack != null) const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText(
                      title: title ?? "",
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    if (subtitle != null && subtitle!.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      AppText(
                        title: subtitle!,
                        color: Colors.white.withOpacity(0.85),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          /// SEARCH BAR
          Container(
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              children: [
                const SizedBox(width: 15),
                const Icon(Iconsax.search_normal, color: Colors.grey, size: 22),
                const SizedBox(width: 10),

                Expanded(
                  child: TextField(
                    onChanged: onSearchChanged,
                    decoration: InputDecoration(
                      hintText: subtitle?.isNotEmpty ?? false
                          ? "Search in ${subtitle!}..."
                          : "Search topics, PDFs...",
                      hintStyle: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 14,
                      ),
                      border: InputBorder.none,
                    ),
                    style: const TextStyle(
                      fontSize: 14,
                    ),
                  ),
                ),

                if ((searchValue ?? "").isNotEmpty)
                  IconButton(
                    icon: const Icon(Iconsax.close_circle, color: Colors.grey),
                    onPressed: onClearSearch,
                  ),

                /// 🔥 FILTER SLOT
                if (trailing != null) ...[
                  Container(
                    height: 30,
                    width: 1,
                    color: Colors.grey.shade300,
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                  ),
                  trailing!,
                ],
              ],
            ),
          ),

          /// 🔥 BOTTOM SLOT (chips etc)
          if (bottomWidget != null) ...[
            const SizedBox(height: 12),
            bottomWidget!,
          ],
        ],
      ),
    );
  }
}


// import 'package:flutter/material.dart';
//
// import '../../theme/app_colors.dart';
// import '../../widgets/app_text.dart';
//
// class AppHeader extends StatelessWidget {
//   final String? title;
//   final String? subtitle;
//   final String? searchValue;
//
//   final VoidCallback? onBack;
//   final ValueChanged<String>? onSearchChanged;
//   final VoidCallback? onClearSearch;
//
//   /// 🔥 NEW
//   final Widget? trailing;      // filter icons
//   final Widget? bottomWidget;  // chips / extra UI
//
//   const AppHeader({
//     super.key,
//     this.title,
//     this.subtitle,
//     this.searchValue,
//     this.onBack,
//     this.onSearchChanged,
//     this.onClearSearch,
//     this.trailing,
//     this.bottomWidget,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       width: double.infinity,
//       padding: const EdgeInsets.fromLTRB(16, 50, 16, 20),
//       decoration: BoxDecoration(
//         gradient: LinearGradient(
//           colors: [
//             appColors.primaryColor,
//             appColors.primaryColor.withOpacity(0.8),
//           ],
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//         ),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           /// TITLE
//           Row(
//             children: [
//               if (onBack != null)
//                 InkWell(
//                   borderRadius: BorderRadius.circular(24),
//                   onTap: onBack,
//                   child: const Padding(
//                     padding: EdgeInsets.all(8),
//                     child: Icon(
//                       Icons.arrow_back_ios_new,
//                       color: Colors.white,
//                       size: 20,
//                     ),
//                   ),
//                 ),
//               if (onBack != null) const SizedBox(width: 12),
//
//               Expanded(
//                 child: AppText(
//                   title: title ?? "",
//                   color: Colors.white,
//                   fontSize: 18,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//             ],
//           ),
//
//           const SizedBox(height: 20),
//
//           /// SEARCH BAR
//           Container(
//             height: 48,
//             decoration: BoxDecoration(
//               color: Colors.white,
//               borderRadius: BorderRadius.circular(30),
//               boxShadow: [
//                 BoxShadow(
//                   color: Colors.black.withOpacity(0.1),
//                   blurRadius: 10,
//                   offset: const Offset(0, 3),
//                 ),
//               ],
//             ),
//             child: Row(
//               children: [
//                 const SizedBox(width: 15),
//                 const Icon(Icons.search, color: Colors.grey),
//                 const SizedBox(width: 10),
//
//                 Expanded(
//                   child: TextField(
//                     onChanged: onSearchChanged,
//                     decoration: const InputDecoration(
//                       hintText: "Search for courses...",
//                       border: InputBorder.none,
//                     ),
//                   ),
//                 ),
//
//                 if ((searchValue ?? "").isNotEmpty)
//                   IconButton(
//                     icons: const Icon(Icons.clear, color: Colors.grey),
//                     onPressed: onClearSearch,
//                   ),
//
//                 /// 🔥 FILTER SLOT
//                 if (trailing != null) trailing!,
//               ],
//             ),
//           ),
//
//           /// 🔥 BOTTOM SLOT (chips etc)
//           if (bottomWidget != null) ...[
//             const SizedBox(height: 12),
//             bottomWidget!,
//           ],
//         ],
//       ),
//     );
//   }
// }
