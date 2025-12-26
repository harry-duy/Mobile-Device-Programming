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

                        // Thông tin shipper nếu có
                        if (order.shipperInfo != null &&
                            !order.shipperInfo!.isEmpty) ...[
                          const Divider(height: 24),
                          _buildSectionTitle("Thông tin người giao hàng"),
                          _buildInfoRow(
                              Icons.person, order.shipperInfo!.name),
                          _buildInfoRow(
                              Icons.phone, order.shipperInfo!.phone),
                          if (order.shipperInfo!.vehicleNumber.isNotEmpty)
                            _buildInfoRow(Icons.motorcycle,
                                order.shipperInfo!.vehicleNumber),
                        ],

                        // Ghi chú
                        if (order.notes != null && order.notes!.isNotEmpty) ...[
                          const Divider(height: 24),
                          _buildSectionTitle("Ghi chú"),
                          Text(order.notes!,
                              style: TextStyle(color: Colors.grey.shade700)),
                        ],

                        // Nút xác nhận đã nhận hàng
                        if (order.status == OrderStatus.delivered) ...[
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            height: 48,
                            child: ElevatedButton.icon(
                              onPressed: () => _confirmReceived(
                                  context, service, order.id),
                              icon: const Icon(Icons.check_circle),
                              label: const Text(
                                "XÁC NHẬN ĐÃ NHẬN HÀNG",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                        ],

                        // Hiển thị thời gian hoàn thành
                        if (order.status == OrderStatus.completed &&
                            order.completedAt != null) ...[
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.green.shade50,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.green.shade200),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.check_circle,
                                    color: Colors.green),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    "Hoàn thành lúc ${DateFormat('dd/MM/yyyy HH:mm').format(order.completedAt!)}",
                                    style: const TextStyle(
                                      color: Colors.green,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.grey.shade600),
          const SizedBox(width: 8),
          Expanded(
            child: Text(text, style: TextStyle(color: Colors.grey.shade700)),
          ),
        ],
      ),
    );
  }

  IconData _getStatusIcon(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return Icons.access_time;
      case OrderStatus.accepted:
        return Icons.check;
        return Icons.inventory;
      case OrderStatus.shipping:
        return Icons.delivery_dining;
      case OrderStatus.delivered:
        return Icons.home;
      case OrderStatus.completed:
        return Icons.check_circle;
      case OrderStatus.cancelled:
        return Icons.cancel;
    }
  }

  void _confirmReceived(
      BuildContext context, FirebaseService service, String orderId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Xác nhận nhận hàng"),
        content: const Text(
            "Bạn đã nhận được đơn hàng này chưa? Sau khi xác nhận, đơn hàng sẽ được đánh dấu là hoàn thành."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Chưa"),
          ),
          ElevatedButton(
            onPressed: () async {
              await service.confirmReceived(orderId);
              if (!context.mounted) return;
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Cảm ơn bạn! Đơn hàng đã hoàn thành."),
                  backgroundColor: Colors.green,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            child: const Text("Đã nhận"),
          ),
        ],
      ),
    );
  }
}