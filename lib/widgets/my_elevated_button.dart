import 'package:flutter/material.dart';

class MyElevatedButton extends StatelessWidget {
  final double? height;
  final double? width;
  final String text;
  final VoidCallback onPressed;
  final Color? backgroundColor;
  final Color? textColor;
  final Color? borderColor; // Border color property
  final double borderRadius;
  final EdgeInsetsGeometry padding;
  final Widget? icon;
  final double iconSpacing;
  final double? iconSize;
  final TextStyle? textStyle;
  final double textShift; // New property to shift text

  const MyElevatedButton({
    required this.text,
    required this.onPressed,
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
    this.textShift = 10.0, // Default shift for text
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width ?? double.infinity, // Full width button
      height: height ?? 50.0, // Default height
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor ?? Theme.of(context).primaryColor,
          foregroundColor: textColor ?? Colors.white,
          padding: padding,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
            side: borderColor != null
                ? BorderSide(color: borderColor!, width: 2) // Border color
                : BorderSide.none, // No border if not provided
          ),
        ),
        onPressed: onPressed,
        child: Stack(
          alignment: Alignment.center,
          children: [
            if (icon != null)
              Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding:
                      const EdgeInsets.only(left: 16), // Adjust icon spacing
                  child: IconTheme(
                    data: IconThemeData(size: iconSize ?? 24.0),
                    child: icon!,
                  ),
                ),
              ),
            Transform.translate(
              offset: Offset(textShift, 0), // Shift text slightly right
              child: Text(
                text,
                style: textStyle ??
                    TextStyle(
                      color: textColor ?? Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
