import 'package:flutter/material.dart';
import 'package:my_petition_app/core/constants/app_constant.dart';


class Logger {
  static void d(String message, {String tag = AppConstant.defaultTag}) {
    _log('DEBUG', message, tag);
  }

  static void i(String message, {String tag = AppConstant.defaultTag}) {
    _log('INFO', message, tag);
  }

  static void w(String message, {String tag = AppConstant.defaultTag}) {
    _log('WARNING', message, tag);
  }

  static void e(
    String message, {
    String tag = AppConstant.defaultTag,
    dynamic error,
  }) {
    _log('ERROR', message, tag);
    if (error != null) {
      _log('ERROR', error.toString(), tag);
    }
  }

  static void _log(String level, String message, String tag) {
    // developer.log('[$level] $message', name: tag);
    debugPrint('[$tag][$level] $message');
  }
}
