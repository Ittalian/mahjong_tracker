import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mahjong_tracker/models/place.dart';

class PlaceService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _collectionName = 'places';

  Future<void> addPlace(Place place) async {
    await _firestore.collection(_collectionName).add(place.toMap());
  }

  Stream<List<Place>> getPlaces(String category) {
    return _firestore
        .collection(_collectionName)
        .where('category', isEqualTo: category)
        .snapshots()
        .map((snapshot) {
      final places = snapshot.docs.map((doc) => Place.fromFirestore(doc)).toList();
      places.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return places;
    });
  }

  Future<void> updatePlace(Place place) async {
    final id = place.id;
    if (id == null || id.isEmpty) return;

    try {
      final docRef = _firestore.collection(_collectionName).doc(id);
      final docSnap = await docRef.get();
      if (docSnap.exists) {
        await docRef.update(place.toMap());
      }
    } catch (e) {
      print('Error updating place: $e');
    }
  }

  Future<void> deletePlace(String id) async {
    try {
      final docRef = _firestore.collection(_collectionName).doc(id);
      final docSnap = await docRef.get();
      if (docSnap.exists) {
        await docRef.delete();
      }
    } catch (e) {
      print('Error deleting place: $e');
    }
  }
}
