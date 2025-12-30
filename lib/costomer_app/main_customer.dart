import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// --- IMPORT CÁC MÀN HÌNH CON ---
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

  // Danh sách màn hình tương ứng với Menu
  final List<Widget> _screens = [
    const ProductListScreen(),
    const CartScreen(),
    const OrderListScreen(),
    const ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    // Kích hoạt lắng nghe thông báo ngay khi vào màn hình chính
    _setupNotifications();
  }

  // --- HÀM LẮNG NGHE THÔNG BÁO REALTIME ---
  void _setupNotifications() {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    // Lắng nghe collection 'notifications'
    FirebaseFirestore.instance
        .collection('notifications')
        .where('userId', isEqualTo: uid)
        .where('isRead', isEqualTo: false) // Chỉ bắt những tin chưa đọc
        .snapshots()
        .listen((snapshot) {
      // Duyệt qua các thay đổi (tin mới đến)
      for (var change in snapshot.docChanges) {
        if (change.type == DocumentChangeType.added) {
          final data = change.doc.data() as Map<String, dynamic>;
          // Hiển thị Popup
          if (mounted) {
            _showNotificationPopup(
                data['title'] ?? 'Thông báo',
                data['body'] ?? '',
                change.doc.id
            );
          }
        }
      }
    });
  }

  void _showNotificationPopup(String title, String body, String docId) {
    // 1. Đánh dấu là đã đọc ngay lập tức để không hiện lại lần sau
    FirebaseFirestore.instance.collection('notifications').doc(docId).update({'isRead': true});

    // 2. Hiện Dialog
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: Row(
          children: [
            const Icon(Icons.notifications_active, color: Colors.orange),
            const SizedBox(width: 10),
            Expanded(child: Text(title, style: const TextStyle(fontSize: 18))),
          ],
        ),
        content: Text(body, style: const TextStyle(fontSize: 16)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Đóng", style: TextStyle(color: Colors.blue)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              // Chuyển sang Tab Đơn hàng (Index 2) để xem chi tiết
              setState(() => _selectedIndex = 2);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            child: const Text("Xem đơn hàng", style: TextStyle(color: Colors.white)),
          )
        ],
      ),
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Hiển thị màn hình theo Tab đang chọn
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed, // Cố định 4 nút
        selectedItemColor: Colors.orange,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.restaurant_menu),
            label: 'Thực đơn',
          ),

          // --- TAB GIỎ HÀNG (CÓ CHẤM ĐỎ SỐ LƯỢNG) ---
          BottomNavigationBarItem(
            icon: Consumer<CartProvider>(
              builder: (_, cart, ch) => Badge(
                label: Text(cart.itemCount.toString()), // Số lượng món
                isLabelVisible: cart.itemCount > 0,     // Ẩn nếu = 0
                backgroundColor: Colors.red,
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