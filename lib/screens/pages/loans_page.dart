import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../models/loan.dart';
import '../../services/firestore_service.dart';
import '../../theme/app_colors.dart';
import '../../widgets/stat_card.dart';

import '../../dialogs/loanPage/loan_application_flow.dart';


class LoansPage extends StatefulWidget {
  const LoansPage({super.key});

  @override
  State<LoansPage> createState() => _LoansPageState();
}

class _LoansPageState extends State<LoansPage> {
  final FirestoreService _service = FirestoreService();
  final ScrollController _horizontalScroll = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  late Stream<List<Loan>> _loansStream; // ADDED: Stable stream reference
  
  String _searchQuery = "";
  int _sortColumnIndex = 0;
  bool _sortAscending = true;

  @override
  void initState() {
    super.initState();
    _loansStream = _service.getLoans(); // Initialize once
  }

  @override
  void dispose() {
    _horizontalScroll.dispose();
    _searchController.dispose(); // ADDED
    super.dispose();
  }
  void _onSort(int columnIndex, bool ascending) {
  setState(() {
    _sortColumnIndex = columnIndex;
    _sortAscending = ascending;
   });
  }
  Widget _buildStatusBadge(String status) {
    Color bgColor;
    Color textColor;
    
    switch (status.toLowerCase()) {
      case 'active':
        bgColor = Colors.green.shade100;
        textColor = Colors.green.shade800;
        break;
      case 'pending':
        bgColor = Colors.orange.shade100;
        textColor = Colors.orange.shade800;
        break;
      case 'delinquent':
      case 'past due':
        bgColor = Colors.red.shade100;
        textColor = Colors.red.shade800;
        break;
      case 'completed':
        bgColor = Colors.blue.shade100;
        textColor = Colors.blue.shade800;
        break;
      default:
        bgColor = Colors.grey.shade200;
        textColor = Colors.grey.shade800;
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status.toUpperCase(), 
        style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 12)
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Loan>>(
      stream: _loansStream, // Use the stable reference
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final loans = snapshot.data ?? [];

        int activeCount = 0;
        int pendingCount = 0;
        int pastDueCount = 0;
        double totalLoanAmount = 0; // Changed to track the base amount
        final filtered = loans.where((l) {
          final query = _searchQuery.toLowerCase();
          return l.customerName.toLowerCase().contains(query) || 
                 l.category.toLowerCase().contains(query);
        }).toList();
        filtered.sort((a, b) {
        int comparison = 0;
          switch (_sortColumnIndex) {
            case 0: comparison = a.customerName.toLowerCase().compareTo(b.customerName.toLowerCase()); break;
            case 4: comparison = a.status.toLowerCase().compareTo(b.status.toLowerCase()); break;
            case 5: comparison = a.dateApplied.compareTo(b.dateApplied); break;
          }
          return _sortAscending ? comparison : -comparison;
        });

        for (var loan in loans) {
          final status = loan.status.toLowerCase();
          
          if (status == 'active') {
            activeCount++;
            totalLoanAmount += loan.amount;
          } else if (status == 'pending') {
            pendingCount++;
          } else if (status == 'delinquent' || status == 'past due') {
            pastDueCount++;
            totalLoanAmount += loan.amount;
          } else if (status == 'completed') {
            totalLoanAmount += loan.amount;
          }
        }
        
        

        final formattedTotal = NumberFormat.compactCurrency(
          symbol: '₱', 
          decimalDigits: 2
        ).format(totalLoanAmount);

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
              
              StatCardRow(
                stats: [
                  StatData(icon: Icons.account_balance_wallet, label: 'Active Loans', value: activeCount.toString()),
                  // Updated label to reflect the total principal amount recorded
                  StatData(icon: Icons.monetization_on, label: 'Total Principal', value: formattedTotal),
                  StatData(icon: Icons.pending_actions, label: 'Pending Approvals', value: pendingCount.toString()),
                  StatData(icon: Icons.warning_amber_rounded, label: 'Past Due', value: pastDueCount.toString()),
                ],
              ),
              
              const SizedBox(height: 24),
              TextField(
                controller: _searchController, // ADDED: Prevents focus loss
                onChanged: (v) => setState(() => _searchQuery = v),
                decoration: const InputDecoration(
                  hintText: 'Search by Name or Category...', 
                  prefixIcon: Icon(Icons.search)
                ),
              ),
              const SizedBox(height: 16),
              if (loans.isEmpty)
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
                )
              else
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white, 
                    borderRadius: BorderRadius.circular(16)
                  ),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      return Scrollbar(
                        controller: _horizontalScroll,
                        thumbVisibility: true,
                        trackVisibility: true,
                        child: SingleChildScrollView(
                          controller: _horizontalScroll,
                          scrollDirection: Axis.horizontal,
                          child: ConstrainedBox(
                            constraints: BoxConstraints(minWidth: constraints.maxWidth),
                            child: DataTable(
                              showCheckboxColumn: false,
                              sortColumnIndex: _sortColumnIndex,
                              sortAscending: _sortAscending,
                              columns: [
                                DataColumn(label: const Text('Customer'), onSort: _onSort),
                                DataColumn(label: const Text('Category')),
                                DataColumn(label: const Text('Amount')),
                                DataColumn(label: const Text('Monthly Due')),
                                DataColumn(label: const Text('Status'), onSort: _onSort),
                                DataColumn(label: const Text('Date Applied'), onSort: _onSort),
                              ],
                              rows: filtered.map((loan) => DataRow(
                                cells: [
                                  DataCell(Text(loan.customerName, style: const TextStyle(fontWeight: FontWeight.bold))),
                                  DataCell(Text(loan.category)),
                                  DataCell(Text(NumberFormat.currency(symbol: '₱', decimalDigits: 2).format(loan.amount))),
                                  DataCell(Text(NumberFormat.currency(symbol: '₱', decimalDigits: 2).format(loan.monthlyDue))),
                                  DataCell(_buildStatusBadge(loan.status)),
                                  DataCell(Text(DateFormat('MMM d, yyyy').format(loan.dateApplied))),
                                ],
                              )).toList(),
                            ),
                          ),
                        ),
                      );
                    }
                  ),
                ),
            ],
          ),
        );
      }
    );
  }
}