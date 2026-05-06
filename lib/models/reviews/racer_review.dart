import 'package:cloud_firestore/cloud_firestore.dart';

class RacerReview {
  final String? id;
  final String name; // 選手名
  final String category; // 'keirin', 'boat_racing', 'auto_racing'
  final int overall; // 総合評価 1-5
  final int speed; // スピード 1-5
  final int technique; // 技術 1-5
  final int mental; // メンタル 1-5
  final String memo;
  final DateTime createdAt;
  final DateTime updatedAt;

  RacerReview({
    this.id,
    required this.name,
    required this.category,
    required this.overall,
    required this.speed,
    required this.technique,
    required this.mental,
    required this.memo,
    required this.createdAt,
    required this.updatedAt,
  });

  factory RacerReview.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return RacerReview(
      id: doc.id,
      name: data['name'] ?? '',
      category: data['category'] ?? '',
      overall: data['overall'] ?? 3,
      speed: data['speed'] ?? 3,
      technique: data['technique'] ?? 3,
      mental: data['mental'] ?? 3,
      memo: data['memo'] ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'category': category,
      'overall': overall,
      'speed': speed,
      'technique': technique,
      'mental': mental,
      'memo': memo,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }
}
