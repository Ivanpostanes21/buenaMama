import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// A compact checkbox that fills lime green and plays a small scale-bounce
/// each time it is toggled.
class BounceCheckbox extends StatefulWidget {
  const BounceCheckbox({
    super.key,
    required this.value,
    required this.onChanged,
    this.label,
  });

  final bool value;
  final ValueChanged<bool> onChanged;
  final String? label;

  @override
  State<BounceCheckbox> createState() => _BounceCheckboxState();
}

class _BounceCheckboxState extends State<BounceCheckbox>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 220),
  );
  late final Animation<double> _bounce = TweenSequence<double>([
    TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.25), weight: 50),
    TweenSequenceItem(tween: Tween(begin: 1.25, end: 1.0), weight: 50),
  ]).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggle() {
    widget.onChanged(!widget.value);
    _controller.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _toggle,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ScaleTransition(
            scale: _bounce,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeOut,
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color:
                    widget.value ? AppColors.primaryGreen : Colors.transparent,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: widget.value ? AppColors.primaryGreen : AppColors.muted,
                  width: 2,
                ),
              ),
              child: widget.value
                  ? const Icon(Icons.check, size: 14, color: Colors.white)
                  : null,
            ),
          ),
          if (widget.label != null) ...[
            const SizedBox(width: 8),
            Text(
              widget.label!,
              style: const TextStyle(fontSize: 13, color: AppColors.muted),
            ),
          ],
        ],
      ),
    );
  }
}
