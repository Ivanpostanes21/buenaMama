import 'package:flutter/material.dart';

import '../../widgets/section_page.dart';
import '../../widgets/stat_card.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const SectionPage(
      title: 'Settings',
      description: 'Configure application preferences.',
      placeholderIcon: Icons.settings_rounded,
      placeholderLabel: 'Preferences',
      stats: [
        StatData(
            icon: Icons.business_rounded,
            label: 'Organization',
            value: 'BuenaMama'),
        StatData(
            icon: Icons.language_rounded, label: 'Currency', value: 'USD'),
        StatData(
            icon: Icons.shield_rounded,
            label: 'Security',
            value: '2FA On'),
        StatData(
            icon: Icons.backup_rounded,
            label: 'Last Backup',
            value: 'Today'),
      ],
    );
  }
}
