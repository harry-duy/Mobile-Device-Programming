import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../../services/firebase_service.dart';
import '../../models/models.dart';

class OrderListScreen extends StatelessWidget {
  const OrderListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final FirebaseService service = FirebaseService();

    return StreamBuilder<QuerySnapshot>(
      stream: service.getCustomerOrders(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

        return ListView.builder(
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            final doc = snapshot.data!.docs[index];
            final order = OrderModel.fromFirestore(doc.data() as Map<String, dynamic>, doc.id);

            return Card(
              margin: const EdgeInsets.all(8),
              child: ListTile(
                title: Text("Đơn hàng ngày ${DateFormat('dd/MM/yyyy').format(order.orderDate)}"),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Tổng tiền: ${order.totalAmount.toInt()} VNĐ"),
                    Text("Trạng thái: ${order.status.displayName}"), // Đã fix lỗi displayName
                  ],
                ),
                trailing: Icon(Icons.circle, color: order.status.color), // Đã fix lỗi color
              ),
            );
          },
        );
      },
    );
  }
}