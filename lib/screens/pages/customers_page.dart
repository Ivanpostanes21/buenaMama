import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../../models/customer.dart';
import '../../services/firestore_service.dart';
import '../../theme/app_colors.dart';
import '../../widgets/stat_card.dart';
import '../../widgets/loan_application_flow.dart';

// --- CUSTOM MONEY FORMATTER ---
class ThousandsFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.isEmpty) return newValue;
    
    String clean = newValue.text.replaceAll(RegExp(r'[^0-9.]'), '');
    if ('.'.allMatches(clean).length > 1) clean = oldValue.text.replaceAll(',', ''); 

    List<String> parts = clean.split('.');
    String intPart = parts[0];
    
    if (intPart.isNotEmpty) {
      intPart = NumberFormat('#,###', 'en_US').format(int.parse(intPart));
    }
    
    String result = intPart;
    if (parts.length > 1) {
      result += '.${parts[1]}';
    } else if (clean.endsWith('.')) {
      result += '.';
    }

    return TextEditingValue(
      text: result,
      selection: TextSelection.collapsed(offset: result.length),
    );
  }
}

// --- MAIN PAGE ---
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
                // Only process sorting for index 0, 1, and 4
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
                    // REMOVED onSort FROM ADDRESS AND MOBILE
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

// --- DETAIL DIALOG ---
class CustomerDetailDialog extends StatelessWidget {
  final Customer customer;
  final BuildContext parentContext;
  final FirestoreService _service = FirestoreService();
  
  CustomerDetailDialog({super.key, required this.customer, required this.parentContext});

  @override
  Widget build(BuildContext context) {
    String formattedIncome = NumberFormat('#,##0.00').format(customer.monthlyIncome);
    String formattedLoan = NumberFormat('#,##0.00').format(customer.loanAmount);
    String formattedDue = NumberFormat('#,##0.00').format(customer.monthlyDue);

    return AlertDialog(
      title: Text(customer.fullName, style: const TextStyle(fontWeight: FontWeight.bold)),
      content: SizedBox(
        width: 600, 
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Client ID: ${customer.id}", style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryGreen, fontSize: 16)),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: customer.status.toLowerCase() == 'active' ? Colors.green.shade100 : Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(customer.status.toUpperCase(), style: TextStyle(
                      color: customer.status.toLowerCase() == 'active' ? Colors.green.shade800 : Colors.grey.shade800,
                      fontWeight: FontWeight.bold,
                      fontSize: 12
                    )),
                  )
                ],
              ),
              const SizedBox(height: 16),
              
              const Text("PERSONAL INFORMATION", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.grey)),
              const Divider(),
              _buildInfoRow("Address", customer.address),
              _buildInfoRow("Mobile", customer.mobile),
              _buildInfoRow("Email", customer.email.isNotEmpty ? customer.email : "N/A"),
              _buildInfoRow("Messenger", customer.messenger.isNotEmpty ? customer.messenger : "N/A"),
              _buildInfoRow("Date of Birth", "${customer.dob.month}/${customer.dob.day}/${customer.dob.year} (Age: ${customer.age.toInt()})"),
              _buildInfoRow("Civil Status", customer.civilStatus),
              if (customer.spouseName.isNotEmpty) _buildInfoRow("Spouse", customer.spouseName),
              const SizedBox(height: 16),

              const Text("FINANCIAL INFORMATION", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.grey)),
              const Divider(),
              _buildInfoRow("Employment", "${customer.employmentStatus} ${customer.employer.isNotEmpty ? 'at ${customer.employer}' : ''}"),
              _buildInfoRow("Other Income", customer.otherIncome.isNotEmpty ? customer.otherIncome : "None"),
              _buildInfoRow("Household Income", "₱$formattedIncome / month"),
              const SizedBox(height: 16),

              const Text("LOAN INFORMATION", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.grey)),
              const Divider(),
              if (customer.loanAmount > 0) ...[
                _buildInfoRow("Category", customer.loanCategory),
                _buildInfoRow("Principal Amount", "₱$formattedLoan"),
                _buildInfoRow("Interest Rate", "${customer.loanRate.toStringAsFixed(1)}%"),
                _buildInfoRow("Term", "${customer.loanTerm.toInt()} Period(s)"),
                _buildInfoRow("Payment Structure", customer.paymentStructure),
                _buildInfoRow("Monthly Due", "₱$formattedDue"),
                const SizedBox(height: 16),
                
                const Text("CO-MAKER INFORMATION", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.grey)),
                const Divider(),
                _buildInfoRow("Name", customer.coMakerName),
                _buildInfoRow("Address", customer.coMakerAddress),
                _buildInfoRow("Contact No.", customer.coMakerMobile),
                if (customer.coMakerMessenger.isNotEmpty) _buildInfoRow("Messenger", customer.coMakerMessenger),
              ] else ...[
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.0),
                  child: Text("No active loan recorded for this profile.", style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey)),
                ),
              ]
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text("Close")),
        IconButton(
          icon: const Icon(Icons.delete, color: Colors.red), 
          tooltip: "Delete Customer",
          onPressed: () async {
            bool confirmDelete = await showDialog(
              context: context,
              builder: (c) => AlertDialog(
                title: const Text("Delete Customer?"),
                content: Text("Are you sure you want to permanently delete ${customer.firstName}'s profile?"),
                actions: [
                  TextButton(onPressed: () => Navigator.pop(c, false), child: const Text("Cancel")),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
                    onPressed: () => Navigator.pop(c, true), 
                    child: const Text("Delete")
                  )
                ],
              )
            ) ?? false;

            if (confirmDelete) {
              await _service.deleteCustomer(customer.id);
              if (context.mounted) Navigator.pop(context);
            }
          },
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryGreen, foregroundColor: Colors.white),
          onPressed: () {
            Navigator.pop(context); 
            if (parentContext.mounted) {
              showDialog(context: parentContext, builder: (_) => CustomerFormDialog(customer: customer));
            }
          }, 
          child: const Text("Edit Profile")
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 150, child: Text(label, style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.black87))),
          Expanded(child: Text(value, style: const TextStyle(color: Colors.black54))),
        ],
      ),
    );
  }
}

