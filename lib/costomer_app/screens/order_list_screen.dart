import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/order_model.dart';
import 'order_tracking_screen.dart';

class OrderListScreen extends StatelessWidget {
  const OrderListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      appBar: AppBar(title: const Text('Lịch sử đơn hàng'), backgroundColor: Colors.white),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('orders')
            .where('userId', isEqualTo: uid)
            .orderBy('date', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // --- SỬA LỖI TẠI ĐÂY ---
          // Phải dùng snapshot.data!.docs thay vì snapshot.docs
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("Bạn chưa có đơn hàng nào"));
          }

          final docs = snapshot.data!.docs; // Lấy danh sách ra biến cho gọn

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final order = OrderModel.fromFirestore(docs[index]);

              // Màu sắc trạng thái
              Color statusColor = Colors.grey;
              String statusText = '';
              if (order.status == 'pending') {
                statusColor = Colors.blue;
                statusText = 'Đang xử lý';
              } else if (order.status == 'shipping') {
                statusColor = Colors.orange;
                statusText = 'Đang giao';
              } else if (order.status == 'completed') {
                statusColor = Colors.green;
                statusText = 'Hoàn thành';
              }

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  title: Text('Đơn hàng #${order.id.substring(0,4).toUpperCase()}'),
                  subtitle: Text('${order.date.day}/${order.date.month} - ${order.totalPrice}đ'),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      // Fix warning withOpacity bằng cách dùng withAlpha hoặc màu shade nhẹ
                      color: statusColor.withAlpha(30),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                        statusText,
                        style: TextStyle(color: statusColor, fontSize: 12, fontWeight: FontWeight.bold)
                    ),
                  ),
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => OrderTrackingScreen(order: order))
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}