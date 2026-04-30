import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

class NoLeadingSpaceFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue,
      TextEditingValue newValue,
      ) {
    if (newValue.text.startsWith(' ')) {
      final String trimedText = newValue.text.trimLeft();
      return TextEditingValue(
        text: trimedText,
        selection: TextSelection(
          baseOffset: trimedText.length,
          extentOffset: trimedText.length,
        ),
      );
    }

    return newValue;
  }
}


void callToDial({required String? phoneNumber}) async {
  if (phoneNumber == null || phoneNumber.isEmpty) return;

  final Uri uri = Uri(scheme: 'tel', path: phoneNumber);
  if (await canLaunchUrl(uri)) {
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  } else {
    debugPrint("Cannot launch phone call for $phoneNumber");
  }
}
Future<void> email(String? email) async {
  if (email == null || email.isEmpty) return;

  final Uri uri = Uri(
    scheme: 'mailto',
    path: email,
    query: Uri.encodeFull('subject=Hello&body=Hi there'),
  );

  try {
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  } catch (e) {
    debugPrint('No email app found');
  }
}

/// hh:mm:ss OR mm:ss format
String  formattedDuration(int duration) {
  final hours = duration ~/ 3600;
  final minutes = (duration % 3600) ~/ 60;
  final seconds = duration % 60;

  if (hours > 0) {
    return '${hours.toString().padLeft(2, '0')}:'
        '${minutes.toString().padLeft(2, '0')}:'
        '${seconds.toString().padLeft(2, '0')}';
  } else {
    return '${minutes.toString().padLeft(2, '0')}:'
        '${seconds.toString().padLeft(2, '0')}';
  }
}


String formatExpiryDate(String? dateStr) {
  if (dateStr == null || dateStr.isEmpty) return '-';

  try {
    final date = DateTime.parse(dateStr);
    const months = [
      'JANUARY', 'FEBRUARY', 'MARCH', 'APRIL', 'MAY', 'JUNE',
      'JULY', 'AUGUST', 'SEPTEMBER', 'OCTOBER', 'NOVEMBER', 'DECEMBER'
    ];

    return '${date.day} ${months[date.month - 1]} ${date.year}';
  } catch (e) {
    debugPrint('Error formatting date: $e');
    return dateStr; // fallback original string
  }
}

