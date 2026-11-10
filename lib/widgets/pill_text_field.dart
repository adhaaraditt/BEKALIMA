import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class PillTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final TextInputType? keyboardType;
  final bool obscureText;
  final ValueChanged<String>? onChanged;
  final Widget? suffixIcon;
  final String? errorText;

  const PillTextField({
    super.key,
    required this.controller,
    required this.hintText,
    this.keyboardType,
    this.obscureText = false,
    this.onChanged,
    this.suffixIcon,
    this.errorText,
  });

  static const TextStyle _textStyle = TextStyle(
    fontFamily: 'Plus Jakarta Sans',
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: Color(0xFF222222),
  );

  static const TextStyle _hintStyle = TextStyle(
    fontFamily: 'Plus Jakarta Sans',
    color: Color(0xFF757575),
    fontSize: 14,
    fontWeight: FontWeight.w500,
  );

  static const TextStyle _errorStyle = TextStyle(
    fontFamily: 'Plus Jakarta Sans',
    color: AppColors.tomatoBurst,
    fontSize: 12,
    fontWeight: FontWeight.w500,
  );

  InputBorder _border() {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(26),
      borderSide: BorderSide(
        color: errorText == null
            ? AppColors.textSecondary
            : AppColors.tomatoBurst,
        width: errorText == null ? 1 : 1.5,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFFFFFFFF),
            borderRadius: BorderRadius.circular(26),
          ),
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            obscureText: obscureText,
            onChanged: onChanged,
            style: _textStyle,
            decoration: InputDecoration(
              hintText: hintText,
              filled: false,
              hintStyle: _hintStyle,
              border: InputBorder.none,
              enabledBorder: _border(),
              focusedBorder: _border(),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 22,
                vertical: 16,
              ),
              suffixIcon: suffixIcon,
            ),
          ),
        ),
        if (errorText != null)
          Padding(
            padding: const EdgeInsets.only(left: 22, top: 6),
            child: Text(errorText!, style: _errorStyle),
          ),
      ],
    );
  }
}