import 'package:flutter/material.dart';
import 'product_list_screen.dart';
import 'order_list_screen.dart';
import 'cart_screen.dart';
import 'profile_screen.dart';


class CustomerHomeScreen extends StatefulWidget {
  const CustomerHomeScreen({super.key});

  @override
  State<CustomerHomeScreen> createState() => _CustomerHomeScreenState();
}

class _CustomerHomeScreenState extends State<CustomerHomeScreen> {
  int _selectedIndex = 0;

  // Danh sách các tab màn hình
  final List<Widget> _pages = [
    const ProductListScreen(),
    const OrderListScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Food Delivery'),
        backgroundColor: Colors.orange,
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart),
            onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CartScreen())
            ),
          )
        ],
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        selectedItemColor: Colors.orange,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.menu_book), label: 'Thực đơn'),
          BottomNavigationBarItem(icon: Icon(Icons.list_alt), label: 'Đơn hàng'),
        ],
      ),
    );
  }
}