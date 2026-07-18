import 'package:cloud_firestore/cloud_firestore.dart';

class Loan {
  final String id;
  final String customerId;
  final String customerName; 
  final String category;
  final String paymentStructure;
  final double amount;
  final double rate;
  final double term;
  final double monthlyDue;
  
  final String coMakerName;
  final String coMakerAddress;
  final String coMakerMobile;
  final String coMakerMessenger;
  final DateTime coMakerDob;
  
  final String status; 
  final DateTime dateApplied;

  Loan({
    required this.id, required this.customerId, required this.customerName,
    required this.category, required this.paymentStructure, required this.amount,
    required this.rate, required this.term, required this.monthlyDue,
    required this.coMakerName, required this.coMakerAddress,
    required this.coMakerMobile, required this.coMakerMessenger,
    required this.coMakerDob, required this.status, required this.dateApplied,
  });

  Map<String, dynamic> toMap() {
    return {
      'customerId': customerId,
      'customerName': customerName,
      'category': category,
      'paymentStructure': paymentStructure,
      'amount': amount,
      'rate': rate,
      'term': term,
      'monthlyDue': monthlyDue,
      'coMakerName': coMakerName,
      'coMakerAddress': coMakerAddress,
      'coMakerMobile': coMakerMobile,
      'coMakerMessenger': coMakerMessenger,
      'coMakerDob': Timestamp.fromDate(coMakerDob),
      'status': status,
      'dateApplied': Timestamp.fromDate(dateApplied),
    };
  }
}