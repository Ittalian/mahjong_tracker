import 'package:cloud_firestore/cloud_firestore.dart';

class SlotMachineReview {
  final String? id;
  final String machineId; // SlotMachineTypeのID
  final int overall; // 総合評価 1-5
  final int explosive; // 爆発力 1-5
  final int soundEffect; // 効果音 1-5
  final int production; // 演出 1-5
  final String memo;
  final DateTime createdAt;
  final DateTime updatedAt;

  SlotMachineReview({
    this.id,
    required this.machineId,
    required this.overall,
    required this.explosive,
    required this.soundEffect,
    required this.production,
    required this.memo,
    required this.createdAt,
    required this.updatedAt,
  });

  factory SlotMachineReview.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return SlotMachineReview(
      id: doc.id,
      machineId: data['machineId'] ?? '',
      overall: data['overall'] ?? 3,
      explosive: data['explosive'] ?? 3,
      soundEffect: data['soundEffect'] ?? 3,
      production: data['production'] ?? 3,
      memo: data['memo'] ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'machineId': machineId,
      'overall': overall,
      'explosive': explosive,
      'soundEffect': soundEffect,
      'production': production,
      'memo': memo,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }
}
