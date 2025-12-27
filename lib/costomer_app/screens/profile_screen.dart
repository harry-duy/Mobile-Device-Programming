import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import 'edit_profile_screen.dart';
import 'order_list_screen.dart';
import 'address/address_list_screen.dart'; // <--- Import màn hình danh sách địa chỉ

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Lắng nghe dữ liệu user
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.userProfile;

    // Đã xóa biến isLoading không dùng tới để fix warning

    return Scaffold(
      appBar: AppBar(
        title: const Text('Hồ sơ cá nhân', style: TextStyle(color: Colors.black)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.orange),
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

            Text(
              user?.name ?? 'Đang tải...',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            Text(
              user?.email ?? '',
              style: const TextStyle(color: Colors.grey, fontSize: 14),
            ),

            const SizedBox(height: 30),

            // --- PHẦN 2: THÔNG TIN CHI TIẾT ---
            _buildInfoTile(
                Icons.phone,
                'Số điện thoại',
                user?.phone ?? '...'
            ),

            // Bấm vào đây để mở Sổ Địa Chỉ
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AddressListScreen()),
                );
              },
              child: _buildInfoTile(
                Icons.location_on,
                'Địa chỉ giao hàng',
                (user?.address != null && user!.address.isNotEmpty)
                    ? user.address
                    : 'Bấm để thêm địa chỉ',
              ),
            ),

            const Divider(height: 40),

            // --- PHẦN 3: MENU CHỨC NĂNG ---
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
            _buildMenuButton(
              context,
              icon: Icons.support_agent,
              title: 'Hỗ trợ',
              onTap: () {},
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
                ),
                icon: const Icon(Icons.logout),
                label: const Text('Đăng xuất'),
                onPressed: () {
                  context.read<AuthProvider>().signOut();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoTile(IconData icon, String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: Colors.orange, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                Text(
                  value,
                  style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          // Mũi tên nhỏ để biết là bấm được
          if(title == 'Địa chỉ giao hàng')
            const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey)
        ],
      ),
    );
  }

  Widget _buildMenuButton(BuildContext context, {required IconData icon, required String title, required VoidCallback onTap}) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.black87, size: 20),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
      onTap: onTap,
    );
  }
}