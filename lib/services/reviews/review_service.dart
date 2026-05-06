import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/reviews/pachinko_machine_review.dart';
import '../../models/reviews/pachinko_place_review.dart';
import '../../models/reviews/mahjong_place_review.dart';
import '../../models/reviews/horse_review.dart';
import '../../models/reviews/jockey_review.dart';
import '../../models/reviews/racer_review.dart';

class ReviewService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // --- Pachinko Machine Review ---
  Stream<List<PachinkoMachineReview>> getPachinkoMachineReviews() {
    return _firestore.collection('pachinko_machine_reviews').snapshots().map(
        (snapshot) => snapshot.docs.map((doc) => PachinkoMachineReview.fromFirestore(doc)).toList());
  }

  Future<void> savePachinkoMachineReview(PachinkoMachineReview review) async {
    if (review.id == null) {
      await _firestore.collection('pachinko_machine_reviews').add(review.toMap());
    } else {
      await _firestore.collection('pachinko_machine_reviews').doc(review.id).update(review.toMap());
    }
  }

  Future<void> deletePachinkoMachineReview(String id) async {
    await _firestore.collection('pachinko_machine_reviews').doc(id).delete();
  }

  // --- Pachinko Place Review ---
  Stream<List<PachinkoPlaceReview>> getPachinkoPlaceReviews() {
    return _firestore.collection('pachinko_place_reviews').snapshots().map(
        (snapshot) => snapshot.docs.map((doc) => PachinkoPlaceReview.fromFirestore(doc)).toList());
  }

  Future<void> savePachinkoPlaceReview(PachinkoPlaceReview review) async {
    if (review.id == null) {
      await _firestore.collection('pachinko_place_reviews').add(review.toMap());
    } else {
      await _firestore.collection('pachinko_place_reviews').doc(review.id).update(review.toMap());
    }
  }

  Future<void> deletePachinkoPlaceReview(String id) async {
    await _firestore.collection('pachinko_place_reviews').doc(id).delete();
  }

  // --- Mahjong Place Review ---
  Stream<List<MahjongPlaceReview>> getMahjongPlaceReviews() {
    return _firestore.collection('mahjong_place_reviews').snapshots().map(
        (snapshot) => snapshot.docs.map((doc) => MahjongPlaceReview.fromFirestore(doc)).toList());
  }

  Future<void> saveMahjongPlaceReview(MahjongPlaceReview review) async {
    if (review.id == null) {
      await _firestore.collection('mahjong_place_reviews').add(review.toMap());
    } else {
      await _firestore.collection('mahjong_place_reviews').doc(review.id).update(review.toMap());
    }
  }

  Future<void> deleteMahjongPlaceReview(String id) async {
    await _firestore.collection('mahjong_place_reviews').doc(id).delete();
  }

  // --- Horse Review ---
  Stream<List<HorseReview>> getHorseReviews() {
    return _firestore.collection('horse_reviews').snapshots().map(
        (snapshot) => snapshot.docs.map((doc) => HorseReview.fromFirestore(doc)).toList());
  }

  Future<void> saveHorseReview(HorseReview review) async {
    if (review.id == null) {
      await _firestore.collection('horse_reviews').add(review.toMap());
    } else {
      await _firestore.collection('horse_reviews').doc(review.id).update(review.toMap());
    }
  }

  Future<void> deleteHorseReview(String id) async {
    await _firestore.collection('horse_reviews').doc(id).delete();
  }

  // --- Jockey Review ---
  Stream<List<JockeyReview>> getJockeyReviews() {
    return _firestore.collection('jockey_reviews').snapshots().map(
        (snapshot) => snapshot.docs.map((doc) => JockeyReview.fromFirestore(doc)).toList());
  }

  Future<void> saveJockeyReview(JockeyReview review) async {
    if (review.id == null) {
      await _firestore.collection('jockey_reviews').add(review.toMap());
    } else {
      await _firestore.collection('jockey_reviews').doc(review.id).update(review.toMap());
    }
  }

  Future<void> deleteJockeyReview(String id) async {
    await _firestore.collection('jockey_reviews').doc(id).delete();
  }

  // --- Racer Review ---
  Stream<List<RacerReview>> getRacerReviews() {
    return _firestore.collection('racer_reviews').snapshots().map(
        (snapshot) => snapshot.docs.map((doc) => RacerReview.fromFirestore(doc)).toList());
  }

  Future<void> saveRacerReview(RacerReview review) async {
    if (review.id == null) {
      await _firestore.collection('racer_reviews').add(review.toMap());
    } else {
      await _firestore.collection('racer_reviews').doc(review.id).update(review.toMap());
    }
  }

  Future<void> deleteRacerReview(String id) async {
    await _firestore.collection('racer_reviews').doc(id).delete();
  }
}
