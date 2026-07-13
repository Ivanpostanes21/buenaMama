import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';

import '../theme/app_colors.dart';

/// Minimize / maximize (restore) / close controls for the main app window.
/// Listens to window events so the maximize icon stays in sync.
class AppWindowButtons extends StatefulWidget {
  const AppWindowButtons({super.key});

  @override
  State<AppWindowButtons> createState() => _AppWindowButtonsState();
}

class _AppWindowButtonsState extends State<AppWindowButtons>
    with WindowListener {
  bool _maximized = false;

  @override
  void initState() {
    super.initState();
    windowManager.addListener(this);
    windowManager.isMaximized().then((v) {
      if (mounted) setState(() => _maximized = v);
    });
  }

  @override
  void dispose() {
    windowManager.removeListener(this);
    super.dispose();
  }

  @override
  void onWindowMaximize() => setState(() => _maximized = true);

  @override
  void onWindowUnmaximize() => setState(() => _maximized = false);

  Future<void> _toggleMaximize() async {
    if (await windowManager.isMaximized()) {
      await windowManager.unmaximize();
    } else {
      await windowManager.maximize();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _Btn(
          icon: Icons.remove,
          tooltip: 'Minimize',
          onPressed: () => windowManager.minimize(),
        ),
        _Btn(
          icon: _maximized
              ? Icons.filter_none_rounded
              : Icons.crop_square_rounded,
          tooltip: _maximized ? 'Restore' : 'Maximize',
          iconSize: _maximized ? 13 : 15,
          onPressed: _toggleMaximize,
        ),
        _Btn(
          icon: Icons.close_rounded,
          tooltip: 'Close',
          hoverColor: AppColors.error,
          onPressed: () => windowManager.close(),
        ),
      ],
    );
  }
}

class _Btn extends StatefulWidget {
  const _Btn({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
    this.hoverColor,
    this.iconSize = 16,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;
  final Color? hoverColor;
  final double iconSize;

  @override
  State<_Btn> createState() => _BtnState();
}

class _BtnState extends State<_Btn> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    final Color bg = _hovering
        ? (widget.hoverColor ?? AppColors.heading.withValues(alpha: 0.06))
        : Colors.transparent;
    final Color fg = _hovering && widget.hoverColor != null
        ? Colors.white
        : AppColors.muted;

    return Tooltip(
      message: widget.tooltip,
      waitDuration: const Duration(milliseconds: 500),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _hovering = true),
        onExit: (_) => setState(() => _hovering = false),
        child: GestureDetector(
          onTap: widget.onPressed,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            width: 40,
            height: 32,
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(widget.icon, size: widget.iconSize, color: fg),
          ),
        ),
      ),
    );
  }
}
