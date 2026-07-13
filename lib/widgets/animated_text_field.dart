import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// A filled text field whose border, fill and prefix icon animate to lime green
/// when focused. Idle: light gray fill, no border. Focus: 10% lime fill with a
/// 2px lime border, animated over 200ms.
class AnimatedTextField extends StatefulWidget {
  const AnimatedTextField({
    super.key,
    required this.controller,
    required this.hintText,
    required this.icon,
    this.obscureText = false,
    this.keyboardType,
    this.suffix,
    this.onSubmitted,
    this.enabled = true,
  });

  final TextEditingController controller;
  final String hintText;
  final IconData icon;
  final bool obscureText;
  final TextInputType? keyboardType;
  final Widget? suffix;
  final ValueChanged<String>? onSubmitted;
  final bool enabled;

  @override
  State<AnimatedTextField> createState() => _AnimatedTextFieldState();
}

class _AnimatedTextFieldState extends State<AnimatedTextField> {
  final FocusNode _focusNode = FocusNode();
  bool _focused = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      setState(() => _focused = _focusNode.hasFocus);
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Color iconColor = _focused ? AppColors.primaryGreen : AppColors.muted;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
      decoration: BoxDecoration(
        color: _focused ? AppColors.primaryTint : AppColors.fieldFill,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _focused ? AppColors.primaryGreen : Colors.transparent,
          width: 2,
        ),
        boxShadow: _focused
            ? [
                BoxShadow(
                  color: AppColors.primaryGreen.withValues(alpha: 0.15),
                  blurRadius: 10,
                  spreadRadius: 1,
                ),
              ]
            : const [],
      ),
      child: Row(
        children: [
          const SizedBox(width: 14),
          // 200ms color crossfade on the prefix icon.
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            child: Icon(widget.icon, size: 20, color: iconColor),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: widget.controller,
              focusNode: _focusNode,
              obscureText: widget.obscureText,
              keyboardType: widget.keyboardType,
              enabled: widget.enabled,
              onSubmitted: widget.onSubmitted,
              cursorColor: AppColors.primaryGreen,
              style: const TextStyle(fontSize: 14, color: AppColors.heading),
              decoration: InputDecoration(
                hintText: widget.hintText,
                hintStyle:
                    const TextStyle(color: AppColors.muted, fontSize: 14),
                border: InputBorder.none,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 15),
              ),
            ),
          ),
          if (widget.suffix != null) widget.suffix!,
          const SizedBox(width: 6),
        ],
      ),
    );
  }
}
