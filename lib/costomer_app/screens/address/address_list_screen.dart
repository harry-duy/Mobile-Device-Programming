import 'package:flutter/material.dart';
import '../../../services/address_service.dart';
import 'add_edit_address_screen.dart';

class AddressListScreen extends StatelessWidget {
  const AddressListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AddressService addressService = AddressService();
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDarkMode ? const Color(0xFF1E1E1E) : Colors.white;
    final textColor = isDarkMode ? Colors.white : Colors.black;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sổ địa chỉ'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Colors.orange),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AddEditAddressScreen())),
          )
        ],
      ),
      body: StreamBuilder<List<AddressModel>>(
        stream: addressService.getUserAddresses(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.location_off_outlined, size: 80, color: Colors.grey.shade600),
                  const SizedBox(height: 16),
                  Text('Chưa có địa chỉ nào', style: TextStyle(color: textColor, fontSize: 16)),
                  const SizedBox(height: 10),
                  ElevatedButton.icon(
                    onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AddEditAddressScreen())),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.orange, foregroundColor: Colors.white),
                    icon: const Icon(Icons.add),
                    label: const Text('Thêm ngay'),
                  )
                ],
              ),
            );
          }

          final addresses = snapshot.data!;
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: addresses.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final addr = addresses[index];
              return Card(
                color: cardColor, // Màu nền thẻ động
                elevation: addr.isDefault ? 2 : 0,
                shape: RoundedRectangleBorder(
                  side: addr.isDefault ? const BorderSide(color: Colors.orange) : BorderSide.none,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  title: Row(
                    children: [
                      Text(addr.name, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: textColor)),
                      if (addr.isDefault)
                        Container(
                          margin: const EdgeInsets.only(left: 10),
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(color: Colors.orange.withOpacity(0.2), borderRadius: BorderRadius.circular(4)),
                          child: const Text('Mặc định', style: TextStyle(fontSize: 10, color: Colors.orange, fontWeight: FontWeight.bold)),
                        )
                    ],
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(addr.phone, style: TextStyle(color: textColor.withOpacity(0.7))),
                        const SizedBox(height: 4),
                        Text(addr.detail, style: TextStyle(color: textColor.withOpacity(0.7))),
                      ],
                    ),
                  ),
                  trailing: PopupMenuButton(
                    icon: Icon(Icons.more_vert, color: isDarkMode ? Colors.grey : Colors.black),
                    onSelected: (value) async {
                      if (value == 'edit') {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => AddEditAddressScreen(address: addr)));
                      } else if (value == 'delete') {
                        await addressService.deleteAddress(addr.id);
                      } else if (value == 'default') {
                        await addressService.setDefaultAddress(addr);
                      }
                    },
                    itemBuilder: (context) => [
                      if (!addr.isDefault) const PopupMenuItem(value: 'default', child: Text('Đặt làm mặc định')),
                      const PopupMenuItem(value: 'edit', child: Text('Chỉnh sửa')),
                      const PopupMenuItem(value: 'delete', child: Text('Xóa', style: TextStyle(color: Colors.red))),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}