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
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDarkMode ? const Color(0xFF1E1E1E) : Colors.white; // Màu thẻ bài
    final textColor = isDarkMode ? Colors.white : Colors.black;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Lịch sử đơn hàng'),
        elevation: 0,
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
      ),
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

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            // --- GIAO DIỆN KHI TRỐNG ---
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.receipt_long_outlined, size: 80, color: Colors.grey.shade600),
                  const SizedBox(height: 16),
                  Text("Bạn chưa có đơn hàng nào", style: TextStyle(color: textColor, fontSize: 16)),
                ],
              ),
            );
          }

          final docs = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final order = OrderModel.fromFirestore(docs[index]);

              // Màu sắc trạng thái
              Color statusColor = Colors.grey;
              String statusText = '';
              if (order.status == 'pending') { statusColor = Colors.blue; statusText = 'Đang xử lý'; }
              else if (order.status == 'preparing') { statusColor = Colors.orange; statusText = 'Đang chuẩn bị'; }
              else if (order.status == 'shipping') { statusColor = Colors.purple; statusText = 'Đang giao'; }
              else if (order.status == 'completed') { statusColor = Colors.green; statusText = 'Hoàn thành'; }

              return Card(
                color: cardColor, // Tự động đổi màu
                elevation: 2,
                margin: const EdgeInsets.only(bottom: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                child: InkWell(
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => OrderTrackingScreen(order: order)));
                  },
                  borderRadius: BorderRadius.circular(15),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                                '#${order.id.substring(0,6).toUpperCase()}',
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: textColor)
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: statusColor.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(statusText, style: TextStyle(color: statusColor, fontSize: 12, fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ),
                        const Divider(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                                '${order.date.day}/${order.date.month}/${order.date.year}',
                                style: TextStyle(color: Colors.grey.shade500, fontSize: 13)
                            ),
                            Text(
                                '${order.totalPrice.toStringAsFixed(0)}đ',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.orange)
                            ),
                          ],
                        ),
                        const SizedBox(height: 5),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "${order.items.length} món ăn",
                            style: TextStyle(color: textColor.withOpacity(0.7), fontSize: 13),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}