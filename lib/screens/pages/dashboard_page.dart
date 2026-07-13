import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../widgets/stat_card.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  static const List<StatData> _stats = [
    StatData(
      icon: Icons.people_alt_rounded,
      label: 'Total Customers',
      value: '1,284',
      trend: '+4.2%',
    ),
    StatData(
      icon: Icons.account_balance_wallet_rounded,
      label: 'Active Loans',
      value: '342',
      trend: '+1.8%',
    ),
    StatData(
      icon: Icons.payments_rounded,
      label: 'Payments Today',
      value: '\$18,940',
      trend: '+12.5%',
    ),
    StatData(
      icon: Icons.warning_amber_rounded,
      label: 'Overdue Loans',
      value: '27',
      trend: '-2.1%',
      trendUp: false,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(28, 24, 28, 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Dashboard',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: AppColors.heading,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Overview of your lending activity at a glance.',
            style: TextStyle(fontSize: 13.5, color: AppColors.muted),
          ),
          const SizedBox(height: 24),
          const StatCardRow(stats: _stats),
          const SizedBox(height: 20),
          // Chart + recent payments side by side; stacks when narrow. Both
          // sit in bounded-height boxes so the flexible bar chart and the
          // scrolling list always get a finite height.
          LayoutBuilder(
            builder: (context, constraints) {
              final bool narrow = constraints.maxWidth < 900;
              if (narrow) {
                return Column(
                  children: const [
                    SizedBox(height: 320, child: _ChartCard()),
                    SizedBox(height: 20),
                    SizedBox(height: 340, child: _RecentPaymentsCard()),
                  ],
                );
              }
              return SizedBox(
                height: 360,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: const [
                    Expanded(flex: 3, child: _ChartCard()),
                    SizedBox(width: 20),
                    Expanded(flex: 2, child: _RecentPaymentsCard()),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryGreen.withValues(alpha: 0.05),
            blurRadius: 14,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _ChartCard extends StatelessWidget {
  const _ChartCard();

  static const _values = [42.0, 58.0, 35.0, 70.0, 52.0, 80.0, 64.0];
  static const _labels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  @override
  Widget build(BuildContext context) {
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'Loan Disbursement',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.heading,
                ),
              ),
              const Spacer(),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: AppColors.primaryTint,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'This week',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryDark,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          const Expanded(
            child: _BarChart(values: _values, labels: _labels),
          ),
        ],
      ),
    );
  }
}

/// Lightweight animated bar chart placeholder (no external chart package).
class _BarChart extends StatelessWidget {
  const _BarChart({required this.values, required this.labels});

  final List<double> values;
  final List<String> labels;

  @override
  Widget build(BuildContext context) {
    final double maxV = values.reduce((a, b) => a > b ? a : b);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        for (int i = 0; i < values.length; i++)
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Expanded(
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0, end: values[i] / maxV),
                        duration: Duration(milliseconds: 500 + i * 90),
                        curve: Curves.easeOutCubic,
                        builder: (context, f, _) => FractionallySizedBox(
                          heightFactor: f.clamp(0.0, 1.0),
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  AppColors.primaryGreen,
                                  AppColors.primaryDark,
                                ],
                              ),
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(6),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    labels[i],
                    style: const TextStyle(
                      fontSize: 11.5,
                      color: AppColors.muted,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class _RecentPaymentsCard extends StatelessWidget {
  const _RecentPaymentsCard();

  static const _payments = [
    ('Maria Santos', '\$1,200', 'Paid', true),
    ('John dela Cruz', '\$850', 'Paid', true),
    ('Ana Reyes', '\$2,000', 'Pending', false),
    ('Pedro Lim', '\$540', 'Paid', true),
    ('Grace Tan', '\$1,750', 'Pending', false),
  ];

  @override
  Widget build(BuildContext context) {
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Recent Payments',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.heading,
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                for (final p in _payments)
                  _PaymentRow(p.$1, p.$2, p.$3, p.$4),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PaymentRow extends StatelessWidget {
  const _PaymentRow(this.name, this.amount, this.status, this.paid);

  final String name;
  final String amount;
  final String status;
  final bool paid;

  @override
  Widget build(BuildContext context) {
    final Color statusColor =
        paid ? AppColors.primaryDark : const Color(0xFFB98900);
    final Color statusBg = paid
        ? AppColors.primaryGreen.withValues(alpha: 0.12)
        : const Color(0xFFFFF3D6);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 9),
      child: Row(
        children: [
          CircleAvatar(
            radius: 17,
            backgroundColor: AppColors.primaryTint,
            child: Text(
              name[0],
              style: const TextStyle(
                color: AppColors.primaryDark,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                    color: AppColors.heading,
                  ),
                ),
                Text(
                  amount,
                  style: const TextStyle(fontSize: 12.5, color: AppColors.muted),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: statusBg,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              status,
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
                color: statusColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
