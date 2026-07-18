import 'dart:math'; // Required for pow()
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Required for TextInputFormatter
import 'package:intl/intl.dart';
import '../../models/customer.dart';
import '../../models/loan.dart';
import '../../services/firestore_service.dart';
import '../../theme/app_colors.dart';
import '../customerPage/customer_form_dialog.dart';

class LoanApplicationFlow {
  static void start(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Apply for a Loan", style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text("Select the type of loan application:"),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryGreen, foregroundColor: Colors.white),
            onPressed: () {
              Navigator.pop(context); 
              showDialog(context: context, builder: (_) => const CustomerFormDialog());
            },
            child: const Text("New"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryGreen, foregroundColor: Colors.white),
            onPressed: () {
              Navigator.pop(context);
              _showCustomerSearch(context, "Renew Loan");
            },
            child: const Text("Renew"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryGreen, foregroundColor: Colors.white),
            onPressed: () {
              Navigator.pop(context);
              _showCustomerSearch(context, "Reloan");
            },
            child: const Text("Reloan"),
          ),
        ],
      ),
    );
  }

  static void _showCustomerSearch(BuildContext context, String loanType) {
    showDialog(
      context: context,
      builder: (_) => CustomerSearchDialog(loanType: loanType),
    );
  }
}

class CustomerSearchDialog extends StatefulWidget {
  final String loanType;
  const CustomerSearchDialog({super.key, required this.loanType});
  @override
  State<CustomerSearchDialog> createState() => _CustomerSearchDialogState();
}

