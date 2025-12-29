import 'package:flutter/material.dart';
import '../../../models/address_model.dart'; // <--- Import Model
import '../../../services/address_service.dart';

class AddEditAddressScreen extends StatefulWidget {
  final AddressModel? address; // <--- Dùng Model

  const AddEditAddressScreen({super.key, this.address});

  @override
  State<AddEditAddressScreen> createState() => _AddEditAddressScreenState();
}

class _AddEditAddressScreenState extends State<AddEditAddressScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _detailController = TextEditingController();
  bool _isDefault = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.address != null) {
      _nameController.text = widget.address!.name;
      _phoneController.text = widget.address!.phone;
      _detailController.text = widget.address!.detail;
      _isDefault = widget.address!.isDefault;
    }
  }

  void _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      // TẠO ĐỐI TƯỢNG AddressModel TRƯỚC KHI GỬI
      final newAddress = AddressModel(
        id: widget.address?.id ?? '', // Nếu thêm mới thì ID rỗng
        name: _nameController.text,
        phone: _phoneController.text,
        detail: _detailController.text,
        isDefault: _isDefault,
      );

      // Gửi đối tượng này vào Service
      await AddressService().saveAddress(newAddress);

      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Lỗi: $e")));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.address == null ? 'Thêm địa chỉ' : 'Sửa địa chỉ')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Tên gợi nhớ (VD: Nhà riêng)'),
                validator: (v) => v!.isEmpty ? 'Nhập tên' : null,
              ),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(labelText: 'Số điện thoại'),
                keyboardType: TextInputType.phone,
                validator: (v) => v!.isEmpty ? 'Nhập SĐT' : null,
              ),
              TextFormField(
                controller: _detailController,
                decoration: const InputDecoration(labelText: 'Địa chỉ cụ thể'),
                validator: (v) => v!.isEmpty ? 'Nhập địa chỉ' : null,
              ),
              SwitchListTile(
                title: const Text('Đặt làm địa chỉ mặc định'),
                value: _isDefault,
                activeColor: Colors.orange, // Đã fix activeThumbColor warning
                onChanged: (v) => setState(() => _isDefault = v),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _isLoading ? null : _save,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('LƯU ĐỊA CHỈ', style: TextStyle(color: Colors.white)),
              )
            ],
          ),
        ),
      ),
    );
  }
}