import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

class AddCustomerDialog extends StatefulWidget {
  const AddCustomerDialog({super.key});

  @override
  State<AddCustomerDialog> createState() => _AddCustomerDialogState();
}

class _AddCustomerDialogState extends State<AddCustomerDialog> {
  final _formKey = GlobalKey<FormState>();

  // Form Controllers
  final _fName = TextEditingController();
  final _mName = TextEditingController();
  final _lName = TextEditingController();
  final _address = TextEditingController();
  final _mobile = TextEditingController();
  final _email = TextEditingController();
  
  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 500,
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("Add New Customer", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              
              // Fields based on your notes
              Row(children: [
                Expanded(child: TextFormField(controller: _fName, decoration: const InputDecoration(labelText: "First Name"))),
                const SizedBox(width: 10),
                Expanded(child: TextFormField(controller: _mName, decoration: const InputDecoration(labelText: "Middle Name"))),
                const SizedBox(width: 10),
                Expanded(child: TextFormField(controller: _lName, decoration: const InputDecoration(labelText: "Last Name"))),
              ]),
              const SizedBox(height: 10),
              TextFormField(controller: _address, decoration: const InputDecoration(labelText: "Complete Address")),
              const SizedBox(height: 10),
              Row(children: [
                Expanded(child: TextFormField(controller: _mobile, decoration: const InputDecoration(labelText: "Mobile No."))),
                const SizedBox(width: 10),
                Expanded(child: TextFormField(controller: _email, decoration: const InputDecoration(labelText: "Email"))),
              ]),
              
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        // TODO: Save to Firebase/List
                        Navigator.pop(context);
                      }
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryGreen, foregroundColor: Colors.white),
                    child: const Text("Save Profile"),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}