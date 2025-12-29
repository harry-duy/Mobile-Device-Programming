import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/order_model.dart';
import 'order_tracking_screen.dart';
import 'rate_order_dialog.dart';

class OrderListScreen extends StatelessWidget {
  const OrderListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDarkMode ? const Color(0xFF1E1E1E) : Colors.white;
    final textColor = isDarkMode ? Colors.white : Colors.black;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Lịch sử đơn hàng'),
        elevation: 0,
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
              final data = docs[index].data() as Map<String, dynamic>;
              final orderId = docs[index].id;
              final order = OrderModel.fromFirestore(docs[index]);
              final bool isRated = data['isRated'] ?? false;

              Color statusColor = Colors.grey;
              String statusText = '';
              if (order.status == 'pending') { statusColor = Colors.orange; statusText = 'Chờ xác nhận'; }
              else if (order.status == 'preparing') { statusColor = Colors.blue; statusText = 'Đang chuẩn bị'; }
              else if (order.status == 'shipping') { statusColor = Colors.purple; statusText = 'Đang giao'; }
              else if (order.status == 'completed') { statusColor = Colors.green; statusText = 'Hoàn thành'; }
              else if (order.status == 'cancelled') { statusColor = Colors.red; statusText = 'Đã hủy'; }

              return Card(
                color: cardColor,
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
                                '${order.date.day}/${order.date.month}/${order.date.year} ${order.date.hour}:${order.date.minute}',
                                style: TextStyle(color: Colors.grey.shade500, fontSize: 13)
                            ),
                            Text(
                                '${order.totalPrice.toStringAsFixed(0)}đ',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.orange)
                            ),
                          ],
                        ),

                        // NÚT ĐÁNH GIÁ
                        if (order.status == 'completed') ...[
                          const SizedBox(height: 15),
                          if (isRated)
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              decoration: BoxDecoration(color: Colors.green.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                              child: const Center(child: Text("Đã đánh giá ⭐", style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold))),
                            )
                          else
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                icon: const Icon(Icons.star, size: 18),
                                label: const Text("ĐÁNH GIÁ ĐƠN HÀNG"),
                                style: ElevatedButton.styleFrom(backgroundColor: Colors.orange, foregroundColor: Colors.white, elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                                onPressed: () {
                                  Navigator.push(context, MaterialPageRoute(builder: (_) => RateOrderDialog(orderId: orderId, items: order.items)));
                                },
                              ),
                            )
                        ]
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