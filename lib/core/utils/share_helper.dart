import 'package:share_plus/share_plus.dart';
import 'package:flutter/material.dart';
import 'package:my_petition_app/core/constants/app_strings.dart';

class ShareHelper {
  ShareHelper._();

  /// Share news content
  static Future<void> shareNews({
    required String title,
    required String url,
    String? description,
  }) async {
    final String shareText = '$title\n\n${description ?? ""}\n\nRead more at: $url\n\nShared via ${AppStrings.appName}';
    
    await Share.share(
      shareText,
      subject: title,
    );
  }

  /// Share petition content
  static Future<void> sharePetition({
    required String title,
    required String url,
    String? description,
  }) async {
    final String shareText = 'Support this petition: $title\n\n${description ?? ""}\n\nSign here: $url\n\nShared via ${AppStrings.appName}';
    
    await Share.share(
      shareText,
      subject: 'Support this Petition: $title',
    );
  }

  /// Generic share
  static Future<void> shareText(String text, {String? subject}) async {
    await Share.share(text, subject: subject);
  }
}