class _CustomerSearchDialogState extends State<CustomerSearchDialog> {
  final FirestoreService _service = FirestoreService();
  String _searchQuery = "";

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: 500,
        height: 600,
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Search Customer for ${widget.loanType}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 16),
            TextField(
              onChanged: (v) => setState(() => _searchQuery = v),
              decoration: const InputDecoration(
                hintText: "Search by name or ID...",
                prefixIcon: Icon(Icons.search),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: StreamBuilder<List<Customer>>(
                stream: _service.getCustomers(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
                  
                  final list = snapshot.data ?? [];
                  final filtered = list.where((c) => 
                    c.fullName.toLowerCase().contains(_searchQuery.toLowerCase()) || 
                    c.id.toLowerCase().contains(_searchQuery.toLowerCase())
                  ).toList();

                  if (filtered.isEmpty) {
                    return const Center(child: Text("No customers found."));
                  }

                  return ListView.builder(
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final c = filtered[index];
                      return ListTile(
                        leading: CircleAvatar(backgroundColor: AppColors.primaryGreen, foregroundColor: Colors.white, child: Text(c.id.substring(0, 1))),
                        title: Text(c.fullName, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text("ID: ${c.id} | Status: ${c.status}"),
                        trailing: ElevatedButton(
                          style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryGreen, foregroundColor: Colors.white),
                          onPressed: () {
                            Navigator.pop(context); 
                            showDialog(context: context, builder: (_) => SeparateLoanFormDialog(customer: c, applicationType: widget.loanType));
                          },
                          child: const Text("Select"),
                        ),
                      );
                    },
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}

class SeparateLoanFormDialog extends StatefulWidget {
  final Customer customer;
  final String applicationType; 

  const SeparateLoanFormDialog({super.key, required this.customer, required this.applicationType});

  @override
  State<SeparateLoanFormDialog> createState() => _SeparateLoanFormDialogState();
}

class _SeparateLoanFormDialogState extends State<SeparateLoanFormDialog> {
  final _fKey = GlobalKey<FormState>();
  final _service = FirestoreService();
  bool _isSaving = false;

  final _category = TextEditingController();
  final _amount = TextEditingController();
  final _rate = TextEditingController();
  final _term = TextEditingController();
  final _paymentStructure = TextEditingController();
  final _monthlyDue = TextEditingController();

  TextEditingController? _cmNameController;
  final _cmAddress = TextEditingController();
  final _cmDob = TextEditingController();
  final _cmContact = TextEditingController();
  final _cmMessenger = TextEditingController();

  List<Customer> _allCustomers = [];

  @override
  void initState() {
    super.initState();
    _amount.addListener(_calculateDue);
    _rate.addListener(_calculateDue);
    _term.addListener(_calculateDue);

    _service.getCustomers().first.then((customers) {
      if (mounted) {
        setState(() {
          _allCustomers = customers;
        });
      }
    });
  }

  @override
  void dispose() {
    _category.dispose();
    _amount.dispose();
    _rate.dispose();
    _term.dispose();
    _paymentStructure.dispose();
    _monthlyDue.dispose();
    _cmAddress.dispose();
    _cmDob.dispose();
    _cmContact.dispose();
    _cmMessenger.dispose();
    super.dispose();
  }

  void _calculateDue() {
    // Strip commas out before doing math
    final amount = double.tryParse(_amount.text.replaceAll(',', '')) ?? 0;
    final rate = double.tryParse(_rate.text) ?? 0;
    final term = double.tryParse(_term.text) ?? 0;

    if (amount > 0 && rate >= 0 && term > 0) {
      final totalInterest = amount * (rate / 100) * term;
      final totalAmount = amount + totalInterest;
      final monthly = totalAmount / term;
      
      // Format the result with commas
      _monthlyDue.text = NumberFormat('#,##0.00').format(monthly);
    } else {
      _monthlyDue.text = ''; 
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: 700,
        height: MediaQuery.of(context).size.height * 0.85,
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _fKey, 
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("${widget.applicationType} - ${widget.customer.fullName} (${widget.customer.id})", 
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)
                ),
                const SizedBox(height: 16),
                
                const Text("Loan Info", style: TextStyle(fontWeight: FontWeight.w600)),
                const Divider(),
                Row(children: [
                  Expanded(
                    child: TextFormField(
                      controller: _category, 
                      decoration: const InputDecoration(labelText: "Category *"),
                      validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                    )
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextFormField(
                      controller: _amount, 
                      keyboardType: TextInputType.number,
                      // Apply the comma formatter here
                      inputFormatters: [ThousandsFormatter()], 
                      decoration: const InputDecoration(labelText: "Principal Amount (₱) *"),
                      validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                    )
                  ),
                ]),
                Row(children: [
                  Expanded(
                    child: TextFormField(
                      controller: _rate, 
                      keyboardType: TextInputType.number, 
                      decoration: const InputDecoration(labelText: "Rate (%) *"),
                      validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                    )
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextFormField(
                      controller: _term, 
                      keyboardType: TextInputType.number, 
                      decoration: const InputDecoration(labelText: "Term (Months) *"),
                      validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                    )
                  ),
                ]),
                Row(children: [
                  Expanded(
                    child: TextFormField(
                      controller: _paymentStructure, 
                      decoration: const InputDecoration(labelText: "Payment Structure *"),
                      validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                    )
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextFormField(
                      controller: _monthlyDue, 
                      readOnly: true, 
                      keyboardType: TextInputType.number, 
                      decoration: InputDecoration(
                        labelText: "Monthly Due (₱) *",
                        filled: true,
                        fillColor: Colors.grey.shade100, 
                      ),
                      validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                    )
                  ),
                ]),
                const SizedBox(height: 24),

                const Text("Co-Maker's Information", style: TextStyle(fontWeight: FontWeight.w600)),
                const Divider(),
                
                Autocomplete<Customer>(
                  optionsBuilder: (TextEditingValue textEditingValue) {
                    if (textEditingValue.text.isEmpty) {
                      return const Iterable<Customer>.empty();
                    }
                    return _allCustomers.where((Customer option) {
                      return option.fullName.toLowerCase().contains(textEditingValue.text.toLowerCase());
                    });
                  },
                  displayStringForOption: (Customer option) => option.fullName,
                  onSelected: (Customer selection) {
                    _cmAddress.text = selection.address;
                    _cmDob.text = DateFormat('yyyy-MM-dd').format(selection.dob);
                    _cmContact.text = selection.mobile;
                    _cmMessenger.text = selection.messenger;
                  },
                  fieldViewBuilder: (context, controller, focusNode, onEditingComplete) {
                    _cmNameController = controller;
                    return TextFormField(
                      controller: controller,
                      focusNode: focusNode,
                      decoration: const InputDecoration(
                        labelText: "Name *",
                        hintText: "Type to search existing customers..."
                      ),
                      validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                    );
                  },
                ),

                TextFormField(
                  controller: _cmAddress, 
                  decoration: const InputDecoration(labelText: "Address *"),
                  validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                ),
                Row(children: [
                  Expanded(
                    child: TextFormField(
                      controller: _cmDob, 
                      readOnly: true, 
                      decoration: const InputDecoration(labelText: "Date of Birth *", suffixIcon: Icon(Icons.calendar_today)),
                      validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                      onTap: () async {
                        DateTime? pickedDate = await showDatePicker(
                          context: context, initialDate: DateTime.now(), firstDate: DateTime(1900), lastDate: DateTime.now(),
                        );
                        if (pickedDate != null) {
                          setState(() => _cmDob.text = DateFormat('yyyy-MM-dd').format(pickedDate));
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextFormField(
                      controller: _cmContact, 
                      decoration: const InputDecoration(labelText: "Contact No. *"),
                      validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                      )),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextFormField(
                      controller: _cmMessenger, 
                      decoration: const InputDecoration(labelText: "Messenger *"),
                      validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                    )
                  ),
                ]),

                const SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryGreen, foregroundColor: Colors.white),
                      onPressed: _isSaving ? null : () async {
                        if (_fKey.currentState!.validate()) { 
                          setState(() => _isSaving = true);
                          
                          DateTime cmParsedDob;
                          try { cmParsedDob = DateFormat('yyyy-MM-dd').parse(_cmDob.text); } 
                          catch (_) { cmParsedDob = DateTime.now(); }

                          final newLoan = Loan(
                            id: '', 
                            customerId: widget.customer.id,
                            customerName: widget.customer.fullName,
                            category: _category.text,
                            // Strip commas out before saving to Firestore
                            amount: double.tryParse(_amount.text.replaceAll(',', '')) ?? 0,
                            rate: double.tryParse(_rate.text) ?? 0,
                            term: double.tryParse(_term.text) ?? 0,
                            paymentStructure: _paymentStructure.text,
                            monthlyDue: double.tryParse(_monthlyDue.text.replaceAll(',', '')) ?? 0,
                            coMakerName: _cmNameController?.text ?? '', 
                            coMakerAddress: _cmAddress.text,
                            coMakerDob: cmParsedDob,
                            coMakerMobile: _cmContact.text,
                            coMakerMessenger: _cmMessenger.text,
                            status: 'Pending',
                            dateApplied: DateTime.now(),
                          );

                          await _service.saveLoan(newLoan);
                          
                          if (mounted) Navigator.pop(context);
                        }
                      },
                      child: _isSaving ? const CircularProgressIndicator(color: Colors.white) : const Text("Process Application"),
                    )
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// --- THOUSANDS FORMATTER CLASS ---
class ThousandsFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.isEmpty) {
      return newValue;
    }
    
    // Strip non-digits safely
    String numericOnly = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (numericOnly.isEmpty) return newValue;

    final intValue = int.parse(numericOnly);
    final stringValue = NumberFormat('#,###').format(intValue);
    
    return TextEditingValue(
      text: stringValue,
      selection: TextSelection.collapsed(offset: stringValue.length),
    );
  }
}