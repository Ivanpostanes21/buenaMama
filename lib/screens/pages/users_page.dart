import 'package:flutter/material.dart';

import '../../widgets/section_page.dart';
import '../../widgets/stat_card.dart';

class UsersPage extends StatelessWidget {
  const UsersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const SectionPage(
      title: 'Users',
      description: 'Manage staff accounts and access roles.',
      placeholderIcon: Icons.manage_accounts_rounded,
      placeholderLabel: 'User management',
      stats: [
        StatData(
            icon: Icons.manage_accounts_rounded,
            label: 'Total Users',
            value: '18'),
        StatData(
            icon: Icons.admin_panel_settings_rounded,
            label: 'Administrators',
            value: '3'),
        StatData(
            icon: Icons.badge_rounded, label: 'Staff', value: '12'),
        StatData(
            icon: Icons.circle_rounded,
            label: 'Online Now',
            value: '5',
            trend: 'live'),
      ],
    );
  }
}
