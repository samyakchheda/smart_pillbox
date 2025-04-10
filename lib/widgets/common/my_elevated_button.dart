import 'package:flutter/material.dart';
import 'package:home/theme/app_colors.dart'; // Adjust import path
import 'package:home/theme/app_fonts.dart'; // Adjust import path

class MyElevatedButton extends StatelessWidget {
  final double? height;
  final double? width;
  final String? text;
  final VoidCallback? onPressed;
  final Future<void> Function()? onPressedAsync; // Added for async support
  final Color? backgroundColor;
  final Color? textColor;
  final Color? borderColor;
  final double borderRadius;
  final EdgeInsetsGeometry padding;
  final Widget? icon;
  final double iconSpacing;
  final double? iconSize;
  final TextStyle? textStyle;
  final double textShift;
  final BorderSide? borderSide; // Added for custom border
  final Widget? child; // Added for custom child widget
  final bool? disabled; // Added for disabled state

  const MyElevatedButton({
    this.text,
    this.onPressed,
    this.onPressedAsync,
    this.height,
    this.width,
    this.backgroundColor,
    this.textColor,
    this.borderColor,
    this.borderRadius = 8.0,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    this.icon,
    this.iconSpacing = 8.0,
    this.iconSize,
    this.textStyle,
    this.textShift = 10.0,
    this.borderSide,
    this.child,
    this.disabled,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final isDisabled = disabled ?? false;
    final effectiveOnPressed =
        isDisabled ? null : (onPressedAsync ?? onPressed);

    return SizedBox(
      width: width ?? double.infinity,
      height: height ?? 50.0,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: isDisabled
              ? Colors.grey
              : (backgroundColor ?? AppColors.buttonColor),
          foregroundColor: textColor ?? AppColors.buttonText,
          padding: padding,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
            side: borderSide ??
                (borderColor != null
                    ? BorderSide(color: borderColor!, width: 2)
                    : BorderSide.none),
          ),
        ),
        onPressed: effectiveOnPressed != null
            ? () {
                if (onPressedAsync != null) {
                  onPressedAsync!();
                } else {
                  onPressed?.call();
                }
              }
            : null,
        child: child ??
            (text != null
                ? Stack(
                    alignment: Alignment.center,
                    children: [
                      if (icon != null)
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Padding(
                            padding: const EdgeInsets.only(left: 16),
                            child: IconTheme(
                              data: IconThemeData(
                                size: iconSize ?? 24.0,
                                color: textColor ?? AppColors.buttonColor,
                              ),
                              child: icon!,
                            ),
                          ),
                        ),
                      Transform.translate(
                        offset: Offset(textShift, 0),
                        child: Text(
                          text!,
                          style: textStyle ??
                              AppFonts.buttonText.copyWith(
                                color: textColor ?? AppColors.buttonText,
                              ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  )
                : null),
      ),
    );
  }
}
