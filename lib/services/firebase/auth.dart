import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  // ---------------- LOGIN ----------------
  Future<UserCredential> loginWithEmailAndPassword(
      String email, String password) async {
    return await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password.trim(),
    );
  }

  // ---------------- REGISTER ----------------
  Future<UserCredential> createUserWithEmailAndPassword(
      String email, String password) async {

    final credential = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password.trim(),
    );

    await _createUserIfNotExists(credential.user!, "email");

    return credential;
  }

  // ---------------- GOOGLE SIGN-IN ----------------
  Future<UserCredential> signInWithGoogle() async {
    final googleUser = await GoogleSignIn().signIn();
    final googleAuth = await googleUser!.authentication;

    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    final userCredential =
    await _auth.signInWithCredential(credential);

    await _createUserIfNotExists(userCredential.user!, "google");

    return userCredential;
  }

  // ---------------- FIRESTORE INIT ----------------
  Future<void> _createUserIfNotExists(User user, String provider) async {
    final userRef = _firestore.collection('users').doc(user.uid);
    final doc = await userRef.get();

    if (!doc.exists) {
      await userRef.set({
        'email': user.email,
        'provider': provider,
        'totalPoints': 0,
        'lastConvertedSteps': 0,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    }
  }

  /// 🔹 Stream (login/logout en temps réel)
  Stream<User?> get authStateChanges => _auth.authStateChanges();
}
