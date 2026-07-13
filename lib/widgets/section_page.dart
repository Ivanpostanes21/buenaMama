import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import 'stat_card.dart';

/// A reusable placeholder page: heading + description, a row of stat cards,
/// and a placeholder table/chart area. Used by the simpler sections.
class SectionPage extends StatelessWidget {
  const SectionPage({
    super.key,
    required this.title,
    required this.description,
    required this.stats,
    this.placeholderIcon = Icons.table_chart_rounded,
    this.placeholderLabel = 'Data table',
  });

  final String title;
  final String description;
  final List<StatData> stats;
  final IconData placeholderIcon;
  final String placeholderLabel;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(28, 24, 28, 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: AppColors.heading,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            description,
            style: const TextStyle(fontSize: 13.5, color: AppColors.muted),
          ),
          const SizedBox(height: 24),
          StatCardRow(stats: stats),
          const SizedBox(height: 24),
          _PlaceholderArea(icon: placeholderIcon, label: placeholderLabel),
        ],
      ),
    );
  }
}

class _PlaceholderArea extends StatelessWidget {
  const _PlaceholderArea({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 320,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppColors.primaryTint,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Icon(icon, size: 30, color: AppColors.primaryDark),
            ),
            const SizedBox(height: 14),
            Text(
              '$label coming soon',
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppColors.heading,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'This section is a placeholder for now.',
              style: TextStyle(fontSize: 13, color: AppColors.muted),
            ),
          ],
        ),
      ),
    );
  }
}
