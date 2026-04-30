/// @Created by akash on 16-02-2024.
/// Know more about author at https://akash.cloudemy.in

import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class ApiResponsePrinter {
  // Print Dio Request
  static void printRequest(RequestOptions options) {
    if (kDebugMode) {
      try {
        print("╔═╣ Request ║ ${options.method.toUpperCase()} ");
        print("║");
        print("║  ${options.uri}");
        print("║");
        print("║═╣ Headers ║══════════════════════════════════════════════════════════════════════════════");
        _prettyPrint(jsonEncode(options.headers));
        print("║═╣ Body ║═════════════════════════════════════════════════════════════════════════════════");
        if (options.data != null) {
          if (options.data is FormData) {
            final formData = options.data as FormData;
            print("║  FormData Fields:");
            for (var field in formData.fields) {
              print("║    ${field.key}: ${field.value}");
            }
            if (formData.files.isNotEmpty) {
              print("║  FormData Files:");
              for (var file in formData.files) {
                print("║    ${file.key}: ${file.value.filename} (Type: ${file.value.contentType})");
              }
            }
          } else if (options.data is Map || options.data is List) {
            _prettyPrint(jsonEncode(options.data));
          } else {
            print("║  ${options.data.toString()}");
          }
        } else {
          print("║  No body");
        }
        print('╚══════════════════════════════════════════════════════════════════════════════════════════╝');
      } catch (e) {
        debugPrint("Unable to print request: $e");
      }
    }
  }

  // Print Dio Response
  static void printResponse(Response response) {
    if (kDebugMode) {
      try {
        print("╔═╣ Response ║ ${response.requestOptions.method.toUpperCase()} ║ Status: ${response.statusCode}");
        print("║");
        print("║  ${response.requestOptions.uri}");
        print("║");
        print("║═╣ Body ║═════════════════════════════════════════════════════════════════════════════════");
        if (response.data != null) {
          if (response.data is Map || response.data is List) {
            _prettyPrint(jsonEncode(response.data));
          } else {
             _prettyPrint(response.data.toString());
          }
        } else {
          print("║  No body");
        }
        print('╚══════════════════════════════════════════════════════════════════════════════════════════╝');
      } catch (e) {
        debugPrint("Unable to print response: $e");
      }
    }
  }

  // Print Dio Error
  static void printError(DioException error) {
    if (kDebugMode) {
      try {
        print("╔═╣ ERROR ║ ${error.requestOptions.method.toUpperCase()} ║ Status: ${error.response?.statusCode ?? 'N/A'}");
        print("║");
        print("║  ${error.requestOptions.uri}");
        print("║");
        print("║═╣ Error Message ║════════════════════════════════════════════════════════════════════════");
        print("║  ${error.message}");
        if (error.response?.data != null) {
          print("║═╣ Error Body ║═══════════════════════════════════════════════════════════════════════════");
          if (error.response?.data is Map || error.response?.data is List) {
            _prettyPrint(jsonEncode(error.response?.data));
          } else {
            _prettyPrint(error.response?.data.toString() ?? "");
          }
        }
        print('╚══════════════════════════════════════════════════════════════════════════════════════════╝');
      } catch (e) {
        debugPrint("Unable to print error: $e");
      }
    }
  }

  // Pretty print JSON or long strings in chunks
  static void _prettyPrint(String input) {
    String output = input;
    try {
      final json = jsonDecode(input);
      const encoder = JsonEncoder.withIndent('  ');
      output = encoder.convert(json);
    } catch (e) {
      // Not a JSON string, use as is
    }

    // Split target string to handle indentation or log limits
    // Adding prefix to each line for better formatting
    final lines = output.split('\n');
    for (var line in lines) {
      // If line is too long, chunk it
      if (line.length > 800) {
        int startIndex = 0;
        while (startIndex < line.length) {
          int endIndex = startIndex + 800;
          if (endIndex > line.length) endIndex = line.length;
          print("║  ${line.substring(startIndex, endIndex)}");
          startIndex = endIndex;
        }
      } else {
        print("║  $line");
      }
    }
  }
}
