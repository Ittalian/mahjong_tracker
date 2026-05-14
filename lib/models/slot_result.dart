import 'package:cloud_firestore/cloud_firestore.dart';

class SlotResult {
  final String? id;
  final DateTime date;
  final int amount;
  final String memo;
  final DateTime createdAt;
  final String place;
  final String machine;
  final int expectedSetting; // 予想設定: 0=未設定, 1〜6
  final List<String> member;
  final int totalGames;
  final int rbCount;
  final int bbCount;

  SlotResult({
    this.id,
    required this.date,
    required this.amount,
    required this.memo,
    required this.createdAt,
    this.place = '',
    this.machine = '',
    this.expectedSetting = 0,
    this.member = const [],
    this.totalGames = 0,
    this.rbCount = 0,
    this.bbCount = 0,
  });

  factory SlotResult.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return SlotResult(
      id: doc.id,
      date: (data['date'] as Timestamp).toDate(),
      amount: data['amount'] ?? 0,
      memo: data['memo'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      place: data['place'] ?? '',
      machine: data['machine'] ?? '',
      expectedSetting: data['expectedSetting'] ?? 0,
      member: List<String>.from(data['member'] ?? []),
      totalGames: data['totalGames'] ?? 0,
      rbCount: data['rbCount'] ?? 0,
      bbCount: data['bbCount'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'date': Timestamp.fromDate(date),
      'amount': amount,
      'memo': memo,
      'createdAt': Timestamp.fromDate(createdAt),
      'place': place,
      'machine': machine,
      'expectedSetting': expectedSetting,
      'member': member,
      'totalGames': totalGames,
      'rbCount': rbCount,
      'bbCount': bbCount,
    };
  }
}

