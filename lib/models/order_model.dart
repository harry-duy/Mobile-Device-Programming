import 'package:cloud_firestore/cloud_firestore.dart';

class OrderModel {
  final String id;
  final String userId;
  final double totalPrice;
  final String status; // 'pending', 'preparing', 'shipping', 'completed', 'cancelled'
  final DateTime date;
  final List<Map<String, dynamic>> items; // Danh sách món ăn

  OrderModel({
    required this.id,
    required this.userId,
    required this.totalPrice,
    required this.status,
    required this.date,
    required this.items,
  });

  // Chuyển đổi từ Firestore về Object
  factory OrderModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return OrderModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      totalPrice: (data['totalPrice'] ?? 0).toDouble(),
      status: data['status'] ?? 'pending',
      date: (data['date'] as Timestamp).toDate(),
      items: List<Map<String, dynamic>>.from(data['items'] ?? []),
    );
  }

  // Helper: Lấy index của trạng thái để tô màu UI
  int get statusStep {
    switch (status) {
      case 'pending': return 0;   // Đã đặt
      case 'preparing': return 1; // Đang làm
      case 'shipping': return 2;  // Đang giao
      case 'completed': return 3; // Hoàn thành
      default: return 0;
    }
  }
}