import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../models/order_model.dart';
import '../admin_order_detail_screen.dart';

class AdminOrderListTab extends StatelessWidget {
  const AdminOrderListTab({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('orders')
          .orderBy('date', descending: true) // Mới nhất lên đầu
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) return const Center(child: Text("Chưa có đơn hàng nào"));

        final docs = snapshot.data!.docs;

        return ListView.builder(
          padding: const EdgeInsets.all(10),
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final order = OrderModel.fromFirestore(docs[index]);

            // Màu sắc trạng thái
            Color statusColor = Colors.grey;
            if (order.status == 'pending') statusColor = Colors.orange;
            if (order.status == 'preparing') statusColor = Colors.blue;
            if (order.status == 'shipping') statusColor = Colors.purple;
            if (order.status == 'completed') statusColor = Colors.green;
            if (order.status == 'cancelled') statusColor = Colors.red;

            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                title: Text("Đơn #${order.id.substring(0, 5).toUpperCase()}", style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("${order.date.day}/${order.date.month} ${order.date.hour}:${order.date.minute} - ${order.items.length} món"),
                    Text("${order.totalPrice}đ", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
                  ],
                ),
                trailing: Chip(
                  label: Text(order.status.toUpperCase(), style: const TextStyle(color: Colors.white, fontSize: 10)),
                  backgroundColor: statusColor,
                ),
                onTap: () {
                  // Mở trang chi tiết để xử lý
                  Navigator.push(context, MaterialPageRoute(builder: (_) => AdminOrderDetailScreen(order: order)));
                },
              ),
            );
          },
        );
      },
    );
  }
}