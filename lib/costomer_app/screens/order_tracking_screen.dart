import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/order_model.dart';

class OrderTrackingScreen extends StatefulWidget {
  final OrderModel order; // Nhận dữ liệu đơn hàng từ màn hình danh sách

  const OrderTrackingScreen({super.key, required this.order});

  @override
  State<OrderTrackingScreen> createState() => _OrderTrackingScreenState();
}

class _OrderTrackingScreenState extends State<OrderTrackingScreen> {
  // Biến dùng cho việc đánh giá
  final TextEditingController _reviewController = TextEditingController();
  int _rating = 5; // Mặc định 5 sao

  // Hàm gửi đánh giá lên Firebase
  Future<void> _submitReview() async {
    if (_reviewController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Vui lòng viết nhận xét!')));
      return;
    }

    try {
      await FirebaseFirestore.instance.collection('reviews').add({
        'orderId': widget.order.id,
        'userId': widget.order.userId,
        'rating': _rating,
        'comment': _reviewController.text,
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        Navigator.pop(context); // Đóng dialog
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Cảm ơn bạn đã đánh giá!')));
      }
    } catch (e) {
      print(e);
    }
  }

  // Hộp thoại đánh giá (Rating Dialog)
  void _showRatingDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder( // Dùng StatefulBuilder để update màu sao ngay trong Dialog
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Đánh giá món ăn'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Bạn cảm thấy món ăn thế nào?'),
                  const SizedBox(height: 10),
                  // Vẽ 5 ngôi sao
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      return IconButton(
                        icon: Icon(
                          index < _rating ? Icons.star : Icons.star_border,
                          color: Colors.orange,
                          size: 32,
                        ),
                        onPressed: () {
                          setDialogState(() => _rating = index + 1);
                        },
                      );
                    }),
                  ),
                  TextField(
                    controller: _reviewController,
                    decoration: const InputDecoration(
                      hintText: 'Viết nhận xét của bạn...',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Bỏ qua', style: TextStyle(color: Colors.grey)),
                ),
                ElevatedButton(
                  onPressed: _submitReview,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                  child: const Text('Gửi đánh giá', style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // StreamBuilder để lắng nghe thay đổi trạng thái đơn hàng Realtime
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.collection('orders').doc(widget.order.id).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Scaffold(body: Center(child: CircularProgressIndicator()));

        // Cập nhật dữ liệu mới nhất
        final currentOrder = OrderModel.fromFirestore(snapshot.data!);
        final currentStep = currentOrder.statusStep;

        return Scaffold(
          appBar: AppBar(
            title: Text('Đơn hàng #${currentOrder.id.substring(0, 4).toUpperCase()}'),
            backgroundColor: Colors.white,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. PHẦN TRACKING UI
                const Text('Trạng thái đơn hàng', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 20),
                _buildTimelineTile('Đơn hàng đã đặt', 'Chúng tôi đã nhận được đơn của bạn', 0, currentStep),
                _buildTimelineTile('Nhà bếp đang làm', 'Món ăn đang được chế biến', 1, currentStep),
                _buildTimelineTile('Đang giao hàng', 'Tài xế đang trên đường đến', 2, currentStep),
                _buildTimelineTile('Hoàn thành', 'Giao hàng thành công', 3, currentStep, isLast: true),

                const Divider(height: 40),

                // 2. DANH SÁCH MÓN ĂN
                const Text('Chi tiết món ăn', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ...currentOrder.items.map((item) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Image.network(item['image'] ?? '', width: 50, height: 50, fit: BoxFit.cover,
                      errorBuilder: (_,__,___) => const Icon(Icons.fastfood)), // Fallback icon
                  title: Text(item['name']),
                  subtitle: Text('x${item['quantity']}'),
                  trailing: Text('${item['price']}đ'),
                )),

                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Tổng cộng:', style: TextStyle(fontWeight: FontWeight.bold)),
                    Text('${currentOrder.totalPrice}đ', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.orange)),
                  ],
                ),

                const SizedBox(height: 30),

                // 3. NÚT ĐÁNH GIÁ (Chỉ hiện khi đã Hoàn thành)
                if (currentOrder.status == 'completed')
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _showRatingDialog,
                      icon: const Icon(Icons.star),
                      label: const Text('Đánh giá & Nhận xét'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                      ),
                    ),
                  ),

                // Nút "Giả lập" cho bạn test (Xóa khi deploy thật)
                if (currentOrder.status != 'completed')
                  Center(
                    child: TextButton(
                      onPressed: () {
                        // Hack nhẹ để test chuyển trạng thái
                        FirebaseFirestore.instance.collection('orders').doc(currentOrder.id).update({
                          'status': 'completed'
                        });
                      },
                      child: const Text('(Test) Bấm để hoàn thành đơn', style: TextStyle(color: Colors.grey)),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Widget vẽ từng bước trong Timeline
  Widget _buildTimelineTile(String title, String subtitle, int stepIndex, int currentStep, {bool isLast = false}) {
    bool isActive = stepIndex <= currentStep;
    bool isCompleted = stepIndex < currentStep;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Cột Icon và Line
        Column(
          children: [
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: isActive ? Colors.orange : Colors.grey.shade300,
                shape: BoxShape.circle,
              ),
              child: Icon(
                isCompleted ? Icons.check : (isActive ? Icons.access_time_filled : Icons.radio_button_unchecked),
                color: Colors.white,
                size: 16,
              ),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 50,
                color: isCompleted ? Colors.orange : Colors.grey.shade300,
              ),
          ],
        ),
        const SizedBox(width: 15),
        // Cột nội dung text
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: isActive ? Colors.black : Colors.grey,
              )),
              Text(subtitle, style: const TextStyle(color: Colors.grey, fontSize: 12)),
              const SizedBox(height: 40), // Khoảng cách giữa các bước
            ],
          ),
        )
      ],
    );
  }
}