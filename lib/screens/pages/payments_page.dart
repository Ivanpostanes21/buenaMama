import 'package:flutter/material.dart';

import '../../widgets/section_page.dart';
import '../../widgets/stat_card.dart';

class PaymentsPage extends StatelessWidget {
  const PaymentsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const SectionPage(
      title: 'Payments',
      description: 'Record and review incoming repayments.',
      placeholderIcon: Icons.payments_rounded,
      placeholderLabel: 'Payment history',
      stats: [
        StatData(
            icon: Icons.payments_rounded,
            label: 'Collected Today',
            value: '\$18,940',
            trend: '+12.5%'),
        StatData(
            icon: Icons.calendar_month_rounded,
            label: 'This Month',
            value: '\$412K',
            trend: '+7.1%'),
        StatData(
            icon: Icons.hourglass_bottom_rounded,
            label: 'Pending',
            value: '\$34,200'),
        StatData(
            icon: Icons.receipt_long_rounded,
            label: 'Transactions',
            value: '963'),
      ],
    );
  }
}
