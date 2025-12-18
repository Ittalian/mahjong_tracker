import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mahjong_tracker/models/auto_racing_result.dart';
import 'package:mahjong_tracker/services/firestore_service.dart';

class AutoRacingService implements FirestoreService<AutoRacingResult> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static const String _collectionName = 'auto_racing_results';

  @override
  Future<void> addResult(AutoRacingResult result) async {
    await _firestore.collection(_collectionName).add(result.toMap());
  }

  @override
  Stream<List<AutoRacingResult>> getResults() {
    return _firestore
        .collection(_collectionName)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => AutoRacingResult.fromFirestore(doc))
          .toList();
    });
  }

  @override
  Future<void> updateResult(AutoRacingResult result) async {
    final id = result.id;
    if (id == null || id.isEmpty) return;

    await _firestore.collection(_collectionName).doc(id).update(result.toMap());
  }

  @override
  Future<void> deleteResult(String id) async {
    await _firestore.collection(_collectionName).doc(id).delete();
  }
}