// --- FULL FORM DIALOG ---
class CustomerFormDialog extends StatefulWidget {
  final Customer? customer;
  const CustomerFormDialog({super.key, this.customer});
  @override
  State<CustomerFormDialog> createState() => _CustomerFormDialogState();
}

class _CustomerFormDialogState extends State<CustomerFormDialog> {
  final _fKey = GlobalKey<FormState>();
  final _service = FirestoreService();
  bool _isSaving = false; 
  
  final _clientIdPrefix = TextEditingController(); 
  final _fName = TextEditingController();
  final _mName = TextEditingController();
  final _lName = TextEditingController();
  final _address = TextEditingController();
  final _mobile = TextEditingController();
  final _email = TextEditingController();
  final _messenger = TextEditingController();
  final _dob = TextEditingController();
  final _spouse = TextEditingController();
  final _age = TextEditingController();
  final _civilStatus = TextEditingController();
  
  final _customEmpStatus = TextEditingController(); 
  final _employer = TextEditingController();
  final _otherIncome = TextEditingController();
  final _income = TextEditingController();

  String? _selectedEmpStatus; 
  final List<String> _empOptions = ['Employed', 'Self-Employed', 'Unemployed', 'Retired', 'Student', 'Other'];

  @override
  void initState() {
    super.initState();
    if (widget.customer != null) {
      _fName.text = widget.customer!.firstName;
      _mName.text = widget.customer!.middleName;
      _lName.text = widget.customer!.lastName;
      _address.text = widget.customer!.address;
      _mobile.text = widget.customer!.mobile;
      _email.text = widget.customer!.email;
      _messenger.text = widget.customer!.messenger;
      _dob.text = DateFormat('yyyy-MM-dd').format(widget.customer!.dob);
      _spouse.text = widget.customer!.spouseName;
      _age.text = widget.customer!.age.toInt().toString();
      _civilStatus.text = widget.customer!.civilStatus;
      
      if (_empOptions.contains(widget.customer!.employmentStatus)) {
        _selectedEmpStatus = widget.customer!.employmentStatus;
      } else if (widget.customer!.employmentStatus.isNotEmpty) {
        _selectedEmpStatus = 'Other'; 
        _customEmpStatus.text = widget.customer!.employmentStatus; 
      }

      _employer.text = widget.customer!.employer;
      _otherIncome.text = widget.customer!.otherIncome;
      
      _income.text = widget.customer!.monthlyIncome > 0 
          ? NumberFormat('#,###.##', 'en_US').format(widget.customer!.monthlyIncome) 
          : '';
    }
  }

