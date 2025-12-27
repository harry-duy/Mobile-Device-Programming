import 'package:flutter/material.dart';
import '../../../services/address_service.dart';

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
  final AddressService _addressService = AddressService();

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

  // Hàm tạo Input Decoration chung cho đẹp
  InputDecoration _buildDecoration(String label, IconData icon, bool isDarkMode) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: Colors.orange),
      labelStyle: TextStyle(color: isDarkMode ? Colors.grey : Colors.grey.shade700),
      filled: true,
      fillColor: isDarkMode ? Colors.grey.shade900 : Colors.grey.shade50, // Màu nền input
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: isDarkMode ? Colors.grey.shade800 : Colors.grey.shade300), // Viền mờ
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.orange, width: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDarkMode ? Colors.white : Colors.black;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.address == null ? 'Thêm địa chỉ' : 'Sửa địa chỉ'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                style: TextStyle(color: textColor),
                decoration: _buildDecoration('Tên gợi nhớ (VD: Nhà riêng)', Icons.label_outline, isDarkMode),
                validator: (v) => v!.isEmpty ? 'Vui lòng nhập tên' : null,
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _phoneController,
                style: TextStyle(color: textColor),
                keyboardType: TextInputType.phone,
                decoration: _buildDecoration('Số điện thoại nhận hàng', Icons.phone_android, isDarkMode),
                validator: (v) => v!.isEmpty ? 'Vui lòng nhập SĐT' : null,
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _detailController,
                style: TextStyle(color: textColor),
                maxLines: 3,
                decoration: _buildDecoration('Địa chỉ chi tiết (Số nhà, đường...)', Icons.location_on_outlined, isDarkMode),
                validator: (v) => v!.isEmpty ? 'Vui lòng nhập địa chỉ' : null,
              ),
              const SizedBox(height: 16),

              // Công tắc gạt
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text('Đặt làm địa chỉ mặc định', style: TextStyle(color: textColor, fontWeight: FontWeight.w500)),
                value: _isDefault,
                activeColor: Colors.orange,
                onChanged: (val) => setState(() => _isDefault = val),
              ),

              const SizedBox(height: 30),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('LƯU ĐỊA CHỈ', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}