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
  final ScrollController _horizontalScroll = ScrollController();
  
  String _searchQuery = "";
  
  String _selectedStatusFilter = "All";
  final List<String> _statusFilters = ["All", "Active", "Pending", "Delinquent", "Inactive"];
  
  String _selectedTimeFilter = "All Time";
  final List<String> _timeFilters = ["All Time", "Today", "Last 7 Days", "Last 30 Days"];
  
  int _sortColumnIndex = 0;
  bool _sortAscending = true;

  // --- NEW: Pagination Variables ---
  int _currentPage = 0;
  final int _rowsPerPage = 15; // Set limit to 15!

  @override
  void dispose() {
    _horizontalScroll.dispose();
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
        bgColor = Colors.red.shade100;
        textColor = Colors.red.shade800;
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
          
          Row(
            children: [
              Expanded(
                flex: 2,
                child: TextField(
                  // Reset page to 0 when user types a new search
                  onChanged: (v) => setState(() { _searchQuery = v; _currentPage = 0; }),
                  decoration: const InputDecoration(
                    hintText: 'Search by Name or Client ID...', 
                    prefixIcon: Icon(Icons.search)
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                flex: 1,
                child: DropdownButtonFormField<String>(
                  value: _selectedStatusFilter,
                  decoration: const InputDecoration(
                    labelText: "Status",
                    prefixIcon: Icon(Icons.filter_list)
                  ),
                  items: _statusFilters.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                  onChanged: (val) {
                    if (val != null) {
                      setState(() { _selectedStatusFilter = val; _currentPage = 0; });
                    }
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                flex: 1,
                child: DropdownButtonFormField<String>(
                  value: _selectedTimeFilter,
                  decoration: const InputDecoration(
                    labelText: "Time Period",
                    prefixIcon: Icon(Icons.date_range)
                  ),
                  items: _timeFilters.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                  onChanged: (val) {
                    if (val != null) {
                      setState(() { _selectedTimeFilter = val; _currentPage = 0; });
                    }
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          StreamBuilder<List<Customer>>(
            stream: _service.getCustomers(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
              final list = snapshot.data ?? [];
              
              final now = DateTime.now();
              
              final filtered = list.where((c) {
                final query = _searchQuery.toLowerCase();
                final matchesSearch = c.fullName.toLowerCase().contains(query) || c.id.toLowerCase().contains(query);
                
                final matchesStatus = _selectedStatusFilter == 'All' || 
                                      c.status.toLowerCase() == _selectedStatusFilter.toLowerCase();
                
                bool matchesTime = true;
                if (_selectedTimeFilter == "Today") {
                  matchesTime = c.latestTransaction.year == now.year &&
                                c.latestTransaction.month == now.month &&
                                c.latestTransaction.day == now.day;
                } else if (_selectedTimeFilter == "Last 7 Days") {
                  matchesTime = now.difference(c.latestTransaction).inDays <= 7;
                } else if (_selectedTimeFilter == "Last 30 Days") {
                  matchesTime = now.difference(c.latestTransaction).inDays <= 30;
                }
                
                return matchesSearch && matchesStatus && matchesTime;
              }).toList();
              
              filtered.sort((a, b) {
                int comparison = 0;
                switch (_sortColumnIndex) {
                  case 0: comparison = a.id.compareTo(b.id); break;
                  case 1: comparison = a.fullName.toLowerCase().compareTo(b.fullName.toLowerCase()); break;
                  case 2: comparison = a.status.toLowerCase().compareTo(b.status.toLowerCase()); break;
                  case 5: comparison = a.latestTransaction.compareTo(b.latestTransaction); break;
                }
                return _sortAscending ? comparison : -comparison;
              });

              // --- NEW: Calculate Total Pages and Get the Slice of 15 Items ---
              final int totalItems = filtered.length;
              final int totalPages = (totalItems / _rowsPerPage).ceil();
              
              // Ensure we don't end up on a blank page if the list shrinks
              if (_currentPage >= totalPages && totalPages > 0) {
                _currentPage = totalPages - 1;
              }

              // Extract only the 15 customers for the current page
              final paginatedList = filtered
                  .skip(_currentPage * _rowsPerPage)
                  .take(_rowsPerPage)
                  .toList();
              
              return Column(
                children: [
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
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
                                  DataColumn(label: const Text('Client ID'), onSort: _onSort), 
                                  DataColumn(label: const Text('Name'), onSort: _onSort), 
                                  DataColumn(label: const Text('Status'), onSort: _onSort), 
                                  const DataColumn(label: Text('Address')), 
                                  const DataColumn(label: Text('Mobile')), 
                                  DataColumn(label: const Text('Last Transaction'), onSort: _onSort), 
                                ],
                                // Use paginatedList instead of filtered!
                                rows: paginatedList.map((c) => DataRow(
                                  onSelectChanged: (_) => showDialog(
                                    context: stablePageContext, 
                                    builder: (_) => CustomerDetailDialog(customer: c, parentContext: stablePageContext)
                                  ),
                                  cells: [
                                    DataCell(Text(c.id, style: const TextStyle(fontWeight: FontWeight.bold))), 
                                    DataCell(Text(c.fullName)), 
                                    DataCell(_buildStatusBadge(c.status)), 
                                    DataCell(Text(c.address)), 
                                    DataCell(Text(c.mobile)),
                                    DataCell(Text(DateFormat('MMM d, yyyy').format(c.latestTransaction))),
                                  ],
                                )).toList(),
                              ),
                            ),
                          ),
                        );
                      }
                    ),
                  ),
                  
                  // --- NEW: Pagination Controls (Prev / Next Buttons) ---
                  if (totalPages > 1) 
                    Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text("Page ${_currentPage + 1} of $totalPages", style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
                          const SizedBox(width: 16),
                          IconButton(
                            icon: const Icon(Icons.chevron_left),
                            onPressed: _currentPage > 0 
                              ? () => setState(() => _currentPage--) 
                              : null,
                          ),
                          IconButton(
                            icon: const Icon(Icons.chevron_right),
                            onPressed: _currentPage < totalPages - 1 
                              ? () => setState(() => _currentPage++) 
                              : null,
                          ),
                        ],
                      ),
                    )
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}