import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/customer.dart';
import '../../models/loan.dart';
import '../../services/firestore_service.dart';
import '../../theme/app_colors.dart';
import 'customer_form_dialog.dart';

class CustomerDetailDialog extends StatelessWidget {
  final Customer customer;
  final BuildContext parentContext;
  final FirestoreService _service = FirestoreService();
  
  CustomerDetailDialog({super.key, required this.customer, required this.parentContext});

  @override
  Widget build(BuildContext context) {
    final Color darkGrey = Colors.grey.shade800;
    String formattedIncome = NumberFormat('#,##0.00').format(customer.monthlyIncome);

    return AlertDialog(
      title: Text(customer.fullName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 22)),
      content: SizedBox(
        width: 600, 
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Client ID: ${customer.id}", style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryGreen, fontSize: 18)),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: customer.status.toLowerCase() == 'active' ? Colors.green.shade100 : Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(customer.status.toUpperCase(), style: TextStyle(
                      color: customer.status.toLowerCase() == 'active' ? Colors.green.shade800 : Colors.grey.shade800,
                      fontWeight: FontWeight.bold,
                      fontSize: 14
                    )),
                  )
                ],
              ),
              const SizedBox(height: 16),
              
              Text("PERSONAL INFORMATION", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: darkGrey)),
              const Divider(),
              _buildInfoRow("Address", customer.address, darkGrey),
              _buildInfoRow("Mobile", customer.mobile, darkGrey),
              _buildInfoRow("Email", customer.email.isNotEmpty ? customer.email : "N/A", darkGrey),
              _buildInfoRow("Messenger", customer.messenger.isNotEmpty ? customer.messenger : "N/A", darkGrey),
              _buildInfoRow("Date of Birth", "${customer.dob.month}/${customer.dob.day}/${customer.dob.year} (Age: ${customer.age.toInt()})", darkGrey),
              _buildInfoRow("Civil Status", customer.civilStatus, darkGrey),
              if (customer.spouseName.isNotEmpty) _buildInfoRow("Spouse", customer.spouseName, darkGrey),
              const SizedBox(height: 16),

              Text("FINANCIAL INFORMATION", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: darkGrey)),
              const Divider(),
              _buildInfoRow("Employment", "${customer.employmentStatus} ${customer.employer.isNotEmpty ? 'at ${customer.employer}' : ''}", darkGrey),
              _buildInfoRow("Other Income", customer.otherIncome.isNotEmpty ? customer.otherIncome : "None", darkGrey),
              _buildInfoRow("Household Income", "₱$formattedIncome / month", darkGrey),
              const SizedBox(height: 16),

              Text("LOAN HISTORY", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: darkGrey)),
              const Divider(),
              
              StreamBuilder<List<Loan>>(
                stream: _service.getLoansForCustomer(customer.id),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Padding(padding: EdgeInsets.all(16.0), child: Center(child: CircularProgressIndicator()));
                  }
                  
                  final loans = snapshot.data ?? [];
                  
                  if (loans.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Text("No loan history recorded for this profile.", style: TextStyle(fontStyle: FontStyle.italic, color: darkGrey, fontSize: 16)),
                    );
                  }

                  return Column(
                    children: loans.map((loan) {
                      String formattedLoanAmt = NumberFormat('#,##0.00').format(loan.amount);
                      String formattedLoanDue = NumberFormat('#,##0.00').format(loan.monthlyDue);
                      
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          border: Border.all(color: Colors.grey.shade200),
                          borderRadius: BorderRadius.circular(12)
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text("${loan.category.toUpperCase()} LOAN", style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryGreen, fontSize: 14)),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: loan.status == 'Pending' ? Colors.orange.shade100 : Colors.blue.shade100,
                                    borderRadius: BorderRadius.circular(8)
                                  ),
                                  child: Text(loan.status, style: TextStyle(
                                    color: loan.status == 'Pending' ? Colors.orange.shade800 : Colors.blue.shade800, 
                                    fontWeight: FontWeight.bold, fontSize: 12
                                  )),
                                )
                              ],
                            ),
                            const SizedBox(height: 12),
                            _buildInfoRow("Principal Amount", "₱$formattedLoanAmt", darkGrey),
                            _buildInfoRow("Term", "${loan.term.toInt()} Period(s)", darkGrey),
                            _buildInfoRow("Monthly Due", "₱$formattedLoanDue", darkGrey),
                            _buildInfoRow("Applied On", DateFormat('MMM d, yyyy').format(loan.dateApplied), darkGrey),
                            
                            const SizedBox(height: 8),
                            const Text("Co-Maker", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.grey)),
                            const Divider(height: 8),
                            _buildInfoRow("Name", loan.coMakerName, darkGrey),
                            _buildInfoRow("Contact No.", loan.coMakerMobile, darkGrey),
                          ],
                        ),
                      );
                    }).toList(),
                  );
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text("Close", style: TextStyle(fontSize: 16))),
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
          child: const Text("Edit Profile", style: TextStyle(fontSize: 16))
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value, Color darkGrey) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 150, child: Text(label, style: TextStyle(fontWeight: FontWeight.w600, color: darkGrey, fontSize: 15))),
          Expanded(child: Text(value, style: const TextStyle(color: Colors.black87, fontSize: 15))),
        ],
      ),
    );
  }
}