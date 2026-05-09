import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mahjong_tracker/models/machine_type.dart';

/// スロット専用の台の種類サービス（パチンコの machine_types とは別コレクション）
class SlotMachineTypeService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _collectionName = 'slot_machine_types';

  Future<void> addMachineType(MachineType machineType) async {
    await _firestore.collection(_collectionName).add(machineType.toMap());
  }

  Stream<List<MachineType>> getMachineTypes() {
    return _firestore
        .collection(_collectionName)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => MachineType.fromFirestore(doc)).toList();
    });
  }

  Future<void> updateMachineType(MachineType machineType) async {
    final id = machineType.id;
    if (id == null || id.isEmpty) return;

    try {
      final docRef = _firestore.collection(_collectionName).doc(id);
      final docSnap = await docRef.get();
      if (docSnap.exists) {
        await docRef.update(machineType.toMap());
      }
    } catch (e) {
      print('Error updating slot_machine_type: $e');
    }
  }

  Future<void> deleteMachineType(String id) async {
    try {
      final docRef = _firestore.collection(_collectionName).doc(id);
      final docSnap = await docRef.get();
      if (docSnap.exists) {
        await docRef.delete();
      }
    } catch (e) {
      print('Error deleting slot_machine_type: $e');
    }
  }
}
