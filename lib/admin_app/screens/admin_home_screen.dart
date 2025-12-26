import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../../services/firebase_service.dart';
import '../../models/models.dart';

class AdminHomeScreen extends StatelessWidget {
  const AdminHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final FirebaseService service = FirebaseService();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Quản lý Đơn hàng"),
        backgroundColor: Colors.blueGrey,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              // Thêm logic đăng xuất nếu cần
            },
          )
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: service.getAllOrders(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("Chưa có đơn hàng nào."));
          }

          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              final doc = snapshot.data!.docs[index];
              final order = OrderModel.fromFirestore(doc.data() as Map<String, dynamic>, doc.id);

              return Card(
                margin: const EdgeInsets.all(10),
                child: ExpansionTile(
                  leading: Icon(Icons.receipt_long, color: order.status.color),
                  title: Text("Khách: ${order.customerName}"),
                  subtitle: Text(
                    "Trạng thái: ${order.status.displayName}\n"
                        "Ngày: ${DateFormat('dd/MM HH:mm').format(order.orderDate)}",
                  ),
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Chi tiết món ăn:", style: TextStyle(fontWeight: FontWeight.bold)),
                          ...order.items.map((item) => Text("- ${item['name']} x ${item['quantity']}")),
                          const Divider(),
                          Text("Địa chỉ: ${order.deliveryAddress}"),
                          Text("Tổng tiền: ${order.totalAmount.toInt()} VNĐ",
                              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
                          const SizedBox(height: 10),
                          const Text("Cập nhật trạng thái:", style: TextStyle(fontWeight: FontWeight.bold)),
                          Wrap(
                            spacing: 8,
                            children: OrderStatus.values.map((status) {
                              return ChoiceChip(
                                label: Text(status.displayName),
                                selected: order.status == status,
                                onSelected: (selected) {
                                  if (selected) {
                                    service. updateOrderStatus(order.id, status.name);
                                  }
                                },
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}