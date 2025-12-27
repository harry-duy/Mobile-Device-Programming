import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/models.dart';

class FirebaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Lấy User hiện tại
  User? getCurrentUser() => _auth.currentUser;

  // Lấy danh sách sản phẩm
  Stream<QuerySnapshot> getProducts() {
    return _db.collection('products').snapshots();
  }

  // Đặt hàng (Customer)
  Future<void> placeOrder({
    required String address,
    required List<dynamic> items,
    required double total,
    String? notes,
  }) async {
    await _db.collection('orders').add({
      'userId': _auth.currentUser?.uid,
      'customerName': _auth.currentUser?.displayName ?? "Khách hàng",
      'items': items,
      'totalAmount': total,
      'status': 'pending',
      'deliveryAddress': address,
      'orderDate': FieldValue.serverTimestamp(),
      'notes': notes,
    });
  }

  // Hàm lấy thống kê cho Admin Dashboard
  Future<Map<String, dynamic>> getOrderStatistics() async {
    try {
      // 1. Lấy tất cả tài liệu từ collection 'orders'
      QuerySnapshot snapshot = await _db.collection('orders').get();

      int totalOrders = snapshot.docs.length;
      double totalRevenue = 0;
      int pendingOrders = 0;
      int completedOrders = 0;

      // 2. Duyệt qua từng đơn hàng để tính toán
      for (var doc in snapshot.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

        // Cộng dồn doanh thu (sử dụng trường 'totalAmount' bạn đã định nghĩa trong hàm placeOrder)
        totalRevenue += (data['totalAmount'] ?? 0).toDouble();

        // Đếm trạng thái đơn hàng
        String status = data['status'] ?? 'pending';
        if (status == 'pending') {
          pendingOrders++;
        } else if (status == 'completed') {
          completedOrders++;
        }
      }

      // 3. Trả về kết quả dưới dạng Map
      return {
        'totalOrders': totalOrders,
        'totalRevenue': totalRevenue,
        'pendingOrders': pendingOrders,
        'completedOrders': completedOrders,
      };
    } catch (e) {
      print("Lỗi khi lấy thống kê: $e");
      return {
        'totalOrders': 0,
        'totalRevenue': 0.0,
        'pendingOrders': 0,
        'completedOrders': 0,
      };
    }
  }

  // Admin: Lấy TẤT CẢ đơn hàng (Dùng trong admin_home_screen.dart)
  Stream<QuerySnapshot> getAllOrders() {
    return _db.collection('orders')
        .orderBy('orderDate', descending: true)
        .snapshots();
  }

  // Khách hàng: Lấy đơn hàng cá nhân
  Stream<QuerySnapshot> getCustomerOrders() {
    return _db.collection('orders')
        .where('userId', isEqualTo: _auth.currentUser?.uid)
        .orderBy('orderDate', descending: true)
        .snapshots();
  }

  // Cập nhật trạng thái đơn hàng (Dùng trong admin_home_screen.dart)
  Future<void> updateOrderStatus(String orderId, String newStatus) async {
    await _db.collection('orders').doc(orderId).update({
      'status': newStatus,
    });
  }

  // Khách hàng xác nhận đã nhận hàng
  Future<void> confirmReceived(String orderId) async {
    await updateOrderStatus(orderId, 'completed');
  }
}