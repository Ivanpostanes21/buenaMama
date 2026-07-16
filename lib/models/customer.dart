
class Customer {
  final String id;
  // Personal
  final String firstName, middleName, lastName, address, mobile, email, messenger;
  final DateTime dob;
  final String spouseName, employmentStatus, civilStatus, employer, otherIncome;
  final double age, monthlyIncome;
  // Loan
  final String loanCategory, paymentStructure;
  final double loanAmount, loanRate, loanTerm, monthlyDue;
  // Co-Maker
  final String coMakerName, coMakerAddress, coMakerMobile, coMakerMessenger;
  final DateTime coMakerDob;
  // History
  final DateTime latestTransaction;

  Customer({
    required this.id, required this.firstName, required this.middleName, required this.lastName,
    required this.address, required this.mobile, required this.email, required this.messenger,
    required this.dob, required this.spouseName, required this.employmentStatus,
    required this.civilStatus, required this.employer, required this.otherIncome,
    required this.age, required this.monthlyIncome, required this.loanCategory,
    required this.paymentStructure, required this.loanAmount, required this.loanRate,
    required this.loanTerm, required this.monthlyDue, required this.coMakerName,
    required this.coMakerAddress, required this.coMakerMobile, required this.coMakerMessenger,
    required this.coMakerDob, required this.latestTransaction,
  });

  String get fullName => "$firstName $lastName";
  String get status => "Active";
}