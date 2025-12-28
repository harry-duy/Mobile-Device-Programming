import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/product_model.dart';
import '../../services/product_service.dart';
import 'add_edit_product_screen.dart';
import 'tabs/admin_order_list_tab.dart';
import 'tabs/admin_dashboard_tab.dart';
import 'voucher_screen.dart'; // <--- Import màn hình Voucher (Nhớ tạo file này theo hướng dẫn trước)

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({super.key});

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
            _selectedIndex == 0 ? 'Tổng quan'
                : _selectedIndex == 1 ? 'Quản lý Menu'
                : 'Quản lý Đơn hàng'
        ),
        backgroundColor: Colors.blueGrey,
        elevation: 0,
        actions: [
          // --- THÊM NÚT QUẢN LÝ VOUCHER TẠI ĐÂY ---
          IconButton(
            icon: const Icon(Icons.confirmation_number), // Icon hình cái vé
            tooltip: 'Quản lý mã giảm giá',
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const VoucherScreen()));
            },
          ),
          // -----------------------------------------

          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Đăng xuất',
            onPressed: () => context.read<AuthProvider>().signOut(),
          )
        ],
      ),

      body: IndexedStack(
        index: _selectedIndex,
        children: const [
          AdminDashboardTab(),
          _AdminProductListTab(),
          AdminOrderListTab(),
        ],
      ),

      floatingActionButton: _selectedIndex == 1
          ? FloatingActionButton(
        backgroundColor: Colors.blueGrey,
        child: const Icon(Icons.add),
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AddEditProductScreen())),
      )
          : null,

      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Tổng quan'),
          BottomNavigationBarItem(icon: Icon(Icons.restaurant_menu), label: 'Thực đơn'),
          BottomNavigationBarItem(icon: Icon(Icons.receipt_long), label: 'Đơn hàng'),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blueGrey,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}

// --- WIDGET CON: TAB DANH SÁCH SẢN PHẨM (Giữ nguyên) ---
class _AdminProductListTab extends StatelessWidget {
  const _AdminProductListTab();

  @override
  Widget build(BuildContext context) {
    final productService = ProductService();

    return StreamBuilder<List<ProductModel>>(
      stream: productService.getProducts(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
        if (!snapshot.hasData || snapshot.data!.isEmpty) return const Center(child: Text('Chưa có món nào'));

        final products = snapshot.data!;
        return ListView.separated(
          padding: const EdgeInsets.all(10),
          itemCount: products.length,
          separatorBuilder: (_,__) => const Divider(),
          itemBuilder: (context, index) {
            final product = products[index];
            return Card(
              elevation: 2,
              child: ListTile(
                leading: Image.network(product.imageUrl, width: 50, height: 50, fit: BoxFit.cover, errorBuilder: (_,__,___) => const Icon(Icons.error)),
                title: Text(product.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text('${product.price}đ - ${product.category}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(icon: const Icon(Icons.edit, color: Colors.blue), onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => AddEditProductScreen(product: product)))),
                    IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => productService.deleteProduct(product.id)),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}