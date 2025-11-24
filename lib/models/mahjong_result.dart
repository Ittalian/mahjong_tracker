import 'package:cloud_firestore/cloud_firestore.dart';

class MahjongResult {
  final String? id;
  final DateTime date;
  final int amount;
  final String memo;
  final DateTime createdAt;

  MahjongResult({
    this.id,
    required this.date,
    required this.amount,
    required this.memo,
    required this.createdAt,
  });

  // Firestoreからデータを取得する際のファクトリメソッド
  factory MahjongResult.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return MahjongResult(
      id: doc.id,
      date: (data['date'] as Timestamp).toDate(),
      amount: data['amount'] ?? 0,
      memo: data['memo'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  // Firestoreにデータを保存する際のMap変換メソッド
  Map<String, dynamic> toMap() {
    return {
      'date': Timestamp.fromDate(date),
      'amount': amount,
      'memo': memo,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  MahjongResult copyWith({
    String? id,
    DateTime? date,
    int? amount,
    String? memo,
    DateTime? createdAt,
  }) {
    return MahjongResult(
      id: id ?? this.id,
      date: date ?? this.date,
      amount: amount ?? this.amount,
      memo: memo ?? this.memo,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
