import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Admin Login Logic
  Future<UserCredential?> loginAdmin(String email, String password) async {
    try {
      // 1. Authenticate with Firebase Auth
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // 2. Check if user has 'admin' role in Firestore
      DocumentSnapshot userDoc = await _db
          .collection('users')
          .doc(userCredential.user!.uid)
          .get();

      if (userDoc.exists && userDoc.get('role') == 'admin') {
        return userCredential;
      } else {
        // Sign out if not an admin
        await _auth.signOut();
        throw Exception("Access Denied: You do not have admin privileges.");
      }
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message ?? "An error occurred during login.");
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  // Logout
  Future<void> logout() async {
    await _auth.signOut();
  }

  // Get current admin
  User? get currentAdmin => _auth.currentUser;
}
