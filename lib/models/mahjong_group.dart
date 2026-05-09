import 'package:cloud_firestore/cloud_firestore.dart';

class MahjongGroup {
  final String? id;
  final String name;
  final String type; // '三麻' or '四麻'
  final List<String> members;
  final DateTime createdAt;

  MahjongGroup({
    this.id,
    required this.name,
    required this.type,
    required this.members,
    required this.createdAt,
  });

  factory MahjongGroup.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return MahjongGroup(
      id: doc.id,
      name: data['name'] ?? '',
      type: data['type'] ?? '四麻',
      members: List<String>.from(data['members'] ?? []),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'type': type,
      'members': members,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  MahjongGroup copyWith({
    String? id,
    String? name,
    String? type,
    List<String>? members,
    DateTime? createdAt,
  }) {
    return MahjongGroup(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      members: members ?? this.members,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
