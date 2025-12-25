import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Lấy thông tin user từ AuthProvider
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.userProfile;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const SizedBox(height: 20),
              // Avatar
              const CircleAvatar(
                radius: 50,
                backgroundColor: Colors.orange,
                child: Icon(Icons.person, size: 50, color: Colors.white),
              ),
              const SizedBox(height: 16),

              // Tên và Email
              Text(
                user?.name ?? 'Người dùng',
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              Text(
                user?.email ?? '',
                style: const TextStyle(color: Colors.grey),
              ),

              const SizedBox(height: 40),

              // Các mục menu (Ví dụ)
              _buildMenuItem(Icons.history, 'Lịch sử đơn hàng', () {}),
              _buildMenuItem(Icons.location_on, 'Địa chỉ giao hàng', () {}),
              _buildMenuItem(Icons.settings, 'Cài đặt', () {}),

              const SizedBox(height: 20),

              // Nút Đăng Xuất
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade50, // Màu nền nhạt
                    foregroundColor: Colors.red,       // Màu chữ đỏ
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    elevation: 0,
                  ),
                  icon: const Icon(Icons.logout),
                  label: const Text('Đăng xuất', style: TextStyle(fontSize: 16)),
                  onPressed: () {
                    // Gọi hàm đăng xuất
                    context.read<AuthProvider>().signOut();
                    // AuthWrapper ở main.dart sẽ tự động chuyển về LoginScreen
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuItem(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: Colors.orange),
      title: Text(title),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
      onTap: onTap,
    );
  }
}