  @override
  void dispose() {
    _clientIdPrefix.dispose();
    _fName.dispose(); _mName.dispose(); _lName.dispose();
    _address.dispose(); _mobile.dispose(); _email.dispose();
    _messenger.dispose(); _dob.dispose(); _spouse.dispose();
    _age.dispose(); _civilStatus.dispose();
    _customEmpStatus.dispose();
    _employer.dispose(); _otherIncome.dispose(); _income.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: 750, 
        height: MediaQuery.of(context).size.height * 0.8, 
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _fKey, 
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("CUSTOMER PROFILE", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                const SizedBox(height: 16),
                
                if (widget.customer == null) ...[
                  SizedBox(
                    width: 200,
                    child: TextFormField(
                      controller: _clientIdPrefix,
                      maxLength: 3,
                      textCapitalization: TextCapitalization.characters,
                      decoration: const InputDecoration(
                        labelText: "Client ID Prefix", 
                        hintText: "e.g. ABC",
                        counterText: "",
                      ),
                      validator: (v) {
                        if (v == null || v.trim().length != 3 || !RegExp(r'^[a-zA-Z]+$').hasMatch(v)) {
                          return "Must be exactly 3 letters";
                        }
                        return null;
                      },
                    ),
                  ),
                  const Text("4 random numbers will be generated automatically.", style: TextStyle(fontSize: 12, color: Colors.grey)),
                  const SizedBox(height: 16),
                ] else ...[
                  Text("Client ID: ${widget.customer!.id}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.primaryGreen)),
                  const SizedBox(height: 16),
                ],

                Row(children: [
                  Expanded(child: TextFormField(controller: _fName, decoration: const InputDecoration(labelText: "First Name"))),
                  const SizedBox(width: 8),
                  Expanded(child: TextFormField(controller: _mName, decoration: const InputDecoration(labelText: "Middle Name"))),
                  const SizedBox(width: 8),
                  Expanded(child: TextFormField(controller: _lName, decoration: const InputDecoration(labelText: "Last Name"))),
                ]),
                TextFormField(controller: _address, decoration: const InputDecoration(labelText: "Complete Address")),
                Row(children: [
                  Expanded(
                    child: TextFormField(
                      controller: _mobile, 
                      decoration: const InputDecoration(labelText: "Mobile"),
                      keyboardType: TextInputType.phone, 
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly], 
                    )
                  ),
                  const SizedBox(width: 8),
                  Expanded(child: TextFormField(controller: _email, decoration: const InputDecoration(labelText: "Email"))),
                  const SizedBox(width: 8),
                  Expanded(child: TextFormField(controller: _messenger, decoration: const InputDecoration(labelText: "Messenger"))),
                ]),
                Row(children: [
                  Expanded(
                    child: TextFormField(
                      controller: _dob, 
                      readOnly: true, 
                      decoration: const InputDecoration(
                        labelText: "Date of Birth",
                        suffixIcon: Icon(Icons.calendar_today),
                      ),
                      onTap: () async {
                        DateTime initialDate = DateTime.now();
                        try {
                          if (_dob.text.isNotEmpty) initialDate = DateFormat('yyyy-MM-dd').parse(_dob.text);
                        } catch (_) {}

                        DateTime? pickedDate = await showDatePicker(
                          context: context,
                          initialDate: initialDate,
                          firstDate: DateTime(1900),
                          lastDate: DateTime.now(),
                        );
                        
                        if (pickedDate != null) {
                          setState(() {
                            _dob.text = DateFormat('yyyy-MM-dd').format(pickedDate);
                            int calculatedAge = DateTime.now().year - pickedDate.year;
                            if (DateTime.now().month < pickedDate.month || 
                               (DateTime.now().month == pickedDate.month && DateTime.now().day < pickedDate.day)) {
                              calculatedAge--;
                            }
                            _age.text = calculatedAge.toString();
                          });
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextFormField(
                      controller: _age, 
                      decoration: const InputDecoration(labelText: "Age"),
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly], 
                    )
                  ),
                  const SizedBox(width: 8),
                  Expanded(child: TextFormField(controller: _civilStatus, decoration: const InputDecoration(labelText: "Civil Status"))),
                ]),
                TextFormField(controller: _spouse, decoration: const InputDecoration(labelText: "Name of Spouse")),
                Row(children: [
                   Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _selectedEmpStatus,
                      decoration: const InputDecoration(labelText: "Employment Status"),
                      items: _empOptions.map((status) => DropdownMenuItem(value: status, child: Text(status))).toList(),
                      onChanged: (val) {
                        setState(() {
                          _selectedEmpStatus = val;
                          if (val != 'Other') _customEmpStatus.clear();
                        });
                      },
                    )
                   ),
                   if (_selectedEmpStatus == 'Other') ...[
                     const SizedBox(width: 8),
                     Expanded(
                       child: TextFormField(
                         controller: _customEmpStatus,
                         decoration: const InputDecoration(labelText: "Please specify"),
                         validator: (v) => v == null || v.isEmpty ? "Please specify status" : null,
                       )
                     ),
                   ],
                   const SizedBox(width: 8),
                   Expanded(child: TextFormField(controller: _employer, decoration: const InputDecoration(labelText: "Employer"))),
                ]),
                Row(children: [
                   Expanded(
                    child: TextFormField(
                      controller: _otherIncome, 
                      decoration: const InputDecoration(labelText: "Other Source of Income (e.g. Freelance)"),
                    )
                   ),
                   const SizedBox(width: 8),
                   Expanded(
                    child: TextFormField(
                      controller: _income, 
                      decoration: const InputDecoration(labelText: "Household Monthly Income (₱)"),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [ThousandsFormatter()], 
                    )
                   ),
                ]),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryGreen,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: _isSaving ? null : () async {
                        if (_fKey.currentState!.validate()) {
                          setState(() => _isSaving = true);
                          
                          bool isNewCustomer = widget.customer == null;
                          String finalId = widget.customer?.id ?? '';

                          if (isNewCustomer) {
                            String prefix = _clientIdPrefix.text.toUpperCase();
                            bool isUnique = false;
                            
                            while (!isUnique) {
                              String randomDigits = (1000 + Random().nextInt(9000)).toString();
                              finalId = '$prefix-$randomDigits'; 
                              
                              final docCheck = await FirebaseFirestore.instance.collection('customers').doc(finalId).get();
                              if (!docCheck.exists) {
                                isUnique = true;
                              }
                            }
                          }

                          DateTime parsedDob;
                          try {
                            parsedDob = DateFormat('yyyy-MM-dd').parse(_dob.text);
                          } catch (_) {
                            parsedDob = DateTime.now();
                          }

                          String finalEmpStatus = _selectedEmpStatus == 'Other' 
                              ? _customEmpStatus.text 
                              : (_selectedEmpStatus ?? '');

                          final updatedCustomer = Customer(
                            id: finalId, 
                            firstName: _fName.text,
                            middleName: _mName.text,
                            lastName: _lName.text,
                            address: _address.text,
                            mobile: _mobile.text,
                            email: _email.text,
                            messenger: _messenger.text,
                            dob: parsedDob,
                            spouseName: _spouse.text,
                            employmentStatus: finalEmpStatus, 
                            civilStatus: _civilStatus.text,
                            employer: _employer.text,
                            otherIncome: _otherIncome.text,
                            age: double.tryParse(_age.text) ?? 0,
                            monthlyIncome: double.tryParse(_income.text.replaceAll(',', '')) ?? 0,
                            
                            loanCategory: widget.customer?.loanCategory ?? '',
                            paymentStructure: widget.customer?.paymentStructure ?? '',
                            loanAmount: widget.customer?.loanAmount ?? 0,
                            loanRate: widget.customer?.loanRate ?? 0,
                            loanTerm: widget.customer?.loanTerm ?? 0,
                            monthlyDue: widget.customer?.monthlyDue ?? 0,
                            coMakerName: widget.customer?.coMakerName ?? '',
                            coMakerAddress: widget.customer?.coMakerAddress ?? '',
                            coMakerMobile: widget.customer?.coMakerMobile ?? '',
                            coMakerMessenger: widget.customer?.coMakerMessenger ?? '',
                            coMakerDob: widget.customer?.coMakerDob ?? DateTime.now(),
                            latestTransaction: DateTime.now(),
                          );

                          await _service.saveCustomer(updatedCustomer, !isNewCustomer);
                          
                          if (mounted) {
                            Navigator.pop(context, isNewCustomer ? updatedCustomer : null);
                          }
                        }
                      }, 
                      child: _isSaving ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Text("Save")
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}