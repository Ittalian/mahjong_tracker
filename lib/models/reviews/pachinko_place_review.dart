import 'package:cloud_firestore/cloud_firestore.dart';

class PachinkoPlaceReview {
  final String? id;
  final String placeId; // PlaceのID
  final int overall; // 総合評価 1-5
  final int rotation; // 回転数 1-5
  final int atmosphere; // 雰囲気 1-5
  final int staff; // 店員 1-5
  final String memo;
  final DateTime createdAt;
  final DateTime updatedAt;

  PachinkoPlaceReview({
    this.id,
    required this.placeId,
    required this.overall,
    required this.rotation,
    required this.atmosphere,
    required this.staff,
    required this.memo,
    required this.createdAt,
    required this.updatedAt,
  });

  factory PachinkoPlaceReview.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return PachinkoPlaceReview(
      id: doc.id,
      placeId: data['placeId'] ?? '',
      overall: data['overall'] ?? 3,
      rotation: data['rotation'] ?? 3,
      atmosphere: data['atmosphere'] ?? 3,
      staff: data['staff'] ?? 3,
      memo: data['memo'] ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'placeId': placeId,
      'overall': overall,
      'rotation': rotation,
      'atmosphere': atmosphere,
      'staff': staff,
      'memo': memo,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }
}
