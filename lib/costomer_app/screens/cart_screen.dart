import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/cart_provider.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);

    // Kiểm tra chế độ tối
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDarkMode ? const Color(0xFF1E1E1E) : Colors.white; // Màu nền thanh toán
    final textColor = isDarkMode ? Colors.white : Colors.black;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Giỏ hàng của bạn'),
        // Bỏ màu cứng, để tự động theo theme
        elevation: 0,
      ),
      body: Column(
        children: [
          // DANH SÁCH MÓN
          Expanded(
            child: cart.items.isEmpty
                ? Center(child: Text("Giỏ hàng đang trống!", style: TextStyle(color: textColor)))
                : ListView.builder(
              itemCount: cart.items.length,
              itemBuilder: (ctx, i) {
                final item = cart.items.values.toList()[i];
                final productId = cart.items.keys.toList()[i];
                return Card(
                  // Tự động chỉnh màu Card theo Theme
                  margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: ListTile(
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.network(item.imageUrl, width: 60, height: 60, fit: BoxFit.cover, errorBuilder: (c,e,s)=>const Icon(Icons.fastfood)),
                      ),
                      title: Text(item.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text('Tổng: ${(item.price * item.quantity).toStringAsFixed(0)}đ', style: const TextStyle(color: Colors.grey)),
                      trailing: SizedBox(
                        width: 120,
                        child: Row(
                          children: [
                            IconButton(
                              icon: Icon(Icons.remove_circle_outline, color: isDarkMode ? Colors.white70 : Colors.black54),
                              onPressed: () => cart.removeSingleItem(productId),
                            ),
                            Text('${item.quantity}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                            IconButton(
                              icon: const Icon(Icons.add_circle_outline, color: Colors.orange),
                              onPressed: () => cart.addItem(productId, item.price, item.title, item.imageUrl),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // THANH THANH TOÁN (Đã sửa lỗi màu trắng)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: backgroundColor, // <--- Tự động đổi màu Đen/Trắng
              boxShadow: [
                BoxShadow(
                    color: isDarkMode ? Colors.black26 : Colors.black12,
                    blurRadius: 10,
                    offset: const Offset(0, -5)
                )
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Tổng cộng', style: TextStyle(color: isDarkMode ? Colors.grey.shade400 : Colors.grey)),
                    Text(
                        '${cart.totalAmount.toStringAsFixed(0)}đ',
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.orange)
                    ),
                  ],
                ),
                ElevatedButton(
                  onPressed: cart.totalAmount <= 0 ? null : () {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Chức năng đặt hàng đang phát triển!")));
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  ),
                  child: const Text('ĐẶT HÀNG', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}