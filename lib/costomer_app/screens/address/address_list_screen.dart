import 'package:flutter/material.dart';
import '../../../models/address_model.dart'; // Import Model
import '../../../services/address_service.dart'; // Import Service
import 'add_edit_address_screen.dart'; // Import màn hình Thêm/Sửa

class AddressListScreen extends StatelessWidget {
  const AddressListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final addressService = AddressService();
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDarkMode ? const Color(0xFF1E1E1E) : Colors.white;
    final textColor = isDarkMode ? Colors.white : Colors.black;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sổ địa chỉ'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AddEditAddressScreen()),
              );
            },
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
                  Icon(Icons.location_off, size: 80, color: Colors.grey.shade400),
                  const SizedBox(height: 10),
                  Text("Chưa có địa chỉ nào", style: TextStyle(color: textColor)),
                ],
              ),
            );
          }

          final addresses = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: addresses.length,
            itemBuilder: (context, index) {
              final address = addresses[index];

              return Card(
                color: cardColor,
                margin: const EdgeInsets.only(bottom: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                  side: address.isDefault
                      ? const BorderSide(color: Colors.orange, width: 2)
                      : BorderSide.none,
                ),
                child: InkWell(
                  onTap: () {
                    // Khi bấm vào thì quay lại màn hình trước (dùng cho Checkout chọn địa chỉ)
                    Navigator.pop(context, address);
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              address.name,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: textColor,
                              ),
                            ),
                            if (address.isDefault)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.orange.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                child: const Text(
                                  "Mặc định",
                                  style: TextStyle(color: Colors.orange, fontSize: 12, fontWeight: FontWeight.bold),
                                ),
                              )
                          ],
                        ),
                        const SizedBox(height: 5),
                        Text(address.phone, style: TextStyle(color: textColor)),
                        const SizedBox(height: 5),
                        Text(
                          address.detail,
                          style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                        ),
                        const Divider(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            // NÚT ĐẶT MẶC ĐỊNH
                            if (!address.isDefault)
                              TextButton(
                                onPressed: () {
                                  // --- ĐÂY LÀ CHỖ ĐÃ SỬA LỖI ---
                                  // Truyền address.id (String) thay vì address (Object)
                                  addressService.setDefaultAddress(address.id);
                                },
                                child: const Text("Đặt làm mặc định", style: TextStyle(color: Colors.blue)),
                              ),

                            // NÚT SỬA
                            TextButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => AddEditAddressScreen(address: address),
                                  ),
                                );
                              },
                              child: const Text("Sửa", style: TextStyle(color: Colors.orange)),
                            ),

                            // NÚT XÓA
                            TextButton(
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (ctx) => AlertDialog(
                                    title: const Text("Xóa địa chỉ?"),
                                    content: const Text("Bạn có chắc muốn xóa địa chỉ này không?"),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(ctx),
                                        child: const Text("Hủy"),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          addressService.deleteAddress(address.id);
                                          Navigator.pop(ctx);
                                        },
                                        child: const Text("Xóa", style: TextStyle(color: Colors.red)),
                                      ),
                                    ],
                                  ),
                                );
                              },
                              child: const Text("Xóa", style: TextStyle(color: Colors.red)),
                            ),
                          ],
                        )
                      ],
                    ),
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