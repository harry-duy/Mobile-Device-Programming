import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/address_model.dart';

class AddressService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Lấy danh sách địa chỉ
  Stream<List<AddressModel>> getUserAddresses() {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return Stream.value([]);

    return _firestore
        .collection('users')
        .doc(uid)
        .collection('addresses')
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => AddressModel.fromMap(doc.data(), doc.id))
        .toList());
  }

  // Lưu địa chỉ (Thêm mới hoặc Cập nhật)
  Future<void> saveAddress(AddressModel address) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    final userRef = _firestore.collection('users').doc(uid);

    // 1. Tạo User Doc nếu chưa có
    final userDoc = await userRef.get();
    if (!userDoc.exists) {
      await userRef.set({
        'email': _auth.currentUser?.email,
        'createdAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    }

    // 2. Xử lý mặc định
    if (address.isDefault) {
      final batch = _firestore.batch();
      final allAddresses = await userRef.collection('addresses').get();
      for (var doc in allAddresses.docs) {
        if (doc.id != address.id) {
          batch.update(doc.reference, {'isDefault': false});
        }
      }
      await batch.commit();
    }

    // 3. Lưu
    if (address.id.isEmpty) {
      await userRef.collection('addresses').add(address.toMap());
    } else {
      await userRef.collection('addresses').doc(address.id).update(address.toMap());
    }
  }

  // --- HÀM MỚI: Đặt địa chỉ mặc định ---
  Future<void> setDefaultAddress(String addressId) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    final userRef = _firestore.collection('users').doc(uid);
    final batch = _firestore.batch();

    // Lấy tất cả địa chỉ
    final allAddresses = await userRef.collection('addresses').get();

    for (var doc in allAddresses.docs) {
      if (doc.id == addressId) {
        // Set cái được chọn thành true
        batch.update(doc.reference, {'isDefault': true});
      } else {
        // Set mấy cái khác thành false
        batch.update(doc.reference, {'isDefault': false});
      }
    }
    await batch.commit();
  }

  // Xóa địa chỉ
  Future<void> deleteAddress(String id) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;
    await _firestore.collection('users').doc(uid).collection('addresses').doc(id).delete();
  }
}