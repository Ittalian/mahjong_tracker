import 'package:cloud_firestore/cloud_firestore.dart';

class Place {
  final String? id;
  final String name;
  final String category;
  final DateTime createdAt;

  Place({
    this.id,
    required this.name,
    required this.category,
    required this.createdAt,
  });

  factory Place.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Place(
      id: doc.id,
      name: data['name'] ?? '',
      category: data['category'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'category': category,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
