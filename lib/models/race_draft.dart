import 'package:cloud_firestore/cloud_firestore.dart';

/// 当日の収支としてまとめる前に一時保存する、1レース分の賭け記録
class RaceDraft {
  final String? id;
  final String category;
  final DateTime date;
  final String place;
  final String raceName;
  final String betType;
  final int amount;
  final String memo;
  final DateTime createdAt;

  RaceDraft({
    this.id,
    required this.category,
    required this.date,
    this.place = '',
    this.raceName = '',
    required this.betType,
    required this.amount,
    this.memo = '',
    required this.createdAt,
  });

  factory RaceDraft.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return RaceDraft(
      id: doc.id,
      category: data['category'] ?? '',
      date: (data['date'] as Timestamp).toDate(),
      place: data['place'] ?? '',
      raceName: data['raceName'] ?? '',
      betType: data['betType'] ?? '',
      amount: data['amount'] ?? 0,
      memo: data['memo'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'category': category,
      'date': Timestamp.fromDate(date),
      'place': place,
      'raceName': raceName,
      'betType': betType,
      'amount': amount,
      'memo': memo,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
