import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Data for a single stat card.
class StatData {
  const StatData({
    required this.icon,
    required this.label,
    required this.value,
    this.trend,
    this.trendUp = true,
  });

  final IconData icon;
  final String label;
  final String value;
  final String? trend;
  final bool trendUp;
}

/// A white stat card with a lime icon container, a large value and a label.
/// Lifts subtly on hover.
class StatCard extends StatefulWidget {
  const StatCard({super.key, required this.data});

  final StatData data;

  @override
  State<StatCard> createState() => _StatCardState();
}

class _StatCardState extends State<StatCard> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    final d = widget.data;
    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        transform: Matrix4.translationValues(0, _hovering ? -3 : 0, 0),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.cardBorder),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryGreen
                  .withValues(alpha: _hovering ? 0.14 : 0.06),
              blurRadius: _hovering ? 22 : 14,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    gradient: AppColors.logoGradient,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryGreen.withValues(alpha: 0.35),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Icon(d.icon, color: Colors.white, size: 22),
                ),
                const Spacer(),
                if (d.trend != null)
                  Row(
                    children: [
                      Icon(
                        d.trendUp
                            ? Icons.trending_up_rounded
                            : Icons.trending_down_rounded,
                        size: 16,
                        color: d.trendUp
                            ? AppColors.primaryDark
                            : AppColors.error,
                      ),
                      const SizedBox(width: 3),
                      Text(
                        d.trend!,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: d.trendUp
                              ? AppColors.primaryDark
                              : AppColors.error,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              d.value,
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w800,
                color: AppColors.heading,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              d.label,
              style: const TextStyle(fontSize: 13, color: AppColors.muted),
            ),
          ],
        ),
      ),
    );
  }
}

/// Lays a list of stat cards out in a single responsive row of equal widths.
class StatCardRow extends StatelessWidget {
  const StatCardRow({super.key, required this.stats});

  final List<StatData> stats;

  @override
  Widget build(BuildContext context) {
    // IntrinsicHeight keeps the cards equal height without a stretch cross-axis
    // (which would force infinite height inside a scroll view). Safe here
    // because StatCard has no flexible children.
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (int i = 0; i < stats.length; i++) ...[
            Expanded(child: StatCard(data: stats[i])),
            if (i != stats.length - 1) const SizedBox(width: 16),
          ],
        ],
      ),
    );
  }
}
