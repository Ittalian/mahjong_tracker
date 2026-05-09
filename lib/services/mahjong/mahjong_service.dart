import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mahjong_tracker/models/mahjong_result.dart';
import 'package:mahjong_tracker/services/firestore_service.dart';

class MahjongService implements FirestoreService<MahjongResult> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static const String _collectionName = 'mahjong_results';

  @override
  Future<void> addResult(MahjongResult result) async {
    await _firestore.collection(_collectionName).add(result.toMap());
  }

  @override
  Stream<List<MahjongResult>> getResults() {
    return _firestore
        .collection(_collectionName)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => MahjongResult.fromFirestore(doc))
          .toList();
    });
  }

  @override
  Future<void> updateResult(MahjongResult result) async {
    final id = result.id;
    if (id == null || id.isEmpty) return;

    await _firestore.collection(_collectionName).doc(id).update(result.toMap());
  }

  @override
  Future<void> deleteResult(String id) async {
    await _firestore.collection(_collectionName).doc(id).delete();
  }

  Future<void> updatePlaceNames(String oldName, String newName) async {
    final snapshot = await _firestore
        .collection(_collectionName)
        .where('place', isEqualTo: oldName)
        .get();
        
    final batch = _firestore.batch();
    for (var doc in snapshot.docs) {
      batch.update(doc.reference, {'place': newName});
    }
    await batch.commit();
  }

  /// 過去の全収支から重複なしのメンバー名一覧を返す
  Stream<List<String>> getUniqueMembers() {
    return _firestore
        .collection(_collectionName)
        .snapshots()
        .map((snapshot) {
      final names = <String>{};
      for (final doc in snapshot.docs) {
        final data = doc.data();
        final members = List<String>.from(data['member'] ?? []);
        names.addAll(members.where((m) => m.trim().isNotEmpty));
      }
      final sorted = names.toList()..sort();
      return sorted;
    });
  }
}
