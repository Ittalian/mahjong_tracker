import 'package:cloud_firestore/cloud_firestore.dart';

class JockeyReview {
  final String? id;
  final String name; // 騎手名
  final int overall; // 総合評価 1-5
  final int technique; // 技術 1-5
  final int clutch; // 勝負強さ 1-5
  final int pace; // ペース配分 1-5
  final String memo;
  final DateTime createdAt;
  final DateTime updatedAt;

  JockeyReview({
    this.id,
    required this.name,
    required this.overall,
    required this.technique,
    required this.clutch,
    required this.pace,
    required this.memo,
    required this.createdAt,
    required this.updatedAt,
  });

  factory JockeyReview.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return JockeyReview(
      id: doc.id,
      name: data['name'] ?? '',
      overall: data['overall'] ?? 3,
      technique: data['technique'] ?? 3,
      clutch: data['clutch'] ?? 3,
      pace: data['pace'] ?? 3,
      memo: data['memo'] ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'overall': overall,
      'technique': technique,
      'clutch': clutch,
      'pace': pace,
      'memo': memo,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }
}
