import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';
import 'screens/product_list_screen.dart';
import 'screens/cart_screen.dart';
import 'screens/order_list_screen.dart';
import 'screens/profile_screen.dart';

class MainCustomerScreen extends StatefulWidget {
  const MainCustomerScreen({super.key});

  @override
  State<MainCustomerScreen> createState() => _MainCustomerScreenState();
}

class _MainCustomerScreenState extends State<MainCustomerScreen> {
  int _selectedIndex = 0;

  // Danh sách các màn hình tương ứng với các tab
  final List<Widget> _screens = [
    const ProductListScreen(),
    const CartScreen(),
    const OrderListScreen(),
    const ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex], // Hiển thị màn hình theo tab đã chọn
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed, // Cố định để hiện đủ 4 nút
        selectedItemColor: Colors.orange,
        unselectedItemColor: Colors.grey,
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.restaurant_menu),
            label: 'Thực đơn',
          ),

          // TAB GIỎ HÀNG (Có chấm đỏ số lượng)
          BottomNavigationBarItem(
            icon: Consumer<CartProvider>( // Dùng Consumer để lắng nghe thay đổi số lượng
              builder: (_, cart, ch) => Badge(
                label: Text(cart.itemCount.toString()), // Số lượng
                isLabelVisible: cart.itemCount > 0, // Chỉ hiện khi > 0
                child: const Icon(Icons.shopping_cart),
              ),
            ),
            label: 'Giỏ hàng',
          ),

          const BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long),
            label: 'Đơn hàng',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Cá nhân',
          ),
        ],
      ),
    );
  }
}