import 'package:flutter/material.dart';
import '../../../services/address_service.dart'; // <--- Import đúng đường dẫn

class AddEditAddressScreen extends StatefulWidget {
  final AddressModel? address;

  const AddEditAddressScreen({super.key, this.address});

  @override
  State<AddEditAddressScreen> createState() => _AddEditAddressScreenState();
}

class _AddEditAddressScreenState extends State<AddEditAddressScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController(text: 'Nhà riêng');
  final _phoneController = TextEditingController();
  final _detailController = TextEditingController();
  bool _isDefault = false;
  final AddressService _addressService = AddressService(); // Đã import được class này

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

    await _addressService.saveAddress(
      id: widget.address?.id,
      name: _nameController.text,
      phone: _phoneController.text,
      detail: _detailController.text,
      isDefault: _isDefault,
    );

    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.address == null ? 'Thêm địa chỉ mới' : 'Sửa địa chỉ'),
        backgroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Tên gợi nhớ (VD: Nhà riêng)'),
                validator: (v) => v!.isEmpty ? 'Nhập tên gợi nhớ' : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(labelText: 'Số điện thoại'),
                keyboardType: TextInputType.phone,
                validator: (v) => v!.isEmpty ? 'Nhập SĐT' : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _detailController,
                decoration: const InputDecoration(labelText: 'Địa chỉ chi tiết'),
                validator: (v) => v!.isEmpty ? 'Nhập địa chỉ' : null,
              ),
              const SizedBox(height: 10),
              SwitchListTile(
                title: const Text('Đặt làm địa chỉ mặc định'),
                value: _isDefault,
                activeColor: Colors.orange, // Đã fix warning bằng cách dùng activeColor bình thường
                onChanged: (val) => setState(() => _isDefault = val),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _save,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                  child: const Text('Lưu Địa Chỉ', style: TextStyle(color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}