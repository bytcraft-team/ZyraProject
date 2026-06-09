import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../database/cycle_dao.dart';
import '../models/cycle_model.dart';
 
class CycleRepository {
  final CycleDao _dao = CycleDao();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
 
  String? get _uid => _auth.currentUser?.uid;
 
  // ── Sauvegarder le cycle ─────────────────────────────────
  Future<CycleResult<CycleModel>> saveCycle({
    required String userId,
    required int dureeCycle,
    required int dureeRegles,
    required DateTime derniereRegles,
    required bool modeGrossesse,
  }) async {
    try {
      // 1. Vérifier si un cycle existe déjà
      final existing = await _dao.getByUserId(userId);
 
      final cycle = CycleModel(
        id: existing?.id,
        userId: userId,
        dureeCycle: dureeCycle,
        dureeRegles: dureeRegles,
        derniereRegles: derniereRegles,
        modeGrossesse: modeGrossesse,
      );
 
      int savedId;
 
      // 2. Sauvegarder dans SQLite (offline first)
      if (existing == null) {
        savedId = await _dao.insertOrReplace(cycle);
      } else {
        await _dao.update(cycle);
        savedId = existing.id!;
      }
 
      final savedCycle = cycle.copyWith(id: savedId);
 
      // 3. Sauvegarder dans Firestore si connecté
      if (_uid != null) {
        await _firestore
            .collection('users')
            .doc(_uid)
            .collection('cycle')
            .doc('settings')
            .set(savedCycle.toFirestore());
      }
 
      return CycleResult.success(savedCycle);
    } catch (e) {
      return CycleResult.error('Erreur sauvegarde cycle : $e');
    }
  }
 
  // ── Récupérer le cycle ───────────────────────────────────
  Future<CycleModel?> getCycle(String userId) async {
    // 1. Chercher localement d'abord
    CycleModel? cycle = await _dao.getByUserId(userId);
 
    // 2. Si pas trouvé localement → chercher dans Firestore
    if (cycle == null && _uid != null) {
      try {
        final doc = await _firestore
            .collection('users')
            .doc(_uid)
            .collection('cycle')
            .doc('settings')
            .get();
 
        if (doc.exists && doc.data() != null) {
          final data = doc.data()!;
          final remoteCycle = CycleModel(
            userId: userId,
            dureeCycle: data['duree_cycle'] ?? 28,
            dureeRegles: data['duree_regles'] ?? 5,
            derniereRegles: DateTime.parse(data['derniere_regles']),
            modeGrossesse: data['mode_grossesse'] ?? false,
          );
          // Sauvegarder localement pour usage offline
          final id = await _dao.insertOrReplace(remoteCycle);
          cycle = remoteCycle.copyWith(id: id);
        }
      } catch (e) {
        // Pas de connexion — on garde null
      }
    }
 
    return cycle;
  }
 
  // ── Supprimer le cycle ───────────────────────────────────
  Future<void> deleteCycle(String userId) async {
    await _dao.delete(userId);
    if (_uid != null) {
      await _firestore
          .collection('users')
          .doc(_uid)
          .collection('cycle')
          .doc('settings')
          .delete();
    }
  }
}
 
// ── Classe résultat ───────────────────────────────────────
class CycleResult<T> {
  final bool success;
  final T? data;
  final String? errorMessage;
 
  CycleResult._({required this.success, this.data, this.errorMessage});
  factory CycleResult.success(T data) =>
      CycleResult._(success: true, data: data);
  factory CycleResult.error(String msg) =>
      CycleResult._(success: false, errorMessage: msg);
}