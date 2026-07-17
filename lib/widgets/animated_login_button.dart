import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Visual state of the [AnimatedLoginButton].
enum LoginButtonState { idle, loading, success }

/// A full-width button that:
///   * lifts slightly on hover and scales down while pressed (tap feedback),
///   * morphs into a circular spinner when [state] becomes `loading`
///     (its width shrinks down to a circle), and
///   * turns the spinner into an animated checkmark when [state] is `success`.
class AnimatedLoginButton extends StatefulWidget {
  const AnimatedLoginButton({
    super.key,
    required this.state,
    required this.onPressed,
    this.label = 'Log in',
    this.height = 54,
  });

  final LoginButtonState state;
  final VoidCallback onPressed;
  final String label;
  final double height;

  @override
  State<AnimatedLoginButton> createState() => _AnimatedLoginButtonState();
}

class _AnimatedLoginButtonState extends State<AnimatedLoginButton>
    with SingleTickerProviderStateMixin {
  bool _pressed = false;
  bool _hovering = false;

  // Drives the checkmark draw-on when we reach the success state.
  late final AnimationController _checkController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 400),
  );

  @override
  void didUpdateWidget(covariant AnimatedLoginButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.state == LoginButtonState.success &&
        oldWidget.state != LoginButtonState.success) {
      _checkController.forward(from: 0);
    } else if (widget.state != LoginButtonState.success) {
      _checkController.reset();
    }
  }

  @override
  void dispose() {
    _checkController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isIdle = widget.state == LoginButtonState.idle;
    final bool hoverActive = _hovering && isIdle && !_pressed;

    // When idle the button is full-width; otherwise it collapses to a circle.
    final double targetWidth = isIdle ? 292 : widget.height;
    final double scale = _pressed ? 0.97 : (hoverActive ? 1.02 : 1.0);
    // Lift the button up by 2px on hover.
    final double lift = hoverActive ? -2.0 : 0.0;
    final double glow = hoverActive ? 0.55 : 0.35;

    return Center(
      child: MouseRegion(
        cursor: isIdle ? SystemMouseCursors.click : SystemMouseCursors.basic,
        onEnter: (_) => setState(() => _hovering = true),
        onExit: (_) => setState(() => _hovering = false),
        child: GestureDetector(
          onTapDown: isIdle ? (_) => setState(() => _pressed = true) : null,
          onTapUp: isIdle ? (_) => setState(() => _pressed = false) : null,
          onTapCancel: isIdle ? () => setState(() => _pressed = false) : null,
          onTap: isIdle ? widget.onPressed : null,
          child: AnimatedSlide(
            offset: Offset(0, lift / widget.height),
            duration: const Duration(milliseconds: 160),
            curve: Curves.easeOut,
            child: AnimatedScale(
              scale: scale,
              duration: const Duration(milliseconds: 160),
              curve: Curves.easeOut,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeInOutCubic,
                height: widget.height,
                width: targetWidth,
                constraints: BoxConstraints(minWidth: widget.height),
                decoration: BoxDecoration(
                  gradient: hoverActive
                      ? AppColors.buttonGradientHover
                      : AppColors.buttonGradient,
                  borderRadius: BorderRadius.circular(
                    isIdle ? 12 : widget.height / 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryGreen.withValues(alpha: glow),
                      blurRadius: hoverActive ? 24 : 16,
                      offset: Offset(0, hoverActive ? 12 : 8),
                    ),
                  ],
                ),
                child: Center(child: _buildChild()),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildChild() {
    switch (widget.state) {
      case LoginButtonState.idle:
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              widget.label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15.5,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.4,
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.arrow_forward_rounded,
                color: Colors.white, size: 19),
          ],
        );
      case LoginButtonState.loading:
        return const SizedBox(
          width: 22,
          height: 22,
          child: CircularProgressIndicator(
            strokeWidth: 2.5,
            valueColor: AlwaysStoppedAnimation(Colors.white),
          ),
        );
      case LoginButtonState.success:
        return AnimatedBuilder(
          animation: _checkController,
          builder: (context, _) => CustomPaint(
            size: const Size(24, 24),
            painter: _CheckPainter(_checkController.value),
          ),
        );
    }
  }
}

/// Paints a checkmark that draws itself on from 0..1 progress.
class _CheckPainter extends CustomPainter {
  _CheckPainter(this.progress);

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    // Two segments of the tick, defined relative to the canvas size.
    final p1 = Offset(size.width * 0.20, size.height * 0.52);
    final p2 = Offset(size.width * 0.42, size.height * 0.72);
    final p3 = Offset(size.width * 0.80, size.height * 0.30);

    final firstLen = (p2 - p1).distance;
    final secondLen = (p3 - p2).distance;
    final total = firstLen + secondLen;
    final drawn = total * progress;

    final path = Path()..moveTo(p1.dx, p1.dy);
    if (drawn <= firstLen) {
      final t = firstLen == 0 ? 0.0 : drawn / firstLen;
      path.lineTo(p1.dx + (p2.dx - p1.dx) * t, p1.dy + (p2.dy - p1.dy) * t);
    } else {
      path.lineTo(p2.dx, p2.dy);
      final t = secondLen == 0 ? 0.0 : (drawn - firstLen) / secondLen;
      path.lineTo(p2.dx + (p3.dx - p2.dx) * t, p2.dy + (p3.dy - p2.dy) * t);
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_CheckPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
