import 'package:cloud_firestore/cloud_firestore.dart';

class HorseReview {
  final String? id;
  final String name; // 馬名
  final int overall; // 総合評価 1-5
  final int speed; // スピード 1-5
  final int stamina; // スタミナ 1-5
  final int power; // パワー 1-5
  final String memo;
  final DateTime createdAt;
  final DateTime updatedAt;

  HorseReview({
    this.id,
    required this.name,
    required this.overall,
    required this.speed,
    required this.stamina,
    required this.power,
    required this.memo,
    required this.createdAt,
    required this.updatedAt,
  });

  factory HorseReview.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return HorseReview(
      id: doc.id,
      name: data['name'] ?? '',
      overall: data['overall'] ?? 3,
      speed: data['speed'] ?? 3,
      stamina: data['stamina'] ?? 3,
      power: data['power'] ?? 3,
      memo: data['memo'] ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'overall': overall,
      'speed': speed,
      'stamina': stamina,
      'power': power,
      'memo': memo,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }
}
