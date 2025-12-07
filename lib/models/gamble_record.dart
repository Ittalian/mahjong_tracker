import 'package:cloud_firestore/cloud_firestore.dart';

class GambleRecord {
  final String? id;
  final String category;
  final DateTime date;
  final int amount;
  final String memo;
  final DateTime createdAt;

  GambleRecord({
    this.id,
    required this.category,
    required this.date,
    required this.amount,
    required this.memo,
    required this.createdAt,
  });

  // Firestoreからデータを取得する際のファクトリメソッド
  factory GambleRecord.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return GambleRecord(
      id: doc.id,
      category: data['category'] ?? 'mahjong',
      date: (data['date'] as Timestamp).toDate(),
      amount: data['amount'] ?? 0,
      memo: data['memo'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  // Firestoreにデータを保存する際のMap変換メソッド
  Map<String, dynamic> toMap() {
    return {
      'category': category,
      'date': Timestamp.fromDate(date),
      'amount': amount,
      'memo': memo,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  GambleRecord copyWith({
    String? id,
    String? category,
    DateTime? date,
    int? amount,
    String? memo,
    DateTime? createdAt,
  }) {
    return GambleRecord(
      id: id ?? this.id,
      category: category ?? this.category,
      date: date ?? this.date,
      amount: amount ?? this.amount,
      memo: memo ?? this.memo,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
