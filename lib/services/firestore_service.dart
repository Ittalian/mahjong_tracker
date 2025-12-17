import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/mahjong_result.dart';
import '../models/horse_racing_result.dart';
import '../models/boat_racing_result.dart';
import '../models/auto_racing_result.dart';
import '../models/keirin_result.dart';
import '../models/pachinko_result.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> addMahjongResult(MahjongResult result) async {
    await _firestore.collection('mahjong_results').add(result.toMap());
  }

  Stream<List<MahjongResult>> getMahjongResults() {
    return _firestore
        .collection('mahjong_results')
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return MahjongResult.fromFirestore(doc);
      }).toList();
    });
  }

  Future<void> updateMahjongResult(MahjongResult result) async {
    if (result.id == null) return;
    await _firestore
        .collection('mahjong_results')
        .doc(result.id)
        .update(result.toMap());
  }

  Future<void> deleteMahjongResult(String id) async {
    await _firestore.collection('mahjong_results').doc(id).delete();
  }

  Future<void> addHorseRacingResult(HorseRacingResult result) async {
    await _firestore.collection('horse_racing_results').add(result.toMap());
  }

  Stream<List<HorseRacingResult>> getHorseRacingResults() {
    return _firestore
        .collection('horse_racing_results')
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return HorseRacingResult.fromFirestore(doc);
      }).toList();
    });
  }

  Future<void> updateHorseRacingResult(HorseRacingResult result) async {
    if (result.id == null) return;
    await _firestore
        .collection('horse_racing_results')
        .doc(result.id)
        .update(result.toMap());
  }

  Future<void> deleteHorseRacingResult(String id) async {
    await _firestore.collection('horse_racing_results').doc(id).delete();
  }

  Future<void> addBoatRacingResult(BoatRacingResult result) async {
    await _firestore.collection('boat_racing_results').add(result.toMap());
  }

  Stream<List<BoatRacingResult>> getBoatRacingResults() {
    return _firestore
        .collection('boat_racing_results')
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return BoatRacingResult.fromFirestore(doc);
      }).toList();
    });
  }

  Future<void> updateBoatRacingResult(BoatRacingResult result) async {
    if (result.id == null) return;
    await _firestore
        .collection('boat_racing_results')
        .doc(result.id)
        .update(result.toMap());
  }

  Future<void> deleteBoatRacingResult(String id) async {
    await _firestore.collection('boat_racing_results').doc(id).delete();
  }

  Future<void> addAutoRacingResult(AutoRacingResult result) async {
    await _firestore.collection('auto_racing_results').add(result.toMap());
  }

  Stream<List<AutoRacingResult>> getAutoRacingResults() {
    return _firestore
        .collection('auto_racing_results')
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return AutoRacingResult.fromFirestore(doc);
      }).toList();
    });
  }

  Future<void> updateAutoRacingResult(AutoRacingResult result) async {
    if (result.id == null) return;
    await _firestore
        .collection('auto_racing_results')
        .doc(result.id)
        .update(result.toMap());
  }

  Future<void> deleteAutoRacingResult(String id) async {
    await _firestore.collection('auto_racing_results').doc(id).delete();
  }

  Future<void> addKeirinResult(KeirinResult result) async {
    await _firestore.collection('keirin_results').add(result.toMap());
  }

  Stream<List<KeirinResult>> getKeirinResults() {
    return _firestore
        .collection('keirin_results')
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return KeirinResult.fromFirestore(doc);
      }).toList();
    });
  }

  Future<void> updateKeirinResult(KeirinResult result) async {
    if (result.id == null) return;
    await _firestore
        .collection('keirin_results')
        .doc(result.id)
        .update(result.toMap());
  }

  Future<void> deleteKeirinResult(String id) async {
    await _firestore.collection('keirin_results').doc(id).delete();
  }

  Future<void> addPachinkoResult(PachinkoResult result) async {
    await _firestore.collection('pachinko_results').add(result.toMap());
  }

  Stream<List<PachinkoResult>> getPachinkoResults() {
    return _firestore
        .collection('pachinko_results')
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return PachinkoResult.fromFirestore(doc);
      }).toList();
    });
  }

  Future<void> updatePachinkoResult(PachinkoResult result) async {
    if (result.id == null) return;
    await _firestore
        .collection('pachinko_results')
        .doc(result.id)
        .update(result.toMap());
  }

  Future<void> deletePachinkoResult(String id) async {
    await _firestore.collection('pachinko_results').doc(id).delete();
  }
}
