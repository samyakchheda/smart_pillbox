import 'package:flutter/material.dart';
import 'package:home/theme/app_colors.dart'; // Adjust import path
import 'package:home/theme/app_fonts.dart'; // Adjust import path

class MyTextField extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;
  final IconData? icon;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final List<String>? autofillHints;
  final bool isPassword;
  final FocusNode? focusNode;
  final TextInputAction? textInputAction;
  final void Function(String)? onFieldSubmitted;
  final bool enabled;
  final int maxLines;
  final void Function(String)? onChanged;
  final void Function()? onTap;
  final Color? fillColor;
  final double borderRadius;
  final TextStyle? hintStyle; // Added
  final TextStyle? textStyle; // Added
  final Color? iconColor; // Added

  const MyTextField({
    super.key,
    required this.controller,
    required this.hintText,
    this.icon,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.autofillHints,
    this.isPassword = false,
    this.focusNode,
    this.textInputAction,
    this.onFieldSubmitted,
    this.enabled = true,
    this.maxLines = 1,
    this.onChanged,
    this.onTap,
    this.fillColor,
    this.borderRadius = 50,
    this.hintStyle, // Added
    this.textStyle, // Added
    this.iconColor, // Added
  });

  @override
  _MyTextFieldState createState() => _MyTextFieldState();
}

class _MyTextFieldState extends State<MyTextField> {
  late bool _isSecure;

  @override
  void initState() {
    super.initState();
    _isSecure = widget.isPassword;
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      obscureText: widget.isPassword ? _isSecure : false,
      focusNode: widget.focusNode,
      textInputAction: widget.textInputAction,
      onFieldSubmitted: widget.onFieldSubmitted,
      enabled: widget.enabled,
      maxLines: widget.isPassword ? 1 : widget.maxLines,
      keyboardType: widget.keyboardType,
      autofillHints: widget.autofillHints,
      validator: widget.validator,
      onChanged: widget.onChanged,
      onTap: widget.onTap,
      style: widget.textStyle ?? // Use provided textStyle or default
          AppFonts.bodyText.copyWith(color: AppColors.textPrimary),
      decoration: InputDecoration(
        prefixIcon: widget.icon != null
            ? Icon(widget.icon,
                color: widget.iconColor ?? AppColors.buttonColor)
            : null,
        suffixIcon: widget.isPassword
            ? AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                transitionBuilder: (child, animation) =>
                    FadeTransition(opacity: animation, child: child),
                child: IconButton(
                  key: ValueKey<bool>(_isSecure),
                  icon: Icon(
                    _isSecure ? Icons.visibility : Icons.visibility_off,
                    color: widget.iconColor ?? AppColors.buttonColor,
                  ),
                  onPressed: () => setState(() => _isSecure = !_isSecure),
                ),
              )
            : null,
        hintText: widget.hintText,
        hintStyle: widget.hintStyle ?? // Use provided hintStyle or default
            AppFonts.caption.copyWith(color: AppColors.textPlaceholder),
        fillColor:
            widget.fillColor ?? AppColors.cardBackground.withOpacity(0.1),
        filled: true,
        border: _borderStyle(),
        enabledBorder: _borderStyle(),
        focusedBorder: _borderStyle(borderColor: AppColors.buttonColor),
        errorBorder: _borderStyle(borderColor: Colors.red),
        focusedErrorBorder: _borderStyle(borderColor: Colors.red),
      ),
    );
  }

  OutlineInputBorder _borderStyle({Color? borderColor}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(widget.borderRadius),
      borderSide: BorderSide(
        color: borderColor ?? AppColors.textPlaceholder,
        width: 1.5,
      ),
    );
  }
}
