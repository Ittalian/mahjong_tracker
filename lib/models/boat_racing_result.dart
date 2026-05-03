import 'package:cloud_firestore/cloud_firestore.dart';

class BoatRacingResult {
  static const List<String> betTypes = [
    '単勝',
    '2連複',
    '2連単',
    '3連複',
    '3連単',
    '拡連複',
  ];

  final String? id;
  final DateTime date;
  final int amount;
  final String betType;
  final String memo;
  final DateTime createdAt;
  final String place;

  BoatRacingResult({
    this.id,
    required this.date,
    required this.amount,
    required this.betType,
    required this.memo,
    required this.createdAt,
    this.place = '',
  });

  factory BoatRacingResult.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return BoatRacingResult(
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
