import 'package:cloud_firestore/cloud_firestore.dart';

class KeirinResult {
  static const List<String> betTypes = [
    '単勝',
    '2車複',
    '2車単',
    '3連複',
    '3連単',
    '2枠単',
    '2枠複',
    'ワイド',
  ];

  final String? id;
  final DateTime date;
  final int amount;
  final String betType;
  final String memo;
  final DateTime createdAt;

  KeirinResult({
    this.id,
    required this.date,
    required this.amount,
    required this.betType,
    required this.memo,
    required this.createdAt,
  });

  factory KeirinResult.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return KeirinResult(
      id: doc.id,
      date: (data['date'] as Timestamp).toDate(),
      amount: data['amount'] ?? 0,
      betType: data['betType'] ?? '単勝',
      memo: data['memo'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'date': Timestamp.fromDate(date),
      'amount': amount,
      'betType': betType,
      'memo': memo,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
