import 'package:flutter/material.dart';

/// A single sidebar navigation entry.
class NavItem {
  const NavItem({
    required this.label,
    required this.description,
    required this.icon,
    this.lockedForGuest = false,
  });

  final String label;
  final String description;
  final IconData icon;

  /// When true, the item is locked (grayed + lock icon) in guest mode.
  final bool lockedForGuest;
}

/// The app's primary navigation, in sidebar order. Page order in
/// [MainScreen] must match this list.
const List<NavItem> kNavItems = [
  NavItem(
    label: 'Dashboard',
    description: 'Overview of your lending activity at a glance.',
    icon: Icons.dashboard_rounded,
    lockedForGuest: true,
  ),
  NavItem(
    label: 'Customers',
    description: 'Manage borrowers and their profiles.',
    icon: Icons.people_alt_rounded,
    lockedForGuest: false,
  ),
  NavItem(
    label: 'Loans',
    description: 'Track loan applications, disbursements and balances.',
    icon: Icons.account_balance_wallet_rounded,
    lockedForGuest: true,
  ),
  NavItem(
    label: 'Payments',
    description: 'Record and review incoming repayments.',
    icon: Icons.payments_rounded,
    lockedForGuest: true,
  ),
  NavItem(
    label: 'Reports',
    description: 'Analyze performance with detailed reports.',
    icon: Icons.bar_chart_rounded,
    lockedForGuest: true,
  ),
  NavItem(
    label: 'Users',
    description: 'Manage staff accounts and access roles.',
    icon: Icons.manage_accounts_rounded,
    lockedForGuest: true,
  ),
  NavItem(
    label: 'Settings',
    description: 'Configure application preferences.',
    icon: Icons.settings_rounded,
    lockedForGuest: true,
  ),
];
