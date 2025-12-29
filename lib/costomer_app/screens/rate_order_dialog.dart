import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/product_model.dart'; // Để lấy thông tin món

class RateOrderDialog extends StatefulWidget {
  final String orderId;
  final List<dynamic> items; // Danh sách món trong đơn

  const RateOrderDialog({super.key, required this.orderId, required this.items});

  @override
  State<RateOrderDialog> createState() => _RateOrderDialogState();
}

class _RateOrderDialogState extends State<RateOrderDialog> {
  // Lưu đánh giá cho từng món: Map<ProductId, Rating>
  final Map<String, double> _ratings = {};
  final Map<String, String> _comments = {};
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    // Mặc định 5 sao cho tất cả
    for (var item in widget.items) {
      _ratings[item['id']] = 5.0;
      _comments[item['id']] = '';
    }
  }

  Future<void> _submitReviews() async {
    setState(() => _isSubmitting = true);
    final uid = FirebaseAuth.instance.currentUser!.uid;
    // Lấy tên user (Giả sử lấy từ Auth hoặc query user profile, ở đây tạm lấy email hoặc tên)
    final userDoc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
    final userName = userDoc.data()?['fullName'] ?? 'Khách hàng';

    final batch = FirebaseFirestore.instance.batch();

    // 1. Tạo review cho từng món
    for (var item in widget.items) {
      final productId = item['id'];
      final docRef = FirebaseFirestore.instance.collection('reviews').doc();
      batch.set(docRef, {
        'productId': productId,
        'userId': uid,
        'userName': userName,
        'rating': _ratings[productId],
        'comment': _comments[productId],
        'date': FieldValue.serverTimestamp(),
      });
    }

    // 2. Đánh dấu đơn hàng là đã đánh giá (isRated = true)
    final orderRef = FirebaseFirestore.instance.collection('orders').doc(widget.orderId);
    batch.update(orderRef, {'isRated': true});

    await batch.commit();

    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Cảm ơn bạn đã đánh giá!")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Đánh giá món ăn")),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: widget.items.length,
        itemBuilder: (context, index) {
          final item = widget.items[index];
          final productId = item['id'];

          return Card(
            margin: const EdgeInsets.only(bottom: 20),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                children: [
                  Row(
                    children: [
                      Image.network(item['image'], width: 50, height: 50, fit: BoxFit.cover),
                      const SizedBox(width: 10),
                      Text(item['name'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    ],
                  ),
                  const Divider(),
                  const Text("Bạn thấy món này thế nào?"),
                  // Star Rating Widget tự chế
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (i) {
                      return IconButton(
                        icon: Icon(
                          i < (_ratings[productId] ?? 0) ? Icons.star : Icons.star_border,
                          color: Colors.amber,
                          size: 32,
                        ),
                        onPressed: () {
                          setState(() => _ratings[productId] = i + 1.0);
                        },
                      );
                    }),
                  ),
                  TextField(
                    decoration: const InputDecoration(
                      hintText: 'Viết nhận xét (Ngon, vừa miệng...)',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (val) => _comments[productId] = val,
                  )
                ],
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton(
          onPressed: _isSubmitting ? null : _submitReviews,
          style: ElevatedButton.styleFrom(backgroundColor: Colors.orange, padding: const EdgeInsets.symmetric(vertical: 15)),
          child: _isSubmitting ? const CircularProgressIndicator(color: Colors.white) : const Text("GỬI ĐÁNH GIÁ", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }
}