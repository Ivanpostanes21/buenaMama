import 'package:flutter/material.dart';

import '../../widgets/section_page.dart';
import '../../widgets/stat_card.dart';

class LoansPage extends StatelessWidget {
  const LoansPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const SectionPage(
      title: 'Loans',
      description: 'Track loan applications, disbursements and balances.',
      placeholderIcon: Icons.account_balance_wallet_rounded,
      placeholderLabel: 'Loan ledger',
      stats: [
        StatData(
            icon: Icons.account_balance_wallet_rounded,
            label: 'Active Loans',
            value: '342',
            trend: '+1.8%'),
        StatData(
            icon: Icons.request_quote_rounded,
            label: 'Pending Applications',
            value: '58'),
        StatData(
            icon: Icons.attach_money_rounded,
            label: 'Portfolio Value',
            value: '\$2.4M',
            trend: '+6.3%'),
        StatData(
            icon: Icons.warning_amber_rounded,
            label: 'Overdue',
            value: '27',
            trend: '-2.1%',
            trendUp: false),
      ],
    );
  }
}
