import 'package:flutter/material.dart';

import '../../widgets/section_page.dart';
import '../../widgets/stat_card.dart';

class CustomersPage extends StatelessWidget {
  const CustomersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const SectionPage(
      title: 'Customers',
      description: 'Manage borrowers and their profiles.',
      placeholderIcon: Icons.people_alt_rounded,
      placeholderLabel: 'Customer list',
      stats: [
        StatData(
            icon: Icons.people_alt_rounded,
            label: 'Total Customers',
            value: '1,284',
            trend: '+4.2%'),
        StatData(
            icon: Icons.person_add_alt_1_rounded,
            label: 'New This Month',
            value: '86',
            trend: '+9.0%'),
        StatData(
            icon: Icons.verified_user_rounded,
            label: 'Active',
            value: '1,102'),
        StatData(
            icon: Icons.block_rounded,
            label: 'Blacklisted',
            value: '14',
            trend: '-1.0%',
            trendUp: false),
      ],
    );
  }
}
