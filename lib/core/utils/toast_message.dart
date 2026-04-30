import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// ─────────────────────────────────────────
///  🎨 AppSnackbar — Premium Snackbar Design
///  Use this for all new snackbar calls.
///  CommonToast below is kept for backward compat.
/// ─────────────────────────────────────────
class AppSnackbar {
  AppSnackbar._();

  static void success(String message, {String? title}) {
    _show(
      title: title ?? 'Success',
      message: message,
      iconData: Icons.check_rounded,
      iconColor: const Color(0xFF22C55E),
      accentColor: const Color(0xFF22C55E),
    );
  }

  static void error(String message, {String? title}) {
    _show(
      title: title ?? 'Error',
      message: message,
      iconData: Icons.error_rounded,
      iconColor: const Color(0xFFEF4444),
      accentColor: const Color(0xFFEF4444),
    );
  }

  static void info(String message, {String? title}) {
    _show(
      title: title ?? 'Info',
      message: message,
      iconData: Icons.info_rounded,
      iconColor: const Color(0xFF3B82F6),
      accentColor: const Color(0xFF3B82F6),
    );
  }

  static void warning(String message, {String? title}) {
    _show(
      title: title ?? 'Warning',
      message: message,
      iconData: Icons.warning_rounded,
      iconColor: const Color(0xFFF59E0B),
      accentColor: const Color(0xFFF59E0B),
    );
  }

  static void _show({
    required String title,
    required String message,
    required IconData iconData,
    required Color iconColor,
    required Color accentColor,
  }) {
    // Dismiss any existing snackbar before showing new one
    if (Get.isSnackbarOpen) Get.closeCurrentSnackbar();

    Get.rawSnackbar(
      duration: const Duration(seconds: 3),
      animationDuration: const Duration(milliseconds: 350),
      snackStyle: SnackStyle.FLOATING,
      snackPosition: SnackPosition.TOP,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      borderRadius: 16,
      backgroundColor: Colors.transparent,
      padding: EdgeInsets.zero,
      messageText: _buildSnackbarContent(
        title: title,
        message: message,
        iconData: iconData,
        iconColor: iconColor,
        accentColor: accentColor,
      ),
    );
  }

  static Widget _buildSnackbarContent({
    required String title,
    required String message,
    required IconData iconData,
    required Color iconColor,
    required Color accentColor,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1C1C1E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: accentColor.withValues(alpha: 0.25),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.35),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: accentColor.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            // Left accent bar
            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              child: Container(
                width: 4,
                decoration: BoxDecoration(
                  color: accentColor,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    bottomLeft: Radius.circular(16),
                  ),
                ),
              ),
            ),
            // Content
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Icon container
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: iconColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      iconData,
                      color: iconColor,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 14),
                  // Text
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.1,
                          ),
                        ),
                        if (message.isNotEmpty) ...[
                          const SizedBox(height: 3),
                          Text(
                            message,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.7),
                              fontSize: 13,
                              fontWeight: FontWeight.w400,
                              height: 1.4,
                            ),
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
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

/// ─────────────────────────────────────────
///  🔄 CommonToast — Backward Compatibility
///  Old code jo CommonToast use karta hai
///  wo break nahi hoga — internally AppSnackbar
///  call karta hai.
/// ─────────────────────────────────────────
class CommonToast {
  CommonToast._();

  static void showToast(String message, {int? showDuration}) {
    AppSnackbar.info(message);
  }

  static void showToastError(String message) {
    AppSnackbar.error(message);
  }

  static void showToastSuccess(String message) {
    AppSnackbar.success(message);
  }
}

