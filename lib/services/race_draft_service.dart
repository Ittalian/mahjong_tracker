import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mahjong_tracker/models/auto_racing_result.dart';
import 'package:mahjong_tracker/models/boat_racing_result.dart';
import 'package:mahjong_tracker/models/horse_racing_result.dart';
import 'package:mahjong_tracker/models/keirin_result.dart';
import 'package:mahjong_tracker/models/race_draft.dart';
import 'package:mahjong_tracker/services/auto_racing/auto_racing_service.dart';
import 'package:mahjong_tracker/services/boat_racing/boat_racing_service.dart';
import 'package:mahjong_tracker/services/horse_racing/horse_racing_service.dart';
import 'package:mahjong_tracker/services/keirin/keirin_service.dart';

/// レース系ギャンブルの一時保存（下書き）を扱うサービス
class RaceDraftService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static const String _collectionName = 'race_drafts';

  Future<void> addDraft(RaceDraft draft) async {
    await _firestore.collection(_collectionName).add(draft.toMap());
  }

  Future<void> updateDraft(RaceDraft draft) async {
    final id = draft.id;
    if (id == null) return;
    await _firestore.collection(_collectionName).doc(id).update(draft.toMap());
  }

  Future<void> deleteDraft(String id) async {
    await _firestore.collection(_collectionName).doc(id).delete();
  }

  Stream<List<RaceDraft>> getDrafts(String category) {
    return _firestore
        .collection(_collectionName)
        .where('category', isEqualTo: category)
        .snapshots()
        .map((snapshot) {
      final list =
          snapshot.docs.map((doc) => RaceDraft.fromFirestore(doc)).toList();
      list.sort((a, b) => a.createdAt.compareTo(b.createdAt));
      return list;
    });
  }

  /// 内訳リストから当日収支を作成 (id が null なら新規追加、あれば更新) する
  Future<void> saveDay(
    String category, {
    String? id,
    required DateTime date,
    required List<Map<String, dynamic>> bets,
    String place = '',
    String memo = '',
    DateTime? createdAt,
  }) async {
    if (bets.isEmpty) return;

    final total = bets.fold<int>(0, (acc, b) => acc + (b['amount'] as int));
    final betType = bets.first['betType'] as String;
    final created = createdAt ?? DateTime.now();
    final isNew = id == null;

    switch (category) {
      case 'horse_racing':
        final r = HorseRacingResult(
            id: id,
            date: date,
            amount: total,
            betType: betType,
            memo: memo,
            createdAt: created,
            place: place,
            bets: bets);
        isNew
            ? await HorseRacingService().addResult(r)
            : await HorseRacingService().updateResult(r);
        break;
      case 'boat_racing':
        final r = BoatRacingResult(
            id: id,
            date: date,
            amount: total,
            betType: betType,
            memo: memo,
            createdAt: created,
            place: place,
            bets: bets);
        isNew
            ? await BoatRacingService().addResult(r)
            : await BoatRacingService().updateResult(r);
        break;
      case 'auto_racing':
        final r = AutoRacingResult(
            id: id,
            date: date,
            amount: total,
            betType: betType,
            memo: memo,
            createdAt: created,
            place: place,
            bets: bets);
        isNew
            ? await AutoRacingService().addResult(r)
            : await AutoRacingService().updateResult(r);
        break;
      case 'keirin':
        final r = KeirinResult(
            id: id,
            date: date,
            amount: total,
            betType: betType,
            memo: memo,
            createdAt: created,
            place: place,
            bets: bets);
        isNew
            ? await KeirinService().addResult(r)
            : await KeirinService().updateResult(r);
        break;
      default:
        throw Exception('Unknown category: $category');
    }
  }

  /// 下書きを1件の当日収支にまとめて保存し、下書きを削除する
  Future<void> commitDrafts(
    String category,
    List<RaceDraft> drafts, {
    String place = '',
    String memo = '',
  }) async {
    if (drafts.isEmpty) return;

    await saveDay(
      category,
      date: drafts.first.date,
      place: place,
      memo: memo,
      bets: drafts
          .map((d) => <String, dynamic>{
                'betType': d.betType,
                'amount': d.amount,
                'raceName': d.raceName,
                'memo': d.memo,
              })
          .toList(),
    );

    final batch = _firestore.batch();
    for (final d in drafts) {
      final id = d.id;
      if (id != null) {
        batch.delete(_firestore.collection(_collectionName).doc(id));
      }
    }
    await batch.commit();
  }
}
