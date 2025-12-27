import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/theme_provider.dart'; // Import ThemeProvider
import 'edit_profile_screen.dart';
import 'order_list_screen.dart';
import 'address/address_list_screen.dart'; // Import màn hình Sổ địa chỉ

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // 1. Lắng nghe dữ liệu User
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.userProfile;

    // 2. Lắng nghe dữ liệu Theme (Dark Mode)
    final themeProvider = context.watch<ThemeProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Hồ sơ cá nhân'),
        centerTitle: true,
        // Không set background cứng để nó tự ăn theo Theme Sáng/Tối
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.orange),
            tooltip: 'Chỉnh sửa thông tin',
            onPressed: () {
              if (user != null) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EditProfileScreen(
                      currentName: user.name,
                      currentPhone: user.phone,
                      currentAddress: user.address,
                    ),
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Đang tải dữ liệu...')),
                );
              }
            },
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // --- PHẦN 1: AVATAR & TÊN ---
            const Center(
              child: CircleAvatar(
                radius: 50,
                backgroundColor: Colors.orange,
                child: Icon(Icons.person, size: 60, color: Colors.white),
              ),
            ),
            const SizedBox(height: 16),

            // Hiển thị tên (Dùng fallback ?? để không bị crash nếu null)
            Text(
              user?.name ?? 'Đang tải tên...',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            Text(
              user?.email ?? '',
              style: const TextStyle(color: Colors.grey, fontSize: 14),
            ),

            const SizedBox(height: 30),

            // --- PHẦN 2: THÔNG TIN CÁ NHÂN ---
            _buildInfoTile(
                context,
                icon: Icons.phone,
                title: 'Số điện thoại',
                value: user?.phone ?? '...'
            ),

            // Dòng địa chỉ: Bấm vào để mở Sổ Địa Chỉ
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AddressListScreen()),
                );
              },
              child: _buildInfoTile(
                context,
                icon: Icons.location_on,
                title: 'Địa chỉ mặc định',
                value: (user?.address != null && user!.address.isNotEmpty)
                    ? user.address
                    : 'Bấm để thêm địa chỉ',
                showArrow: true, // Hiện mũi tên để biết là bấm được
              ),
            ),

            const Divider(height: 40),

            // --- PHẦN 3: CÀI ĐẶT ỨNG DỤNG ---

            // Nút bật tắt Dark Mode
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text("Chế độ tối", style: TextStyle(fontWeight: FontWeight.w500)),
              secondary: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey.withAlpha(30), // Fix lỗi withOpacity
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  themeProvider.isDarkMode ? Icons.dark_mode : Icons.light_mode,
                  color: Colors.orange,
                  size: 20,
                ),
              ),
              value: themeProvider.isDarkMode,
              activeColor: Colors.orange,
              onChanged: (value) {
                // Gọi hàm toggle trong ThemeProvider
                context.read<ThemeProvider>().toggleTheme(value);
              },
            ),

            // Menu Lịch sử đơn hàng
            _buildMenuButton(
              context,
              icon: Icons.history,
              title: 'Lịch sử đơn hàng',
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const OrderListScreen())
                );
              },
            ),

            // Menu Hỗ trợ (Placeholder)
            _buildMenuButton(
              context,
              icon: Icons.support_agent,
              title: 'Hỗ trợ & Trợ giúp',
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Tính năng đang phát triển")));
              },
            ),

            const SizedBox(height: 40),

            // --- PHẦN 4: NÚT ĐĂNG XUẤT ---
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade50,
                  foregroundColor: Colors.red,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                icon: const Icon(Icons.logout),
                label: const Text('Đăng xuất', style: TextStyle(fontWeight: FontWeight.bold)),
                onPressed: () {
                  _showLogoutDialog(context);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget hiển thị thông tin (Phone, Address)
  Widget _buildInfoTile(BuildContext context, {required IconData icon, required String title, required String value, bool showArrow = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.orange.withAlpha(30), // Màu nền nhẹ
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: Colors.orange, size: 22),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(color: Theme.of(context).hintColor, fontSize: 12)),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          if (showArrow)
            Icon(Icons.arrow_forward_ios, size: 14, color: Theme.of(context).hintColor)
        ],
      ),
    );
  }

  // Widget hiển thị menu điều hướng
  Widget _buildMenuButton(BuildContext context, {required IconData icon, required String title, required VoidCallback onTap}) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.grey.withAlpha(30),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Theme.of(context).iconTheme.color, size: 20),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
      onTap: onTap,
    );
  }

  // Dialog xác nhận đăng xuất
  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Đăng xuất'),
        content: const Text('Bạn có chắc chắn muốn đăng xuất?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<AuthProvider>().signOut();
            },
            child: const Text('Đăng xuất', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}