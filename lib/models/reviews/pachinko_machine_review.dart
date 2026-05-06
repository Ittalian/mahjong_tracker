import 'package:cloud_firestore/cloud_firestore.dart';

class PachinkoMachineReview {
  final String? id;
  final String machineId; // MachineTypeのID
  final int overall; // 総合評価 1-5
  final int production; // 演出 1-5
  final int payout; // 出玉力 1-5
  final int custom; // カスタム 1-5
  final int music; // 音楽 1-5
  final String memo;
  final DateTime createdAt;
  final DateTime updatedAt;

  PachinkoMachineReview({
    this.id,
    required this.machineId,
    required this.overall,
    required this.production,
    required this.payout,
    required this.custom,
    required this.music,
    required this.memo,
    required this.createdAt,
    required this.updatedAt,
  });

  factory PachinkoMachineReview.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return PachinkoMachineReview(
      id: doc.id,
      machineId: data['machineId'] ?? '',
      overall: data['overall'] ?? 3,
      production: data['production'] ?? 3,
      payout: data['payout'] ?? 3,
      custom: data['custom'] ?? 3,
      music: data['music'] ?? 3,
      memo: data['memo'] ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'machineId': machineId,
      'overall': overall,
      'production': production,
      'payout': payout,
      'custom': custom,
      'music': music,
      'memo': memo,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }
}
