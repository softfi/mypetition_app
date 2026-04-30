/// @Created by Antigravity
/// API Response Sanitizer to prevent app crashes due to null, empty, or invalid data types.

class ApiSanitizer {
  /// Sanitize String value
  static String sanitizeString(dynamic value, {String defaultValue = ""}) {
    if (value == null) return defaultValue;
    if (value is String) {
      if (value.toLowerCase() == "null") return defaultValue;
      return value.trim();
    }
    return value.toString().trim();
  }

  /// Sanitize Integer value
  static int sanitizeInt(dynamic value, {int defaultValue = 0}) {
    if (value == null) return defaultValue;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) {
      return int.tryParse(value) ?? (double.tryParse(value)?.toInt() ?? defaultValue);
    }
    return defaultValue;
  }

  /// Sanitize Double value
  static double sanitizeDouble(dynamic value, {double defaultValue = 0.0}) {
    if (value == null) return defaultValue;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      return double.tryParse(value) ?? defaultValue;
    }
    return defaultValue;
  }

  /// Sanitize Boolean value
  static bool sanitizeBool(dynamic value, {bool defaultValue = false}) {
    if (value == null) return defaultValue;
    if (value is bool) return value;
    if (value is int) return value == 1;
    if (value is String) {
      String lowered = value.toLowerCase().trim();
      if (lowered == "true" || lowered == "1") return true;
      if (lowered == "false" || lowered == "0") return false;
    }
    return defaultValue;
  }

  /// Sanitize List
  static List<T> sanitizeList<T>(dynamic value) {
    if (value == null || value is! List) return <T>[];
    try {
      return List<T>.from(value);
    } catch (e) {
      // If direct conversion fails, try to cast individual elements or return empty
      return <T>[];
    }
  }

  /// Sanitize Map
  static Map<String, dynamic> sanitizeMap(dynamic value) {
    if (value == null || value is! Map) return <String, dynamic>{};
    try {
      return Map<String, dynamic>.from(value);
    } catch (e) {
      return <String, dynamic>{};
    }
  }

  /// Deep Sanitize for complex objects (Recursive)
  /// Useful for ensuring a whole JSON tree is safe
  static dynamic deepSanitize(dynamic value) {
    if (value == null) return null;
    
    if (value is Map) {
      return value.map((key, val) => MapEntry(key.toString(), deepSanitize(val)));
    }
    
    if (value is List) {
      return value.map((item) => deepSanitize(item)).toList();
    }
    
    if (value is String && value.toLowerCase() == "null") return "";
    
    return value;
  }

  /// Get value from map with safety
  static T getValue<T>(Map<String, dynamic>? map, String key, T defaultValue) {
    if (map == null || !map.containsKey(key) || map[key] == null) {
      return defaultValue;
    }

    dynamic value = map[key];

    if (T == String) return sanitizeString(value, defaultValue: defaultValue as String) as T;
    if (T == int) return sanitizeInt(value, defaultValue: defaultValue as int) as T;
    if (T == double) return sanitizeDouble(value, defaultValue: defaultValue as double) as T;
    if (T == bool) return sanitizeBool(value, defaultValue: defaultValue as bool) as T;
    
    if (value is T) return value;
    
    return defaultValue;
  }
}
