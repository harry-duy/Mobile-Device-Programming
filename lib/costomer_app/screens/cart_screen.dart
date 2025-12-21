import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/firebase_service.dart';
import '../../models/models.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final FirebaseService _firebaseService = FirebaseService();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  // Giả sử đây là danh sách sản phẩm tạm thời trong giỏ hàng
  // Trong thực tế, bạn nên dùng Provider để quản lý danh sách này
  final List<Map<String, dynamic>> _cartItems = [
    {
      "id": "p1",
      "name": "Phở bò",
      "price": 45000.0,
      "quantity": 2,
    },
    {
      "id": "p2",
      "name": "Bún chả",
      "price": 40000.0,
      "quantity": 1,
    }
  ];

  double get _totalAmount {
    return _cartItems.fold(0, (sum, item) => sum + (item['price'] * item['quantity']));
  }

  void _handleCheckout() async {
    if (_addressController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Vui lòng nhập địa chỉ giao hàng")),
      );
      return;
    }

    try {
      // Fix lỗi: Sử dụng Named Parameters để khớp với FirebaseService
      await _firebaseService.placeOrder(
        address: _addressController.text,
        items: _cartItems,
        total: _totalAmount,
        notes: _notesController.text,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Đặt hàng thành công!")),
      );

      // Xóa giỏ hàng và quay về trang chủ
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Lỗi đặt hàng: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Giỏ hàng"),
        backgroundColor: Colors.orange,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _cartItems.length,
              itemBuilder: (context, index) {
                final item = _cartItems[index];
                return ListTile(
                  leading: const CircleAvatar(child: Icon(Icons.fastfood)),
                  title: Text(item['name']),
                  subtitle: Text("${item['quantity']} x ${item['price']} VNĐ"),
                  trailing: Text("${item['quantity'] * item['price']} VNĐ"),
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  spreadRadius: 1,
                  blurRadius: 5,
                ),
              ],
            ),
            child: Column(
              children: [
                TextField(
                  controller: _addressController,
                  decoration: const InputDecoration(
                    labelText: "Địa chỉ giao hàng *",
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.location_on),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _notesController,
                  decoration: const InputDecoration(
                    labelText: "Ghi chú (tùy chọn)",
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.note),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Tổng thanh toán:",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      "$_totalAmount VNĐ",
                      style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.orange
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _handleCheckout,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text("XÁC NHẬN ĐẶT HÀNG"),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _addressController.dispose();
    _notesController.dispose();
    super.dispose();
  }
}