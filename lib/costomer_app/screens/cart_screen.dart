import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/cart_provider.dart';
import 'checkout_screen.dart'; // Import màn hình thanh toán

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);

    // Kiểm tra chế độ tối
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDarkMode ? const Color(0xFF1E1E1E) : Colors.white;
    final textColor = isDarkMode ? Colors.white : Colors.black;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Giỏ hàng của bạn'),
        elevation: 0,
      ),
      body: Column(
        children: [
          // DANH SÁCH MÓN
          Expanded(
            child: cart.items.isEmpty
                ? Center(child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.shopping_cart_outlined, size: 80, color: Colors.grey.shade400),
                const SizedBox(height: 10),
                Text("Giỏ hàng đang trống!", style: TextStyle(color: textColor)),
              ],
            ))
                : ListView.builder(
              padding: const EdgeInsets.all(10),
              itemCount: cart.items.length,
              itemBuilder: (ctx, i) {
                final item = cart.items.values.toList()[i];
                final productId = cart.items.keys.toList()[i];

                // --- LOGIC KIỂM TRA TỒN KHO ---
                // Nếu số lượng trong giỏ >= tồn kho thực tế -> Đạt giới hạn
                final isMaxStock = item.quantity >= item.stock;

                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  color: isDarkMode ? const Color(0xFF2C2C2C) : Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: ListTile(
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.network(item.imageUrl, width: 60, height: 60, fit: BoxFit.cover, errorBuilder: (c,e,s)=>const Icon(Icons.fastfood)),
                      ),
                      title: Text(item.title, style: TextStyle(fontWeight: FontWeight.bold, color: textColor)),
                      subtitle: Text('Tổng: ${(item.price * item.quantity).toStringAsFixed(0)}đ', style: const TextStyle(color: Colors.grey)),
                      trailing: SizedBox(
                        width: 120,
                        child: Row(
                          children: [
                            // NÚT TRỪ (-)
                            IconButton(
                              icon: Icon(Icons.remove_circle_outline, color: isDarkMode ? Colors.white70 : Colors.black54),
                              onPressed: () => cart.removeSingleItem(productId),
                            ),

                            Text('${item.quantity}', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: textColor)),

                            // NÚT CỘNG (+) - ĐÃ FIX
                            IconButton(
                              icon: Icon(Icons.add_circle_outline, color: isMaxStock ? Colors.grey : Colors.orange),
                              onPressed: () {
                                if (isMaxStock) {
                                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                                    content: Text("Đã đạt giới hạn số lượng trong kho!"),
                                    duration: Duration(seconds: 1),
                                  ));
                                } else {
                                  // Truyền item.stock vào để Provider lưu trữ
                                  cart.addItem(productId, item.price, item.title, item.imageUrl, item.stock);
                                }
                              },
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

          // THANH THANH TOÁN
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: backgroundColor,
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
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const CheckoutScreen()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  ),
                  child: const Text('TIẾP TỤC', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}