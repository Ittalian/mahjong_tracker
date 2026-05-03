import 'package:cloud_firestore/cloud_firestore.dart';

class HorseRacingResult {
  static const List<String> betTypes = [
    '単勝',
    '複勝',
    '馬単',
    '馬連',
    '3連単',
    '3連複',
    '枠連',
    'ワイド',
  ];

  final String? id;
  final DateTime date;
  final int amount;
  final String betType;
  final String memo;
  final DateTime createdAt;
  final String place;

  HorseRacingResult({
    this.id,
    required this.date,
    required this.amount,
    required this.betType,
    required this.memo,
    required this.createdAt,
    this.place = '',
  });

  factory HorseRacingResult.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return HorseRacingResult(
      id: doc.id,
      date: (data['date'] as Timestamp).toDate(),
      amount: data['amount'] ?? 0,
      betType: data['betType'] ?? '単勝',
      memo: data['memo'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      place: data['place'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'date': Timestamp.fromDate(date),
      'amount': amount,
      'betType': betType,
      'memo': memo,
      'createdAt': Timestamp.fromDate(createdAt),
      'place': place,
    };
  }
}
