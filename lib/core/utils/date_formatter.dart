import 'package:intl/intl.dart';

class AppDateFormatter {
  /// Format: Apr 29, 2026
  static String formatDate(DateTime date) {
    return DateFormat('MMM dd, yyyy').format(date.toLocal());
  }

  /// Format: Apr 29
  static String formatShortDate(DateTime date) {
    return DateFormat('MMM dd').format(date.toLocal());
  }

  /// Format: 12:31 PM
  static String formatTime(DateTime date) {
    return DateFormat('hh:mm a').format(date.toLocal());
  }

  /// Format: Apr 29, 2026 | 12:31 PM
  static String formatDateTime(DateTime date) {
    return DateFormat('MMM dd, yyyy | hh:mm a').format(date.toLocal());
  }

  /// Format: 29 Apr, 2026
  static String formatDayMonthYear(DateTime date) {
    return DateFormat('dd MMM, yyyy').format(date.toLocal());
  }

  /// Format: Monday, Apr 29
  static String formatDayDate(DateTime date) {
    return DateFormat('EEEE, MMM dd').format(date.toLocal());
  }

  /// Human readable relative time: "2 hours ago", "Just now", etc.
  static String timeAgo(DateTime date) {
    final localDate = date.toLocal();
    final Duration diff = DateTime.now().difference(localDate);
    if (diff.inDays >= 7) {
      return formatDate(localDate);
    } else if (diff.inDays >= 1) {
      return '${diff.inDays} days ago';
    } else if (diff.inHours >= 1) {
      return '${diff.inHours} hours ago';
    } else if (diff.inMinutes >= 1) {
      return '${diff.inMinutes} minutes ago';
    } else {
      return 'Just now';
    }
  }
}
