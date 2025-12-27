import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

enum UserRole { customer, admin }

class UserProfile {
  final String uid;
  final String email;
  final String name;
  final String phone;
  final String address; // <--- Mới thêm trường này
  final UserRole role;
  final DateTime createdAt;

  UserProfile({
    required this.uid,
    required this.email,
    required this.name,
    required this.phone,
    this.address = '', // Mặc định là rỗng
    required this.role,
    required this.createdAt,
  });

  factory UserProfile.fromFirestore(Map<String, dynamic> data, String uid) {
    return UserProfile(
      uid: uid,
      email: data['email'] ?? '',
      name: data['name'] ?? '',
      phone: data['phone'] ?? '',
      address: data['address'] ?? '', // <--- Đọc địa chỉ từ Firebase
      role: data['role'] == 'admin' ? UserRole.admin : UserRole.customer,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? get currentUser => _auth.currentUser;
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // ĐĂNG KÝ
  Future<UserCredential?> signUp({
    required String email,
    required String password,
    required String name,
    required String phone,
    UserRole role = UserRole.customer,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user != null) {
        await credential.user!.updateDisplayName(name);
        await credential.user!.reload();
      }

      await _firestore.collection('users').doc(credential.user!.uid).set({
        'email': email,
        'name': name,
        'phone': phone,
        'address': '', // Tạo mới chưa có địa chỉ
        'role': role.name,
        'createdAt': FieldValue.serverTimestamp(),
      });

      return credential;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  // ĐĂNG NHẬP
  Future<UserCredential?> signIn({
    required String email,
    required String password,
  }) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  // ĐĂNG XUẤT
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // LẤY PROFILE
  Future<UserProfile?> getUserProfile(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        return UserProfile.fromFirestore(doc.data() as Map<String, dynamic>, uid);
      }
      return null;
    } catch (e) {
      print('Error getting user profile: $e');
      return null;
    }
  }

  // CẬP NHẬT PROFILE (Đã thêm Address)
  Future<void> updateProfile({
    required String uid,
    required String name,
    required String phone,
    required String address,
  }) async {
    try {
      await _firestore.collection('users').doc(uid).update({
        'name': name,
        'phone': phone,
        'address': address,
      });
      if (_auth.currentUser != null) {
        await _auth.currentUser!.updateDisplayName(name);
      }
    } catch (e) {
      print("Lỗi update profile: $e");
      throw e;
    }
  }

  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'email-already-in-use': return 'Email này đã được sử dụng.';
      case 'user-not-found': return 'Không tìm thấy tài khoản.';
      case 'wrong-password': return 'Mật khẩu không đúng.';
      default: return 'Lỗi: ${e.message}';
    }
  }

  // --- LOGIC YÊU THÍCH (FAVORITES) ---

  // Lấy danh sách ID yêu thích (Stream realtime)
  Stream<List<String>> getUserFavorites() {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return const Stream.empty();

    return _firestore.collection('users').doc(uid).snapshots().map((snapshot) {
      if (snapshot.exists && snapshot.data()!.containsKey('favorites')) {
        return List<String>.from(snapshot.data()!['favorites']);
      }
      return [];
    });
  }

  // Toggle: Nếu chưa like thì thêm, like rồi thì xóa
  Future<void> toggleFavorite(String productId, bool isCurrentlyFavorite) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    if (isCurrentlyFavorite) {
      // Xóa khỏi danh sách
      await _firestore.collection('users').doc(uid).update({
        'favorites': FieldValue.arrayRemove([productId])
      });
    } else {
      // Thêm vào danh sách
      await _firestore.collection('users').doc(uid).update({
        'favorites': FieldValue.arrayUnion([productId])
      });
    }
  }
}
