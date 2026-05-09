import 'package:cloud_firestore/cloud_firestore.dart';

class PachinkoGroup {
  final String? id;
  final String name;
  final List<String> members;
  final DateTime createdAt;

  PachinkoGroup({
    this.id,
    required this.name,
    required this.members,
    required this.createdAt,
  });

  factory PachinkoGroup.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return PachinkoGroup(
      id: doc.id,
      name: data['name'] ?? '',
      members: List<String>.from(data['members'] ?? []),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'members': members,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  PachinkoGroup copyWith({
    String? id,
    String? name,
    List<String>? members,
    DateTime? createdAt,
  }) {
    return PachinkoGroup(
      id: id ?? this.id,
      name: name ?? this.name,
      members: members ?? this.members,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
