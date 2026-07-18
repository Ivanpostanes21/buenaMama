import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/customer.dart';
import '../models/loan.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String _customerCol = 'customers';
  final String _loanCol = 'loans'; 

  // --- CUSTOMER METHODS ---
  Stream<List<Customer>> getCustomers() {
    return _db.collection(_customerCol).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final d = doc.data();
        return Customer(
          id: doc.id,
          firstName: d['firstName'] ?? '', middleName: d['middleName'] ?? '', lastName: d['lastName'] ?? '',
          address: d['address'] ?? '', mobile: d['mobile'] ?? '', email: d['email'] ?? '', messenger: d['messenger'] ?? '',
          dob: (d['dob'] as Timestamp?)?.toDate() ?? DateTime.now(),
          spouseName: d['spouseName'] ?? '', employmentStatus: d['employmentStatus'] ?? '',
          civilStatus: d['civilStatus'] ?? '', employer: d['employer'] ?? '', otherIncome: d['otherIncome'] ?? '',
          age: (d['age'] ?? 0).toDouble(), monthlyIncome: (d['monthlyIncome'] ?? 0).toDouble(),
          status: d['status'] ?? 'Active',
          
          loanCategory: d['loanCategory'] ?? '', paymentStructure: d['paymentStructure'] ?? '',
          loanAmount: (d['loanAmount'] ?? 0).toDouble(), loanRate: (d['loanRate'] ?? 0).toDouble(),
          loanTerm: (d['loanTerm'] ?? 0).toDouble(), monthlyDue: (d['monthlyDue'] ?? 0).toDouble(),
          coMakerName: d['coMakerName'] ?? '', coMakerAddress: d['coMakerAddress'] ?? '',
          coMakerMobile: d['coMakerMobile'] ?? '', coMakerMessenger: d['coMakerMessenger'] ?? '',
          coMakerDob: (d['coMakerDob'] as Timestamp?)?.toDate() ?? DateTime.now(),
          latestTransaction: (d['latestTransaction'] as Timestamp?)?.toDate() ?? DateTime.now(),
        );
      }).toList();
    });
  }

  Future<void> saveCustomer(Customer c, bool isEditing) async {
    final data = {
      'firstName': c.firstName, 'middleName': c.middleName, 'lastName': c.lastName,
      'address': c.address, 'mobile': c.mobile, 'email': c.email, 'messenger': c.messenger,
      'dob': Timestamp.fromDate(c.dob), 'spouseName': c.spouseName, 'employmentStatus': c.employmentStatus,
      'civilStatus': c.civilStatus, 'employer': c.employer, 'otherIncome': c.otherIncome,
      'age': c.age, 'monthlyIncome': c.monthlyIncome, 'status': c.status,
      
      'loanCategory': c.loanCategory, 'paymentStructure': c.paymentStructure, 
      'loanAmount': c.loanAmount, 'loanRate': c.loanRate, 'loanTerm': c.loanTerm, 'monthlyDue': c.monthlyDue, 
      'coMakerName': c.coMakerName, 'coMakerAddress': c.coMakerAddress, 
      'coMakerMobile': c.coMakerMobile, 'coMakerMessenger': c.coMakerMessenger, 
      'coMakerDob': Timestamp.fromDate(c.coMakerDob), 'latestTransaction': Timestamp.fromDate(c.latestTransaction),
    };
    
    if (isEditing) {
      await _db.collection(_customerCol).doc(c.id).update(data);
    } else {
      await _db.collection(_customerCol).doc(c.id).set(data);
    }
  }

  Future<void> deleteCustomer(String id) async {
    await _db.collection(_customerCol).doc(id).delete();
  }

  // --- LOAN METHODS ---
  Future<void> saveLoan(Loan loan) async {
    if (loan.id.isEmpty) {
      await _db.collection(_loanCol).add(loan.toMap());
    } else {
      await _db.collection(_loanCol).doc(loan.id).set(loan.toMap());
    }
  }

  Stream<List<Loan>> getLoans() {
    return _db.collection(_loanCol).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final d = doc.data();
        return Loan(
          id: doc.id,
          customerId: d['customerId'] ?? '',
          customerName: d['customerName'] ?? '',
          category: d['category'] ?? '',
          paymentStructure: d['paymentStructure'] ?? '',
          amount: (d['amount'] ?? 0).toDouble(),
          rate: (d['rate'] ?? 0).toDouble(),
          term: (d['term'] ?? 0).toDouble(),
          monthlyDue: (d['monthlyDue'] ?? 0).toDouble(),
          coMakerName: d['coMakerName'] ?? '',
          coMakerAddress: d['coMakerAddress'] ?? '',
          coMakerMobile: d['coMakerMobile'] ?? '',
          coMakerMessenger: d['coMakerMessenger'] ?? '',
          coMakerDob: (d['coMakerDob'] as Timestamp?)?.toDate() ?? DateTime.now(),
          status: d['status'] ?? 'Pending',
          dateApplied: (d['dateApplied'] as Timestamp?)?.toDate() ?? DateTime.now(),
        );
      }).toList();
    });
  }

  Stream<List<Loan>> getLoansForCustomer(String customerId) {
    return _db.collection(_loanCol).where('customerId', isEqualTo: customerId).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final d = doc.data();
        return Loan(
          id: doc.id,
          customerId: d['customerId'] ?? '',
          customerName: d['customerName'] ?? '',
          category: d['category'] ?? '',
          paymentStructure: d['paymentStructure'] ?? '',
          amount: (d['amount'] ?? 0).toDouble(),
          
          rate: (d['rate'] ?? 0).toDouble(),
          term: (d['term'] ?? 0).toDouble(),
          monthlyDue: (d['monthlyDue'] ?? 0).toDouble(),
          coMakerName: d['coMakerName'] ?? '',
          coMakerAddress: d['coMakerAddress'] ?? '',
          coMakerMobile: d['coMakerMobile'] ?? '',
          coMakerMessenger: d['coMakerMessenger'] ?? '',
          coMakerDob: (d['coMakerDob'] as Timestamp?)?.toDate() ?? DateTime.now(),
          status: d['status'] ?? 'Pending',
          dateApplied: (d['dateApplied'] as Timestamp?)?.toDate() ?? DateTime.now(),
        );
      }).toList();
    });
  }
}