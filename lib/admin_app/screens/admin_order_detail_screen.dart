import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart'; // Nếu chưa cài intl thì có thể bỏ qua format hoặc dùng hàm thủ công
import '../../models/order_model.dart';

class AdminOrderDetailScreen extends StatefulWidget {
  final OrderModel order;

  const AdminOrderDetailScreen({super.key, required this.order});

  @override
  State<AdminOrderDetailScreen> createState() => _AdminOrderDetailScreenState();
}

class _AdminOrderDetailScreenState extends State<AdminOrderDetailScreen> {
  bool _isLoading = false;

  // Hàm cập nhật trạng thái & Gửi thông báo
  Future<void> _updateStatus(String newStatus) async {
    setState(() => _isLoading = true);
    try {
      // 1. Cập nhật trạng thái đơn hàng trong 'orders'
      await FirebaseFirestore.instance
          .collection('orders')
          .doc(widget.order.id)
          .update({'status': newStatus});

      // 2. GỬI THÔNG BÁO VÀO FIRESTORE (Để App khách hàng bắt được)
      String message = "";
      String title = "Cập nhật đơn hàng";

      if (newStatus == 'preparing') {
        message = "Đơn hàng #${widget.order.id.substring(0,4).toUpperCase()} đã được xác nhận và đang chuẩn bị! 🍳";
      } else if (newStatus == 'shipping') {
        message = "Tài xế đang giao đơn hàng #${widget.order.id.substring(0,4).toUpperCase()} đến bạn! 🛵";
      } else if (newStatus == 'completed') {
        message = "Đơn hàng #${widget.order.id.substring(0,4).toUpperCase()} đã giao thành công. Chúc ngon miệng! 😋";
        title = "Giao hàng thành công";
      } else if (newStatus == 'cancelled') {
        message = "Đơn hàng #${widget.order.id.substring(0,4).toUpperCase()} đã bị hủy.";
        title = "Đơn hàng bị hủy";
      }

      if (message.isNotEmpty) {
        await FirebaseFirestore.instance.collection('notifications').add({
          'userId': widget.order.userId, // Gửi đúng người đặt
          'title': title,
          'body': message,
          'isRead': false, // Chưa đọc
          'createdAt': FieldValue.serverTimestamp(),
          'orderId': widget.order.id,
        });
      }

      if (mounted) {
        Navigator.pop(context); // Quay lại danh sách
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Đã cập nhật: $newStatus và gửi thông báo.")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Lỗi: $e")));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final o = widget.order;
    // Format ngày tháng
    final dateStr = "${o.date.day}/${o.date.month} ${o.date.hour}:${o.date.minute}";

    return Scaffold(
      appBar: AppBar(title: const Text("Chi tiết đơn hàng"), backgroundColor: Colors.blueGrey),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. THÔNG TIN KHÁCH HÀNG & ĐỊA CHỈ
            const Text("Thông tin giao hàng", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Card(
              margin: const EdgeInsets.symmetric(vertical: 10),
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [const Icon(Icons.person, color: Colors.grey), const SizedBox(width: 8), Text("User ID: ${o.userId.substring(0, 5)}...")]),
                    const SizedBox(height: 5),
                    Row(children: [const Icon(Icons.access_time, color: Colors.grey), const SizedBox(width: 8), Text(dateStr)]),
                    const Divider(),
                    // Nếu bạn có lưu field 'address' trong OrderModel thì hiển thị, nếu không thì hiện ID
                    // Ở các bước trước chúng ta đã lưu chuỗi address vào DB nhưng có thể chưa map vào Model.
                    // Tạm thời hiển thị Status để debug.
                    Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.location_on, color: Colors.orange),
                          const SizedBox(width: 8),
                          Expanded(child: Text("ID Đơn: ${o.id}", style: const TextStyle(fontWeight: FontWeight.bold))),
                        ]
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(5)),
                      child: Text("Trạng thái: ${o.status.toUpperCase()}", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // 2. DANH SÁCH MÓN ĂN
            const Text("Danh sách món", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: o.items.length,
              separatorBuilder: (_,__) => const Divider(),
              itemBuilder: (context, index) {
                final item = o.items[index];
                // item là Map<String, dynamic>
                return Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        item['image'] ?? '',
                        width: 50, height: 50, fit: BoxFit.cover,
                        errorBuilder: (_,__,___)=> const Icon(Icons.fastfood, color: Colors.grey),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(item['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
                          Text("SL: ${item['quantity']} x ${item['price']}đ"),
                        ],
                      ),
                    ),
                    Text("${(item['quantity'] * item['price'])}đ", style: const TextStyle(fontWeight: FontWeight.bold)),
                  ],
                );
              },
            ),

            const Divider(thickness: 1, height: 30),

            // 3. TỔNG TIỀN
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("TỔNG THANH TOÁN", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                Text("${o.totalPrice}đ", style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.red)),
              ],
            ),

            const SizedBox(height: 40),

            // 4. QUY TRÌNH DUYỆT ĐƠN (Workflow)
            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else
              Column(
                children: [
                  // PENDING -> PREPARING
                  if (o.status == 'pending')
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.check),
                        label: const Text("XÁC NHẬN ĐƠN (-> Nhà bếp)"),
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, foregroundColor: Colors.white),
                        onPressed: () => _updateStatus('preparing'),
                      ),
                    ),

                  // PREPARING -> SHIPPING
                  if (o.status == 'preparing')
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.delivery_dining),
                        label: const Text("GIAO CHO SHIPPER (-> Đang giao)"),
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.orange, foregroundColor: Colors.white),
                        onPressed: () => _updateStatus('shipping'),
                      ),
                    ),

                  // SHIPPING -> COMPLETED
                  if (o.status == 'shipping')
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.done_all),
                        label: const Text("ĐÃ GIAO THÀNH CÔNG (-> Hoàn tất)"),
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
                        onPressed: () => _updateStatus('completed'),
                      ),
                    ),

                  // NÚT HỦY ĐƠN (Luôn hiện trừ khi đã xong/hủy)
                  if (o.status != 'completed' && o.status != 'cancelled')
                    Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: TextButton.icon(
                        icon: const Icon(Icons.cancel, color: Colors.red),
                        label: const Text("Hủy đơn hàng này", style: TextStyle(color: Colors.red)),
                        onPressed: () {
                          // Thêm xác nhận trước khi hủy
                          showDialog(
                              context: context,
                              builder: (c) => AlertDialog(
                                title: const Text("Xác nhận hủy"),
                                content: const Text("Bạn có chắc muốn hủy đơn này không?"),
                                actions: [
                                  TextButton(onPressed: () => Navigator.pop(c), child: const Text("Không")),
                                  TextButton(onPressed: () {
                                    Navigator.pop(c);
                                    _updateStatus('cancelled');
                                  }, child: const Text("Hủy ngay", style: TextStyle(color: Colors.red))),
                                ],
                              )
                          );
                        },
                      ),
                    )
                ],
              )
          ],
        ),
      ),
    );
  }
}