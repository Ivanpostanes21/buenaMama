import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/customer.dart';
import '../../services/firestore_service.dart';
import '../../theme/app_colors.dart';
import '../../widgets/stat_card.dart';

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

  @override
  Widget build(BuildContext context) {
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
                // --- ADDED GREEN BACKGROUND AND WHITE TEXT HERE ---
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryGreen,
                  foregroundColor: Colors.white,
                ),
                onPressed: () => showDialog(context: context, builder: (_) => const CustomerFormDialog()),
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
            decoration: const InputDecoration(hintText: 'Search...', prefixIcon: Icon(Icons.search)),
          ),
          const SizedBox(height: 16),
          
          StreamBuilder<List<Customer>>(
            stream: _service.getCustomers(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
              final list = snapshot.data ?? [];
              final filtered = list.where((c) => c.fullName.toLowerCase().contains(_searchQuery.toLowerCase())).toList();
              
              return Container(
                width: double.infinity,
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
                child: DataTable(
                  showCheckboxColumn: false,
                  columns: const [
                    DataColumn(label: Text('Client ID')), 
                    DataColumn(label: Text('Name')), 
                    DataColumn(label: Text('Address')), 
                    DataColumn(label: Text('Mobile'))
                  ],
                  rows: filtered.map((c) => DataRow(
                    onSelectChanged: (_) => showDialog(context: context, builder: (_) => CustomerDetailDialog(customer: c)),
                    cells: [
                      DataCell(Text(c.id, style: const TextStyle(fontWeight: FontWeight.bold))), 
                      DataCell(Text(c.fullName)), 
                      DataCell(Text(c.address)), 
                      DataCell(Text(c.mobile))
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
  final FirestoreService _service = FirestoreService();
  CustomerDetailDialog({super.key, required this.customer});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("Profile: ${customer.fullName}"),
      content: SingleChildScrollView(
        child: ListBody(
          children: [
            Text("Client ID: ${customer.id}", style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryGreen)),
            const SizedBox(height: 8),
            Text("Address: ${customer.address}"),
            Text("Mobile: ${customer.mobile}"),
            Text("Email: ${customer.email}"),
            Text("Messenger: ${customer.messenger}"),
            Text("DOB: ${customer.dob.month}/${customer.dob.day}/${customer.dob.year}"),
            Text("Age: ${customer.age.toInt()}"),
            Text("Civil Status: ${customer.civilStatus}"),
            Text("Spouse: ${customer.spouseName}"),
            Text("Employment Status: ${customer.employmentStatus}"),
            Text("Employer: ${customer.employer}"),
            Text("Other Income: ${customer.otherIncome}"),
            Text("Monthly Household Income: ₱${customer.monthlyIncome}"),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text("Close")),
        IconButton(
          icon: const Icon(Icons.delete, color: Colors.red), 
          onPressed: () async {
            await _service.deleteCustomer(customer.id);
            if (context.mounted) Navigator.pop(context);
          },
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
            showDialog(context: context, builder: (_) => CustomerFormDialog(customer: customer));
          }, 
          child: const Text("Edit")
        ),
      ],
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
  final _empStatus = TextEditingController();
  final _employer = TextEditingController();
  final _otherIncome = TextEditingController();
  final _income = TextEditingController();

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
      _empStatus.text = widget.customer!.employmentStatus;
      _employer.text = widget.customer!.employer;
      _otherIncome.text = widget.customer!.otherIncome;
      _income.text = widget.customer!.monthlyIncome.toString();
    }
  }

  @override
  void dispose() {
    _clientIdPrefix.dispose();
    _fName.dispose(); _mName.dispose(); _lName.dispose();
    _address.dispose(); _mobile.dispose(); _email.dispose();
    _messenger.dispose(); _dob.dispose(); _spouse.dispose();
    _age.dispose(); _civilStatus.dispose(); _empStatus.dispose();
    _employer.dispose(); _otherIncome.dispose(); _income.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: 650, 
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
                  Expanded(child: TextFormField(controller: _mobile, decoration: const InputDecoration(labelText: "Mobile"))),
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
                  Expanded(child: TextFormField(controller: _age, decoration: const InputDecoration(labelText: "Age"))),
                  const SizedBox(width: 8),
                  Expanded(child: TextFormField(controller: _civilStatus, decoration: const InputDecoration(labelText: "Civil Status"))),
                ]),
                TextFormField(controller: _spouse, decoration: const InputDecoration(labelText: "Name of Spouse")),
                Row(children: [
                   Expanded(child: TextFormField(controller: _empStatus, decoration: const InputDecoration(labelText: "Employment Status"))),
                   const SizedBox(width: 8),
                   Expanded(child: TextFormField(controller: _employer, decoration: const InputDecoration(labelText: "Employer"))),
                ]),
                Row(children: [
                   Expanded(child: TextFormField(controller: _otherIncome, decoration: const InputDecoration(labelText: "Other Source of Income"))),
                   const SizedBox(width: 8),
                   Expanded(child: TextFormField(controller: _income, decoration: const InputDecoration(labelText: "Household Monthly Income"))),
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
                          
                          String finalId = widget.customer?.id ?? '';

                          if (widget.customer == null) {
                            String prefix = _clientIdPrefix.text.toUpperCase();
                            bool isUnique = false;
                            
                            while (!isUnique) {
                              String randomDigits = (1000 + Random().nextInt(9000)).toString();
                              finalId = '$prefix$randomDigits';
                              
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
                            employmentStatus: _empStatus.text,
                            civilStatus: _civilStatus.text,
                            employer: _employer.text,
                            otherIncome: _otherIncome.text,
                            age: double.tryParse(_age.text) ?? 0,
                            monthlyIncome: double.tryParse(_income.text) ?? 0,
                            
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

                          await _service.saveCustomer(updatedCustomer, widget.customer != null);
                          if (mounted) Navigator.pop(context);
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
