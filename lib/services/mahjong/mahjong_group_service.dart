import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mahjong_tracker/models/mahjong_group.dart';

class MahjongGroupService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _collectionName = 'mahjong_groups';

  Future<void> addGroup(MahjongGroup group) async {
    await _firestore.collection(_collectionName).add(group.toMap());
  }

  Stream<List<MahjongGroup>> getGroups({String? type}) {
    // Firestore側でorderBy+whereを組み合わせると複合インデックスが必要になるため、
    // 全件取得してDart側でフィルタ・ソートする
    return _firestore
        .collection(_collectionName)
        .snapshots()
        .map((snapshot) {
      final groups = snapshot.docs
          .map((doc) => MahjongGroup.fromFirestore(doc))
          .toList();

      final filtered = (type != null && type.isNotEmpty)
          ? groups.where((g) => g.type == type).toList()
          : groups;

      filtered.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return filtered;
    });
  }

  Future<void> updateGroup(MahjongGroup group) async {
    final id = group.id;
    if (id == null || id.isEmpty) return;

    try {
      final docRef = _firestore.collection(_collectionName).doc(id);
      final docSnap = await docRef.get();
      if (docSnap.exists) {
        await docRef.update(group.toMap());
      }
    } catch (e) {
      // ignore errors
    }
  }

  Future<void> deleteGroup(String id) async {
    try {
      final docRef = _firestore.collection(_collectionName).doc(id);
      final docSnap = await docRef.get();
      if (docSnap.exists) {
        await docRef.delete();
      }
    } catch (e) {
      // ignore errors
    }
  }
}
