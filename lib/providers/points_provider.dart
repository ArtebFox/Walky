import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PointsNotifier extends StateNotifier<int> {
  PointsNotifier() : super(0);

  /// Charger les points depuis Firebase
  Future<void> loadPoints() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    if (doc.exists) {
      state = doc.data()?['totalPoints'] ?? 0;
    }
  }

  /// Ajouter des points après conversion
  void addPoints(int points) {
    state += points;
  }

  /// reset si besoin
  void setPoints(int points) {
    state = points;
  }
}

final pointsProvider =
StateNotifierProvider<PointsNotifier, int>((ref) {
  return PointsNotifier();
});