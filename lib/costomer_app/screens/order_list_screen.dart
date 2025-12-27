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


        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.shopping_bag_outlined,
                    size: 80, color: Colors.grey.shade300),
                const SizedBox(height: 16),
                Text(
                  "Chưa có đơn hàng nào",
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(8),
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            final doc = snapshot.data!.docs[index];
            final order = OrderModel.fromFirestore(
                doc.data() as Map<String, dynamic>, doc.id);

            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              elevation: 2,
              child: ExpansionTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(

                    color: order.status.color.withOpacity(0.1),

                    color: order.status.color.withValues(alpha: 0.1),

                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    _getStatusIcon(order.status),
                    color: order.status.color,
                  ),
                ),
                title: Text(
                  "Đơn #${order.id.substring(0, 8)}",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 4),
                    Text(
                      DateFormat('dd/MM/yyyy HH:mm').format(order.orderDate),
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(

                        color: order.status.color.withOpacity(0.2),

                        color: order.status.color.withValues(alpha: 0.1),

                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        order.status.displayName,
                        style: TextStyle(
                          color: order.status.color,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                trailing: Text(
                  "${NumberFormat('#,###').format(order.totalAmount)} VNĐ",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.orange,
                    fontSize: 16,
                  ),
                ),
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Chi tiết món ăn
                        _buildSectionTitle("Món ăn đã đặt"),
                        ...order.items.map((item) => Padding(
                          padding: const EdgeInsets.only(left: 16, top: 4),
                          child: Row(
                            mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  "• ${item['name']} x ${item['quantity']}",
                                ),
                              ),
                              Text(
                                "${NumberFormat('#,###').format(item['price'] * item['quantity'])} VNĐ",
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        )),
                        const Divider(height: 24),

                        // Thông tin giao hàng
                        _buildSectionTitle("Địa chỉ giao hàng"),
                        _buildInfoRow(
                            Icons.location_on, order.deliveryAddress),
                        if (order.customerPhone.isNotEmpty)
                          _buildInfoRow(Icons.phone, order.customerPhone),


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