import 'package:cloud_firestore/cloud_firestore.dart';

class MahjongResult {
  static const List<String> types = ['三麻', '四麻'];
  static const List<String> umaRates = ['10-20', '10-30', '10', '15'];
  static const List<String> umaRates4ma = ['10-20', '10-30'];
  static const List<String> umaRates3ma = ['10', '15'];
  static const List<String> priceRates = ['テンゴ', 'テンサン', 'テンピン'];
  static const List<int> chipRates = [0, 50, 100, 30];

  final String? id;
  final DateTime date;
  final int amount;
  final String memo;
  final DateTime createdAt;
  final String type;
  final String umaRate;
  final String priceRate;
  final int chipRate;
  final List<String> member;

  MahjongResult({
    this.id,
    required this.date,
    required this.amount,
    required this.memo,
    required this.createdAt,
    this.type = '四麻',
    this.umaRate = '10-30',
    this.priceRate = 'テンピン',
    this.chipRate = 50,
    this.member = const [],
  });

  factory MahjongResult.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return MahjongResult(
      id: doc.id,
      date: (data['date'] as Timestamp).toDate(),
      amount: data['amount'] ?? 0,
      memo: data['memo'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      type: data['type'] ?? '四麻',
      umaRate: data['umaRate'] ?? '10-30',
      priceRate: data['priceRate'] ?? 'テンピン',
      chipRate: data['chipRate'] ?? 50,
      member: List<String>.from(data['member'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'date': Timestamp.fromDate(date),
      'amount': amount,
      'memo': memo,
      'createdAt': Timestamp.fromDate(createdAt),
      'type': type,
      'umaRate': umaRate,
      'priceRate': priceRate,
      'chipRate': chipRate,
      'member': member,
    };
  }
}
