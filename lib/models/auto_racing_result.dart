import 'package:cloud_firestore/cloud_firestore.dart';

class AutoRacingResult {
  static const List<String> betTypes = [
    '単勝',
    '複勝',
    '2連単',
    '2連複',
    '3連単',
    '3連複',
    'ワイド',
  ];

  final String? id;
  final DateTime date;
  final int amount;
  final String betType;
  final String memo;
  final DateTime createdAt;
  final String place;

  /// 1日の中の各レースの内訳 (betType, amount, place, raceName, memo)
  final List<Map<String, dynamic>> bets;

  AutoRacingResult({
    this.id,
    required this.date,
    required this.amount,
    required this.betType,
    required this.memo,
    required this.createdAt,
    this.place = '',
    this.bets = const [],
  });

  factory AutoRacingResult.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return AutoRacingResult(
      id: doc.id,
      date: (data['date'] as Timestamp).toDate(),
      amount: data['amount'] ?? 0,
      betType: data['betType'] ?? '単勝',
      memo: data['memo'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      place: data['place'] ?? '',
      bets: List<Map<String, dynamic>>.from(
        (data['bets'] as List<dynamic>? ?? [])
            .map((e) => Map<String, dynamic>.from(e as Map)),
      ),
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
      'bets': bets,
    };
  }
}
