import 'package:cloud_firestore/cloud_firestore.dart';

class PachinkoResult {
  final String? id;
  final DateTime date;
  final int amount;
  final String memo;
  final DateTime createdAt;

  PachinkoResult({
    this.id,
    required this.date,
    required this.amount,
    required this.memo,
    required this.createdAt,
  });

  factory PachinkoResult.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return PachinkoResult(
      id: doc.id,
      date: (data['date'] as Timestamp).toDate(),
      amount: data['amount'] ?? 0,
      memo: data['memo'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'date': Timestamp.fromDate(date),
      'amount': amount,
      'memo': memo,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
