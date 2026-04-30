// lib/widgets/custom_text_field.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:my_petition_app/core/constants/app_text_styles.dart';
import 'package:my_petition_app/core/utils/custom_text.dart';

class CustomTextField extends StatelessWidget {
  final String? label;
  final String hint;
  final TextEditingController? controller;
  final TextInputType? keyboardType;
  final Widget? prefixWidget;
  final Widget? suffixIcon;
  final int? maxLines;
  final bool enabled;
  final bool isPhoneField;
  final String? countryCode;
  final String? flag;
  final bool? mandatory;
  final bool? isReadOnly;
  final VoidCallback? onTap;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onFieldSubmitted;
  final bool obscureText;

  const CustomTextField({
    super.key,
    this.label,
    required this.hint,
    this.controller,
    this.keyboardType,
    this.prefixWidget,
    this.suffixIcon,
    this.maxLines = 1,
    this.enabled = true,
    this.isPhoneField = false,
    this.mandatory = false,
    this.countryCode,
    this.flag,
    this.isReadOnly = false,
    this.onTap,
    this.validator,
    this.onChanged,
    this.onFieldSubmitted,
    this.obscureText = false,
  });

  // Named constructor for phone field
  const CustomTextField.phone({
    super.key,
    this.label,
    this.hint = "Phone Number",
    this.controller,
    this.countryCode = "+91",
    this.flag = "🇮🇳",
    this.isReadOnly = false,
    this.onTap,
    this.validator,
    this.onChanged,
    this.onFieldSubmitted,
  })  : isPhoneField = true,
        keyboardType = TextInputType.phone,
        prefixWidget = null,
        suffixIcon = null,
        mandatory = false,
        maxLines = 1,
        obscureText = false,
        enabled = true;

  @override
  Widget build(BuildContext context) {
    Widget? effectivePrefixWidget = prefixWidget;

    // Phone field prefix
    if (isPhoneField && flag != null && countryCode != null) {
      effectivePrefixWidget = AppText(
        title: "$flag ($countryCode)",
        fontSize: 14,
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              children: [
                AppText(
                  title: label!,
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                ),
                if (mandatory ?? false)
                  const AppText(
                    title: " *",
                    color: Colors.red,
                  ),
              ],
            ),
          ),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          enabled: enabled && !(isReadOnly ?? false),
          readOnly: isReadOnly ?? false,
          onTap: onTap,
          validator: validator,
          onChanged: onChanged,
          onFieldSubmitted: onFieldSubmitted,
          obscureText: obscureText,
          maxLength: isPhoneField ? 10 : null,
          inputFormatters: isPhoneField
              ? [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(10)
                ]
              : null,
          style: const TextStyle(
            fontSize: 16,
            color: Colors.black,
          ),
          decoration: InputDecoration(
            hintText: hint,
            counterText: "",
            hintStyle: AppTextStyles.bodyMedium,
            prefixIcon: effectivePrefixWidget != null
                ? Padding(
                    padding: const EdgeInsets.only(left: 14, right: 8),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        effectivePrefixWidget,
                      ],
                    ),
                  )
                : null,
            suffixIcon: suffixIcon,
            filled: true,
            fillColor: (isReadOnly ?? false)
                ? const Color(0xFFEEEEEE)
                : Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Colors.blue, width: 1),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Colors.red, width: 1),
            ),
          ),
        ),
      ],
    );
  }
}
