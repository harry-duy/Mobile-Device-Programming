import 'package:flutter/material.dart';
import '../../../services/address_service.dart'; // <--- Import đúng
import 'add_edit_address_screen.dart';

class AddressListScreen extends StatelessWidget {
  const AddressListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AddressService addressService = AddressService();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sổ địa chỉ'),
        backgroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Colors.orange),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AddEditAddressScreen()),
            ),
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
                  const Text('Chưa có địa chỉ nào'),
                  TextButton(
                    onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AddEditAddressScreen())),
                    child: const Text('Thêm ngay', style: TextStyle(color: Colors.orange)),
                  )
                ],
              ),
            );
          }

          final addresses = snapshot.data!;
          return ListView.separated(
            padding: const EdgeInsets.all(10),
            itemCount: addresses.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final addr = addresses[index];
              return Card(
                elevation: addr.isDefault ? 2 : 0,
                shape: RoundedRectangleBorder(
                  side: addr.isDefault ? const BorderSide(color: Colors.orange) : BorderSide.none,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ListTile(
                  title: Row(
                    children: [
                      Text(addr.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                      if (addr.isDefault)
                        Container(
                          margin: const EdgeInsets.only(left: 10),
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(color: Colors.orange.shade100, borderRadius: BorderRadius.circular(4)),
                          child: const Text('Mặc định', style: TextStyle(fontSize: 10, color: Colors.orange)),
                        )
                    ],
                  ),
                  subtitle: Text("${addr.phone}\n${addr.detail}"),
                  isThreeLine: true,
                  trailing: PopupMenuButton(
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
                      if (!addr.isDefault)
                        const PopupMenuItem(value: 'default', child: Text('Đặt làm mặc định')),
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