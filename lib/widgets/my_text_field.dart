import 'package:flutter/material.dart';

class MyTextField extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;
  final IconData icon;
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
  final Color fillColor;
  final double borderRadius; // New borderRadius parameter

  const MyTextField({
    super.key,
    required this.controller,
    required this.hintText,
    required this.icon,
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
    this.fillColor = Colors.transparent,
    this.borderRadius = 50, // Default border radius
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
      decoration: InputDecoration(
        prefixIcon: Icon(widget.icon),
        suffixIcon: widget.isPassword
            ? AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                transitionBuilder: (child, animation) =>
                    FadeTransition(opacity: animation, child: child),
                child: IconButton(
                  key: ValueKey<bool>(_isSecure),
                  icon:
                      Icon(_isSecure ? Icons.visibility : Icons.visibility_off),
                  onPressed: () => setState(() => _isSecure = !_isSecure),
                ),
              )
            : null,
        hintText: widget.hintText,
        hintStyle: const TextStyle(color: Colors.grey),
        fillColor: widget.fillColor,
        filled: true,
        border: _borderStyle(),
        enabledBorder: _borderStyle(),
        focusedBorder: _borderStyle(borderColor: Colors.blue),
        errorBorder: _borderStyle(borderColor: Colors.red),
        focusedErrorBorder: _borderStyle(borderColor: Colors.red),
      ),
    );
  }

  OutlineInputBorder _borderStyle({Color borderColor = Colors.grey}) {
    return OutlineInputBorder(
      borderRadius:
          BorderRadius.circular(widget.borderRadius), // Now customizable!
      borderSide: BorderSide(color: borderColor, width: 1.5),
    );
  }
}
