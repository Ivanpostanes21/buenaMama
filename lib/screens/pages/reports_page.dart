import 'package:flutter/material.dart';

import '../../widgets/section_page.dart';
import '../../widgets/stat_card.dart';

class ReportsPage extends StatelessWidget {
  const ReportsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const SectionPage(
      title: 'Reports',
      description: 'Analyze performance with detailed reports.',
      placeholderIcon: Icons.bar_chart_rounded,
      placeholderLabel: 'Analytics report',
      stats: [
        StatData(
            icon: Icons.trending_up_rounded,
            label: 'Collection Rate',
            value: '94.2%',
            trend: '+1.3%'),
        StatData(
            icon: Icons.percent_rounded,
            label: 'Default Rate',
            value: '3.1%',
            trend: '-0.4%',
            trendUp: false),
        StatData(
            icon: Icons.savings_rounded,
            label: 'Net Revenue',
            value: '\$186K',
            trend: '+8.9%'),
        StatData(
            icon: Icons.groups_rounded,
            label: 'Avg. Loan Size',
            value: '\$7,010'),
      ],
    );
  }
}
