import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/mahjong_result.dart';

class FirestoreService {
  final CollectionReference _resultsCollection =
      FirebaseFirestore.instance.collection('results');

  // 収支データの追加
  Future<void> addResult(MahjongResult result) async {
    await _resultsCollection.add(result.toMap());
  }

  // 収支データの取得 (Stream)
  Stream<List<MahjongResult>> getResults() {
    return _resultsCollection
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return MahjongResult.fromFirestore(doc);
      }).toList();
    });
  }

  // 収支データの更新
  Future<void> updateResult(MahjongResult result) async {
    if (result.id == null) return;
    await _resultsCollection.doc(result.id).update(result.toMap());
  }

  // 収支データの削除
  Future<void> deleteResult(String id) async {
    await _resultsCollection.doc(id).delete();
  }
}
