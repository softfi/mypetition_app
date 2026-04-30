import 'package:flutter/material.dart';

class EmptyWidget extends StatelessWidget {
  final String? title;
  final String? message;
  final IconData? icon;
  final String? imagePath;
  final double? imageHeight;
  final double? imageWidth;
  final VoidCallback? onRetry;
  final String? retryButtonText;
  final Color? iconColor;
  final Color? titleColor;
  final Color? messageColor;
  final double? iconSize;
  final double? titleFontSize;
  final double? messageFontSize;

  const EmptyWidget({
    Key? key,
    this.title,
    this.message,
    this.icon,
    this.imagePath,
    this.imageHeight,
    this.imageWidth,
    this.onRetry,
    this.retryButtonText,
    this.iconColor,
    this.titleColor,
    this.messageColor,
    this.iconSize,
    this.titleFontSize,
    this.messageFontSize,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Image or Icon
            if (imagePath != null)
              Image.asset(
                imagePath!,
                height: imageHeight ?? 150,
                width: imageWidth ?? 150,
                fit: BoxFit.contain,
              )
            else
              Icon(
                icon ?? Icons.inbox_outlined,
                size: iconSize ?? 80,
                color: iconColor ?? Colors.grey.shade400,
              ),

            const SizedBox(height: 24),

            // Title
            if (title != null)
              Text(
                title!,
                style: TextStyle(
                  fontSize: titleFontSize ?? 18,
                  fontWeight: FontWeight.w600,
                  color: titleColor ?? Colors.grey.shade800,
                ),
                textAlign: TextAlign.center,
              ),

            const SizedBox(height: 8),

            // Message
            if (message != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  message!,
                  style: TextStyle(
                    fontSize: messageFontSize ?? 14,
                    color: messageColor ?? Colors.grey.shade600,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),

            // Retry Button
            if (onRetry != null) ...[
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh, size: 20),
                label: Text(retryButtonText ?? 'Retry'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// Predefined Empty States
class EmptyStates {
  // No Data
  static Widget noData({
    String? title,
    String? message,
    VoidCallback? onRetry,
  }) {
    return EmptyWidget(
      icon: Icons.inbox_outlined,
      title: title ?? 'No Data Found',
      message: message ?? 'There is no data available at the moment',
      onRetry: onRetry,
    );
  }

  // No Faculties
  static Widget noFaculties({VoidCallback? onRetry}) {
    return EmptyWidget(
      icon: Icons.people_outline,
      iconColor: Colors.blue.shade300,
      title: 'No Faculties Found',
      message: 'There are no faculty members available at the moment',
      onRetry: onRetry,
      retryButtonText: 'Refresh',
    );
  }

  // No Results
  static Widget noResults({String? searchQuery}) {
    return EmptyWidget(
      icon: Icons.search_off_outlined,
      title: 'No Results Found',
      message: searchQuery != null
          ? 'No results found for "$searchQuery"'
          : 'Try adjusting your search criteria',
    );
  }

  // No Internet
  static Widget noInternet({VoidCallback? onRetry}) {
    return EmptyWidget(
      icon: Icons.wifi_off_outlined,
      iconColor: Colors.orange.shade400,
      title: 'No Internet Connection',
      message: 'Please check your internet connection and try again',
      onRetry: onRetry,
      retryButtonText: 'Retry',
    );
  }

  // Error State
  static Widget error({
    String? title,
    String? message,
    VoidCallback? onRetry,
  }) {
    return EmptyWidget(
      icon: Icons.error_outline,
      iconColor: Colors.red.shade400,
      title: title ?? 'Something Went Wrong',
      message: message ?? 'An error occurred. Please try again',
      onRetry: onRetry,
      retryButtonText: 'Retry',
    );
  }

  // Coming Soon
  static Widget comingSoon() {
    return EmptyWidget(
      icon: Icons.upcoming_outlined,
      iconColor: Colors.purple.shade300,
      title: 'Coming Soon',
      message: 'This feature is under development',
    );
  }

  // No Notifications
  static Widget noNotifications() {
    return EmptyWidget(
      icon: Icons.notifications_none_outlined,
      title: 'No Notifications',
      message: 'You don\'t have any notifications yet',
    );
  }

  // Empty Cart
  static Widget emptyCart({VoidCallback? onShopNow}) {
    return EmptyWidget(
      icon: Icons.shopping_cart_outlined,
      title: 'Your Cart is Empty',
      message: 'Add items to your cart to get started',
      onRetry: onShopNow,
      retryButtonText: 'Shop Now',
    );
  }

  // Custom with Image
  static Widget custom({
    required String imagePath,
    String? title,
    String? message,
    VoidCallback? onAction,
    String? actionButtonText,
  }) {
    return EmptyWidget(
      imagePath: imagePath,
      title: title,
      message: message,
      onRetry: onAction,
      retryButtonText: actionButtonText,
    );
  }
}
