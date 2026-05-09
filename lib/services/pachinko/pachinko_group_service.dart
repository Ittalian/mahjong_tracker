import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mahjong_tracker/models/pachinko_group.dart';

class PachinkoGroupService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _collectionName = 'pachinko_groups';

  Future<void> addGroup(PachinkoGroup group) async {
    await _firestore.collection(_collectionName).add(group.toMap());
  }

  Stream<List<PachinkoGroup>> getGroups() {
    // 全件取得してDart側でソートする（インデックス回避のため）
    return _firestore
        .collection(_collectionName)
        .snapshots()
        .map((snapshot) {
      final groups = snapshot.docs
          .map((doc) => PachinkoGroup.fromFirestore(doc))
          .toList();

      groups.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return groups;
    });
  }

  Future<void> updateGroup(PachinkoGroup group) async {
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
