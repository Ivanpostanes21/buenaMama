import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../widgets/stat_card.dart';
import '../../widgets/loan_application_flow.dart';

class LoansPage extends StatelessWidget {
  const LoansPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(28, 24, 28, 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text('Loans', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: AppColors.heading)),
                  Text('Manage and track active loans.', style: TextStyle(fontSize: 13.5, color: AppColors.muted)),
                ],
              ),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryGreen, 
                  foregroundColor: Colors.white,
                ),
                onPressed: () {
                  LoanApplicationFlow.start(context);
                },
                icon: const Icon(Icons.request_quote),
                label: const Text('Apply for Loan'),
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          const StatCardRow(
            stats: [
              StatData(icon: Icons.account_balance_wallet, label: 'Active Loans', value: '142'),
              StatData(icon: Icons.monetization_on, label: 'Total Disbursed', value: '₱1.2M'),
              StatData(icon: Icons.pending_actions, label: 'Pending Approvals', value: '12'),
              StatData(icon: Icons.warning_amber_rounded, label: 'Past Due', value: '4'),
            ],
          ),
          
          const SizedBox(height: 24),
          
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(64),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: const [
                Icon(Icons.real_estate_agent_rounded, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text('Active loans and applications will appear here', style: TextStyle(color: Colors.grey, fontSize: 16)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
