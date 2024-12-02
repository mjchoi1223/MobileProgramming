import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/transaction_model.dart';

class FirebaseServices {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<TransactionModel>> fetchTransactions() async {
    QuerySnapshot snapshot = await _firestore.collection('transactions').get();

    return snapshot.docs.map((doc) {
      return TransactionModel.fromJson(doc.data() as Map<String, dynamic>);
    }).toList();
  }

  Future<void> addTransaction(TransactionModel TransactionModel) async {
    await _firestore.collection('transactions').add(TransactionModel.toJson());
  }

  Future<void> deleteTransaction(String id) async {
    QuerySnapshot snapshot = await _firestore
        .collection('transactions')
        .where('id', isEqualTo: id)
        .get();

    if (snapshot.docs.isNotEmpty) {
      await snapshot.docs.first.reference.delete();
    }
  }
}
