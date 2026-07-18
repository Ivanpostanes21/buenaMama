import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/customer.dart';
import '../../services/firestore_service.dart';
import '../../theme/app_colors.dart';
import '../../widgets/stat_card.dart';
import '../../dialogs/loanPage/loan_application_flow.dart';
import '../../dialogs/customerPage/customer_detail_dialog.dart';
import '../../dialogs/customerPage/customer_form_dialog.dart';

class CustomersPage extends StatefulWidget {
  final bool isGuest;
  const CustomersPage({super.key, required this.isGuest});
  @override
  State<CustomersPage> createState() => _CustomersPageState();
}

class _CustomersPageState extends State<CustomersPage> {
  final FirestoreService _service = FirestoreService();
  String _searchQuery = "";
  int _sortColumnIndex = 0;
  bool _sortAscending = true;

  void _onSort(int columnIndex, bool ascending) {
    setState(() {
      _sortColumnIndex = columnIndex;
      _sortAscending = ascending;
    });
  }

  @override
  Widget build(BuildContext context) {
    final stablePageContext = context; 

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(28, 24, 28, 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: const [
              Text('Customers', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: AppColors.heading)),
              Text('Manage borrower profiles.', style: TextStyle(fontSize: 13.5, color: AppColors.muted)),
            ]),
            if (!widget.isGuest)
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryGreen,
                  foregroundColor: Colors.white,
                ),
                onPressed: () async {
                  final newCustomer = await showDialog(
                    context: stablePageContext, 
                    builder: (_) => const CustomerFormDialog()
                  );
                  
                  if (newCustomer != null && newCustomer is Customer && stablePageContext.mounted) {
                    showDialog(
                      context: stablePageContext,
                      builder: (alertContext) => AlertDialog(
                        title: const Text("Profile Saved!"),
                        content: Text("Do you want to apply for a loan for ${newCustomer.firstName} now?"),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(alertContext), 
                            child: const Text("Not Now")
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryGreen,
                              foregroundColor: Colors.white,
                            ),
                            onPressed: () {
                              Navigator.pop(alertContext);
                              showDialog(
                                context: stablePageContext, 
                                builder: (_) => SeparateLoanFormDialog(
                                  customer: newCustomer, 
                                  applicationType: "New"
                                )
                              );
                            }, 
                            child: const Text("Apply for Loan")
                          )
                        ],
                      )
                    );
                  }
                },
                icon: const Icon(Icons.add), label: const Text('Add Customer'),
              ),
          ]),
          const SizedBox(height: 24),
          
          StreamBuilder<List<Customer>>(
            stream: _service.getCustomers(),
            builder: (context, snapshot) {
              final list = snapshot.data ?? [];
              final activeCount = list.where((c) => c.status.toLowerCase() == 'active').length;
              return StatCardRow(stats: [
                StatData(icon: Icons.people_alt, label: 'Total Customers', value: list.length.toString()),
                StatData(icon: Icons.check_circle, label: 'Active', value: activeCount.toString()),
                StatData(icon: Icons.pending_actions, label: 'Pending', value: '0'),
              ]);
            },
          ),
          const SizedBox(height: 24),
          
          TextField(
            onChanged: (v) => setState(() => _searchQuery = v),
            decoration: const InputDecoration(hintText: 'Search by Name or Client ID...', prefixIcon: Icon(Icons.search)),
          ),
          const SizedBox(height: 16),
          
          StreamBuilder<List<Customer>>(
            stream: _service.getCustomers(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
              final list = snapshot.data ?? [];
              
              final filtered = list.where((c) {
                final query = _searchQuery.toLowerCase();
                return c.fullName.toLowerCase().contains(query) || 
                       c.id.toLowerCase().contains(query);
              }).toList();
              
              filtered.sort((a, b) {
                int comparison = 0;
                switch (_sortColumnIndex) {
                  case 0:
                    comparison = a.id.compareTo(b.id);
                    break;
                  case 1:
                    comparison = a.fullName.toLowerCase().compareTo(b.fullName.toLowerCase());
                    break;
                  case 4:
                    comparison = a.latestTransaction.compareTo(b.latestTransaction);
                    break;
                }
                return _sortAscending ? comparison : -comparison;
              });
              
              return Container(
                width: double.infinity,
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
                child: DataTable(
                  showCheckboxColumn: false,
                  sortColumnIndex: _sortColumnIndex,
                  sortAscending: _sortAscending,
                  columns: [
                    DataColumn(label: const Text('Client ID'), onSort: _onSort), 
                    DataColumn(label: const Text('Name'), onSort: _onSort), 
                    const DataColumn(label: Text('Address')), 
                    const DataColumn(label: Text('Mobile')), 
                    DataColumn(label: const Text('Last Transaction'), onSort: _onSort), 
                  ],
                  rows: filtered.map((c) => DataRow(
                    onSelectChanged: (_) => showDialog(
                      context: stablePageContext, 
                      builder: (_) => CustomerDetailDialog(customer: c, parentContext: stablePageContext)
                    ),
                    cells: [
                      DataCell(Text(c.id, style: const TextStyle(fontWeight: FontWeight.bold))), 
                      DataCell(Text(c.fullName)), 
                      DataCell(Text(c.address)), 
                      DataCell(Text(c.mobile)),
                      DataCell(Text(DateFormat('MMM d, yyyy').format(c.latestTransaction))),
                    ],
                  )).toList(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}