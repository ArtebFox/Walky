import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hive/hive.dart';

class AvatarState {
  final String hair;
  final String head;
  final String body;
  final String legs;
  final String hand;

  AvatarState({
    required this.hair,
    required this.head,
    required this.body,
    required this.legs,
    required this.hand,
  });

  AvatarState copyWith({
    String? hair,
    String? head,
    String? body,
    String? legs,
    String? hand,
  }) {
    return AvatarState(
      hair: hair ?? this.hair,
      head: head ?? this.head,
      body: body ?? this.body,
      legs: legs ?? this.legs,
      hand: hand ?? this.hand,
    );
  }
}

class AvatarNotifier extends StateNotifier<AvatarState> {
  AvatarNotifier()
      : super(
    AvatarState(
      hair: 'assets/avatar/Hair1.png',
      head: 'assets/avatar/Head1.png',
      body: 'assets/avatar/Body1.png',
      legs: 'assets/avatar/Pants1.png',
      hand: 'assets/avatar/Hand.png',
    ),
  );

  /// Charger depuis Firebase
  Future<void> loadAvatar() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    if (doc.exists) {
      final eq = doc.data()?['equipped'] ?? {};

      state = state.copyWith(
        head: eq['head'],
        hair: eq['hair'],
        body: eq['body'],
        legs: eq['legs'],
        hand: eq['hand'],
      );
    }
  }

  /// Mettre à jour localement
  void updateAvatar({
    required String head,
    required String hair,
    required String body,
    required String legs,
    required String hand,
  }) {

    state = state.copyWith(
      head: head,
      hair: hair,
      body: body,
      legs: legs,
      hand: hand,
    );

    final box = Hive.box('walkyBox');

    box.put('avatar_head', head);
    box.put('avatar_hair', hair);
    box.put('avatar_body', body);
    box.put('avatar_legs', legs);
    box.put('avatar_hand', hand);
  }
}

final avatarProvider =
StateNotifierProvider<AvatarNotifier, AvatarState>((ref) {
  return AvatarNotifier();
});