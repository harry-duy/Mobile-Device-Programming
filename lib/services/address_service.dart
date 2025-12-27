import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

// 1. Model
class AddressModel {
  final String id;
  final String name;
  final String phone;
  final String detail;
  final bool isDefault;

  AddressModel({
    required this.id,
    required this.name,
    required this.phone,
    required this.detail,
    this.isDefault = false,
  });

  factory AddressModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return AddressModel(
      id: doc.id,
      name: data['name'] ?? '',
      phone: data['phone'] ?? '',
      detail: data['detail'] ?? '',
      isDefault: data['isDefault'] ?? false,
    );
  }
}

// 2. Service
class AddressService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Lấy danh sách địa chỉ
  Stream<List<AddressModel>> getUserAddresses() {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return const Stream.empty();

    return _firestore
        .collection('users')
        .doc(uid)
        .collection('addresses')
        .orderBy('isDefault', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => AddressModel.fromFirestore(doc))
        .toList());
  }

  // Lưu địa chỉ
  Future<void> saveAddress({String? id, required String name, required String phone, required String detail, bool isDefault = false}) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    final collection = _firestore.collection('users').doc(uid).collection('addresses');

    // Nếu đặt làm mặc định, reset các cái khác trước
    if (isDefault) {
      final allDocs = await collection.get();
      for (var doc in allDocs.docs) {
        await doc.reference.update({'isDefault': false});
      }
      // Đồng bộ ra profile chính
      await _firestore.collection('users').doc(uid).update({
        'address': detail,
        'phone': phone,
      });
    }

    final data = {
      'name': name,
      'phone': phone,
      'detail': detail,
      'isDefault': isDefault,
    };

    if (id == null) {
      // Thêm mới: Nếu list rỗng thì cái đầu tiên auto là mặc định
      final snapshot = await collection.get();
      if (snapshot.docs.isEmpty) {
        data['isDefault'] = true;
        await _firestore.collection('users').doc(uid).update({'address': detail, 'phone': phone});
      }
      await collection.add(data);
    } else {
      await collection.doc(id).update(data);
    }
  }

  Future<void> deleteAddress(String id) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;
    await _firestore.collection('users').doc(uid).collection('addresses').doc(id).delete();
  }

  Future<void> setDefaultAddress(AddressModel address) async {
    await saveAddress(
        id: address.id,
        name: address.name,
        phone: address.phone,
        detail: address.detail,
        isDefault: true
    );
  }

  // 1. Lấy danh sách ID các món đã tim (Stream để tự động cập nhật màu đỏ)
  Stream<List<String>> getUserFavorites() {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return const Stream.empty();

    return _firestore.collection('users').doc(uid).snapshots().map((snapshot) {
      if (snapshot.exists && snapshot.data()!.containsKey('favorites')) {
        // Ép kiểu dữ liệu từ Firebase về List<String>
        return List<String>.from(snapshot.data()!['favorites']);
      }
      return []; // Nếu chưa tim món nào thì trả về list rỗng
    });
  }

  // 2. Hàm Bấm tim (Toggle)
  Future<void> toggleFavorite(String productId, bool isCurrentlyFavorite) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    final userRef = _firestore.collection('users').doc(uid);

    if (isCurrentlyFavorite) {
      // Nếu đang thích -> Bấm lần nữa là XÓA (Gỡ tim)
      await userRef.update({
        'favorites': FieldValue.arrayRemove([productId])
      });
    } else {
      // Nếu chưa thích -> Bấm là THÊM (Hiện tim đỏ)
      await userRef.update({
        'favorites': FieldValue.arrayUnion([productId])
      });
    }
  }
}