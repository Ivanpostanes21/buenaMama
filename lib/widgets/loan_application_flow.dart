import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/customer.dart';
import '../services/firestore_service.dart';
import '../theme/app_colors.dart';
import '../screens/pages/customers_page.dart'; 

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

  final _cmName = TextEditingController();
  final _cmAddress = TextEditingController();
  final _cmDob = TextEditingController();
  final _cmContact = TextEditingController();
  final _cmMessenger = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: 700,
        height: MediaQuery.of(context).size.height * 0.85,
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _fKey, // This form key enables validation
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
                      decoration: const InputDecoration(labelText: "Amount (₱) *"),
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
                      decoration: const InputDecoration(labelText: "Term (Months/Days) *"),
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
                      keyboardType: TextInputType.number, 
                      decoration: const InputDecoration(labelText: "Monthly Due (₱) *"),
                      validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                    )
                  ),
                ]),
                const SizedBox(height: 24),

                const Text("Co-Maker's Information", style: TextStyle(fontWeight: FontWeight.w600)),
                const Divider(),
                TextFormField(
                  controller: _cmName, 
                  decoration: const InputDecoration(labelText: "Name *"),
                  validator: (v) => v == null || v.isEmpty ? 'Required' : null,
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
                  Expanded(child: TextFormField(controller: _cmMessenger, decoration: const InputDecoration(labelText: "Messenger"))),
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
                        if (_fKey.currentState!.validate()) { // THIS TRIGGERS THE REQUIRED CHECKS
                          setState(() => _isSaving = true);
                          DateTime cmParsedDob;
                          try { cmParsedDob = DateFormat('yyyy-MM-dd').parse(_cmDob.text); } 
                          catch (_) { cmParsedDob = DateTime.now(); }

                          final updatedCustomer = Customer(
                            id: widget.customer.id, firstName: widget.customer.firstName, middleName: widget.customer.middleName,
                            lastName: widget.customer.lastName, address: widget.customer.address, mobile: widget.customer.mobile,
                            email: widget.customer.email, messenger: widget.customer.messenger, dob: widget.customer.dob,
                            spouseName: widget.customer.spouseName, employmentStatus: widget.customer.employmentStatus,
                            civilStatus: widget.customer.civilStatus, employer: widget.customer.employer,
                            otherIncome: widget.customer.otherIncome, age: widget.customer.age, monthlyIncome: widget.customer.monthlyIncome,
                            
                            loanCategory: _category.text,
                            loanAmount: double.tryParse(_amount.text) ?? 0,
                            loanRate: double.tryParse(_rate.text) ?? 0,
                            loanTerm: double.tryParse(_term.text) ?? 0,
                            paymentStructure: _paymentStructure.text,
                            monthlyDue: double.tryParse(_monthlyDue.text) ?? 0,
                            coMakerName: _cmName.text, coMakerAddress: _cmAddress.text, coMakerDob: cmParsedDob,
                            coMakerMobile: _cmContact.text, coMakerMessenger: _cmMessenger.text,
                            latestTransaction: DateTime.now(),
                          );

                          await _service.saveCustomer(updatedCustomer, true);
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