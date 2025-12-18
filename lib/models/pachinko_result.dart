import 'package:cloud_firestore/cloud_firestore.dart';

class PachinkoResult {
  static const List<String> types = ['乗り打ち', 'ソロ'];

  final String? id;
  final DateTime date;
  final int amount;
  final String memo;
  final DateTime createdAt;
  final String type;
  final List<String> member;
  final String place;
  final String machine;

  PachinkoResult({
    this.id,
    required this.date,
    required this.amount,
    required this.memo,
    required this.createdAt,
    this.type = 'ソロ',
    this.member = const [],
    this.place = '',
    this.machine = '',
  });

  factory PachinkoResult.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return PachinkoResult(
      id: doc.id,
      date: (data['date'] as Timestamp).toDate(),
      amount: data['amount'] ?? 0,
      memo: data['memo'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      type: data['type'] ?? 'ソロ',
      member: List<String>.from(data['member'] ?? []),
      place: data['place'] ?? '',
      machine: data['machine'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'date': Timestamp.fromDate(date),
      'amount': amount,
      'memo': memo,
      'createdAt': Timestamp.fromDate(createdAt),
      'type': type,
      'member': member,
      'place': place,
      'machine': machine,
    };
  }
}
