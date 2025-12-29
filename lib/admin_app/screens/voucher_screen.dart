import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/voucher_model.dart';

class VoucherScreen extends StatefulWidget {
  const VoucherScreen({super.key});

  @override
  State<VoucherScreen> createState() => _VoucherScreenState();
}

class _VoucherScreenState extends State<VoucherScreen> {
  final _codeController = TextEditingController();
  final _valueController = TextEditingController();
  final _minOrderController = TextEditingController();
  final _quantityController = TextEditingController();

  String _selectedType = 'fixed'; // Mặc định: Trừ tiền trực tiếp
  bool _isCreating = false; // Biến để hiện vòng quay loading khi đang tạo

  // --- HÀM TẠO MÃ (ĐÃ FIX LỖI) ---
  void _addVoucher() async {
    // 1. Kiểm tra nhập liệu
    if (_codeController.text.isEmpty || _valueController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Vui lòng nhập Mã và Số tiền/Phần trăm!")));
      return;
    }

    setState(() => _isCreating = true); // Bật loading

    try {
      // 2. Gửi lên Firebase
      await FirebaseFirestore.instance.collection('vouchers').add({
        'code': _codeController.text.trim().toUpperCase(),
        'discountValue': double.parse(_valueController.text),
        'type': _selectedType,
        'minOrderAmount': double.tryParse(_minOrderController.text) ?? 0,
        'maxUsage': int.tryParse(_quantityController.text) ?? 100,
        'usedCount': 0,
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
      });

      // 3. Xóa form và đóng dialog
      _codeController.clear();
      _valueController.clear();
      _minOrderController.clear();
      _quantityController.clear();

      if (mounted) {
        Navigator.of(context).pop(); // Đóng Dialog
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Tạo mã thành công! 🎉"), backgroundColor: Colors.green));
      }

    } catch (e) {
      // 4. Báo lỗi nếu có (VD: Lỗi quyền, lỗi mạng)
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Lỗi: $e"), backgroundColor: Colors.red));
      }
    } finally {
      if (mounted) setState(() => _isCreating = false); // Tắt loading
    }
  }

  void _showAddDialog() {
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: const Text("Tạo mã giảm giá mới"),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: _codeController,
                      decoration: const InputDecoration(labelText: "Mã Code (VD: TET2024)", border: OutlineInputBorder()),
                      textCapitalization: TextCapitalization.characters, // Tự động viết hoa
                    ),
                    const SizedBox(height: 10),

                    Row(
                      children: [
                        const Text("Loại: "),
                        const SizedBox(width: 10),
                        DropdownButton<String>(
                          value: _selectedType,
                          items: const [
                            DropdownMenuItem(value: 'fixed', child: Text("Trừ tiền trực tiếp")),
                            DropdownMenuItem(value: 'percent', child: Text("Giảm theo %")),
                          ],
                          onChanged: (val) => setStateDialog(() => _selectedType = val!),
                        ),
                      ],
                    ),

                    TextField(
                        controller: _valueController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                            labelText: _selectedType == 'fixed' ? "Số tiền giảm (VNĐ)" : "Phần trăm giảm (%)",
                            suffixText: _selectedType == 'fixed' ? "đ" : "%",
                            border: const OutlineInputBorder()
                        )
                    ),
                    const SizedBox(height: 10),

                    TextField(controller: _minOrderController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: "Đơn tối thiểu (VNĐ)", border: OutlineInputBorder())),
                    const SizedBox(height: 10),

                    TextField(controller: _quantityController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: "Số lượng mã (Lượt dùng)", border: OutlineInputBorder())),
                  ],
                ),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context), child: const Text("Hủy")),
                ElevatedButton(
                  onPressed: _isCreating ? null : _addVoucher, // Vô hiệu hóa nút khi đang tạo
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                  child: _isCreating
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Text("Tạo mã", style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          }
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Quản lý Voucher")),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddDialog,
        backgroundColor: Colors.orange,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('vouchers').orderBy('createdAt', descending: true).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) return Center(child: Text("Lỗi: ${snapshot.error}"));
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

          final docs = snapshot.data!.docs;
          if (docs.isEmpty) return const Center(child: Text("Chưa có mã giảm giá nào"));

          return ListView.builder(
            padding: const EdgeInsets.all(10),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final voucher = VoucherModel.fromFirestore(docs[index]);
              String discountText = voucher.type == 'fixed'
                  ? "${voucher.discountValue.toStringAsFixed(0)}đ"
                  : "${voucher.discountValue.toStringAsFixed(0)}%";

              return Card(
                elevation: 3,
                margin: const EdgeInsets.only(bottom: 10),
                child: ListTile(
                  leading: const Icon(Icons.confirmation_number, color: Colors.orange, size: 40),
                  title: Text(voucher.code, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Giảm: $discountText (Đơn tối thiểu: ${voucher.minOrderAmount.toStringAsFixed(0)}đ)"),
                      Text("Đã dùng: ${voucher.usedCount}/${voucher.maxUsage}", style: TextStyle(color: voucher.usedCount >= voucher.maxUsage ? Colors.red : Colors.green, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      // Xác nhận xóa
                      showDialog(context: context, builder: (c) => AlertDialog(
                        title: const Text("Xóa mã này?"),
                        content: const Text("Hành động này không thể hoàn tác."),
                        actions: [
                          TextButton(onPressed: () => Navigator.pop(c), child: const Text("Hủy")),
                          TextButton(onPressed: () {
                            FirebaseFirestore.instance.collection('vouchers').doc(voucher.id).delete();
                            Navigator.pop(c);
                          }, child: const Text("Xóa", style: TextStyle(color: Colors.red))),
                        ],
                      ));
                    },
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