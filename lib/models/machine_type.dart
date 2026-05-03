import 'package:cloud_firestore/cloud_firestore.dart';

class MachineType {
  final String? id;
  final String name;
  final DateTime createdAt;

  MachineType({
    this.id,
    required this.name,
    required this.createdAt,
  });

  factory MachineType.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return MachineType(
      id: doc.id,
      name: data['name'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
