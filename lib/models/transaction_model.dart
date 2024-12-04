import 'package:cloud_firestore/cloud_firestore.dart';

class TransactionModel {
  final String id;
  final String type;
  final DateTime date; // Firestore의 Timestamp를 DateTime으로 변환
  final String userId; //추가
  final int amount;
  final String category;
  final String memo;

  TransactionModel({
    required this.id,
    required this.userId, //추가
    required this.type,
    required this.date,
    required this.amount,
    required this.category,
    required this.memo,
  });

  // Firestore 데이터를 TransactionModel 객체로 변환
  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id'] as String,
      userId: json['userId'] as String, // userId 추가
      type: json['type'] as String,
      date: (json['date'] as Timestamp).toDate(), // Timestamp → DateTime
      amount: json['amount'] as int,
      category: json['category'] as String,
      memo: json['memo'] as String,
    );
  }

  // TransactionModel 객체를 Firestore 형식으로 변환
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId, //추가
      'type': type,
      'date': Timestamp.fromDate(date), // DateTime → Timestamp
      'amount': amount,
      'category': category,
      'memo': memo,
    };
  }
}
