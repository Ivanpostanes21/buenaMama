import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../../models/customer.dart';
import '../../services/firestore_service.dart';
import '../../theme/app_colors.dart';

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
  
  String? _selectedCivilStatus;
  final List<String> _civilStatusOptions = ['Single', 'Married', 'Widowed', 'Separated', 'Divorced'];
  
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
      
      if (widget.customer!.civilStatus.isNotEmpty) {
        if (!_civilStatusOptions.contains(widget.customer!.civilStatus)) {
          _civilStatusOptions.add(widget.customer!.civilStatus); 
        }
        _selectedCivilStatus = widget.customer!.civilStatus;
      }
      
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
    _age.dispose(); 
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
                        labelText: "Client ID Prefix *", 
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
                  Expanded(
                    child: TextFormField(
                      controller: _fName, 
                      decoration: const InputDecoration(labelText: "First Name *"),
                      validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                    )
                  ),
                  const SizedBox(width: 8),
                  Expanded(child: TextFormField(controller: _mName, decoration: const InputDecoration(labelText: "Middle Name"))),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextFormField(
                      controller: _lName, 
                      decoration: const InputDecoration(labelText: "Last Name *"),
                      validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                    )
                  ),
                ]),
                TextFormField(
                  controller: _address, 
                  decoration: const InputDecoration(labelText: "Complete Address *"),
                  validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                ),
                Row(children: [
                  Expanded(
                    child: TextFormField(
                      controller: _mobile, 
                      decoration: const InputDecoration(labelText: "Mobile *"),
                      keyboardType: TextInputType.phone, 
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly], 
                      validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                    )
                  ),
                  const SizedBox(width: 8),
                  Expanded(child: TextFormField(controller: _email, decoration: const InputDecoration(labelText: "Email"))),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextFormField(
                      controller: _messenger, 
                      decoration: const InputDecoration(labelText: "Messenger *"), 
                      validator: (v) => v == null || v.isEmpty ? 'Required' : null, 
                    )
                  ),
                ]),
                Row(children: [
                  Expanded(
                    child: TextFormField(
                      controller: _dob, 
                      readOnly: true, 
                      decoration: const InputDecoration(
                        labelText: "Date of Birth *",
                        suffixIcon: Icon(Icons.calendar_today),
                      ),
                      validator: (v) => v == null || v.isEmpty ? 'Required' : null,
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
                      decoration: const InputDecoration(labelText: "Age *"),
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly], 
                      validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                    )
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _selectedCivilStatus,
                      decoration: const InputDecoration(labelText: "Civil Status *"),
                      items: _civilStatusOptions.map((status) => DropdownMenuItem(value: status, child: Text(status))).toList(),
                      validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                      onChanged: (val) => setState(() => _selectedCivilStatus = val),
                    )
                  ),
                ]),
                TextFormField(controller: _spouse, decoration: const InputDecoration(labelText: "Name of Spouse")),
                Row(children: [
                   Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _selectedEmpStatus,
                      decoration: const InputDecoration(labelText: "Employment Status *"),
                      items: _empOptions.map((status) => DropdownMenuItem(value: status, child: Text(status))).toList(),
                      validator: (v) => v == null || v.isEmpty ? 'Required' : null,
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
                         decoration: const InputDecoration(labelText: "Please specify *"),
                         validator: (v) => v == null || v.isEmpty ? "Required" : null,
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
                            civilStatus: _selectedCivilStatus ?? '', 
                            employer: _employer.text,
                            otherIncome: _otherIncome.text,
                            age: double.tryParse(_age.text) ?? 0,
                            monthlyIncome: double.tryParse(_income.text.replaceAll(',', '')) ?? 0,
                            status: widget.customer?.status ?? 'Active',
                            
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