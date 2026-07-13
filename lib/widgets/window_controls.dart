import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';

import '../theme/app_colors.dart';

/// Minimize + close buttons for the frameless window, shown in the top-right
/// corner of the header. Kept intentionally subtle to match the login card.
class WindowControls extends StatelessWidget {
  const WindowControls({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _WindowButton(
          icon: Icons.remove,
          tooltip: 'Minimize',
          onPressed: () => windowManager.minimize(),
        ),
        const SizedBox(width: 4),
        _WindowButton(
          icon: Icons.close,
          tooltip: 'Close',
          hoverColor: AppColors.error,
          onPressed: () => windowManager.close(),
        ),
      ],
    );
  }
}

class _WindowButton extends StatefulWidget {
  const _WindowButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
    this.hoverColor,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;
  final Color? hoverColor;

  @override
  State<_WindowButton> createState() => _WindowButtonState();
}

class _WindowButtonState extends State<_WindowButton> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    final Color bg = _hovering
        ? (widget.hoverColor ?? Colors.black.withValues(alpha: 0.08))
        : Colors.transparent;
    final Color fg = _hovering && widget.hoverColor != null
        ? Colors.white
        : Colors.black54;

    return Tooltip(
      message: widget.tooltip,
      child: MouseRegion(
        onEnter: (_) => setState(() => _hovering = true),
        onExit: (_) => setState(() => _hovering = false),
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: widget.onPressed,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            width: 26,
            height: 26,
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(widget.icon, size: 16, color: fg),
          ),
        ),
      ),
    );
  }
}
