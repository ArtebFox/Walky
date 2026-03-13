import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hive/hive.dart';

class UserState {
  final int points;
  final int todaySteps;
  final List<String> inventory;
  final String lastConvertDate;

  UserState({
    required this.points,
    required this.todaySteps,
    required this.inventory,
    required this.lastConvertDate,
  });

  UserState copyWith({
    int? points,
    int? todaySteps,
    List<String>? inventory,
    String? lastConvertDate,
  }) {
    return UserState(
      points: points ?? this.points,
      todaySteps: todaySteps ?? this.todaySteps,
      inventory: inventory ?? this.inventory,
      lastConvertDate: lastConvertDate ?? this.lastConvertDate,
    );
  }
}

class UserNotifier extends StateNotifier<UserState?> {
  UserNotifier() : super(null);

  Future<void> loadUser() async {
    final box = Hive.box('walkyBox');
    final String today = DateTime.now().toString().split(' ')[0];

    // 1️⃣ LOAD LOCAL DATA WITH DATE CHECK
    int localPoints = box.get('points', defaultValue: 0);
    String localLastReset = box.get('lastResetDate', defaultValue: "");

    // CRITICAL: If the saved date isn't today, ignore the cached steps
    int localSteps = (localLastReset == today)
        ? box.get('todaySteps', defaultValue: 0)
        : 0;

    List<String> localInventory = List<String>.from(box.get('inventory', defaultValue: []));
    String localLastConvert = box.get('lastConvertDate', defaultValue: "");

    state = UserState(
      points: localPoints,
      todaySteps: localSteps,
      inventory: localInventory,
      lastConvertDate: localLastConvert,
    );

    // 2️⃣ SYNC WITH FIREBASE (Background update)
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();

      if (doc.exists) {
        final data = doc.data()!;
        String dbResetDate = data['lastResetDate'] ?? "";

        int points = data['totalPoints'] ?? 0;
        int steps = (dbResetDate == today) ? (data['todaySteps'] ?? 0) : 0;
        List<String> inventory = List<String>.from(data['inventory'] ?? []);
        String lastConvert = data['lastConvertDate'] ?? "";

        state = UserState(
          points: points,
          todaySteps: steps,
          inventory: inventory,
          lastConvertDate: lastConvert,
        );

        // 3️⃣ UPDATE HIVE CACHE
        box.put('points', points);
        box.put('todaySteps', steps);
        box.put('inventory', inventory);
        box.put('lastConvertDate', lastConvert);
        box.put('lastResetDate', today); // Ensure we save today's date
      }
    } catch (e) {
      print("Firebase Sync Error: $e"); // App continues using Hive data
    }
  }

  // --- STEPS LOGIC ---

  void updateSteps(int steps) {
    if (state == null) return;
    state = state!.copyWith(todaySteps: steps);

    final box = Hive.box('walkyBox');
    box.put('todaySteps', steps);
    box.put('lastResetDate', DateTime.now().toString().split(' ')[0]);
  }

  void completeConversion(int stepsSubtracted, int pointsEarned) {
    if (state == null) return;
    final String today = DateTime.now().toString().split(' ')[0];

    int newSteps = (state!.todaySteps - stepsSubtracted).clamp(0, 999999);
    int newPoints = state!.points + pointsEarned;

    state = state!.copyWith(
      todaySteps: newSteps,
      points: newPoints,
      lastConvertDate: today,
    );

    final box = Hive.box('walkyBox');
    box.put('todaySteps', newSteps);
    box.put('points', newPoints);
    box.put('lastConvertDate', today);
  }

  // --- POINTS & INVENTORY LOGIC ---

  void addPoints(int points) {
    if (state == null) return;

    int newPoints = state!.points + points;

    state = state!.copyWith(points: newPoints);

    Hive.box('walkyBox').put('points', newPoints);
  }

  void spendPoints(int points) {
    if (state == null) return;

    int newPoints = state!.points - points;
    if (newPoints < 0) newPoints = 0;

    state = state!.copyWith(points: newPoints);

    Hive.box('walkyBox').put('points', newPoints);
  }


  void addItem(String itemId) {
    if (state == null) return;
    if (state!.inventory.contains(itemId)) return;

    List<String> newInventory = [...state!.inventory, itemId];
    state = state!.copyWith(inventory: newInventory);
    Hive.box('walkyBox').put('inventory', newInventory);
  }

}

final userProvider = StateNotifierProvider<UserNotifier, UserState?>((ref) {
  return UserNotifier();
});

