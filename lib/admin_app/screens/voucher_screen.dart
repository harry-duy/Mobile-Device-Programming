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
  final _amountController = TextEditingController();

  void _addVoucher() async {
    if (_codeController.text.isEmpty || _amountController.text.isEmpty) return;

    await FirebaseFirestore.instance.collection('vouchers').add({
      'code': _codeController.text.trim().toUpperCase(),
      'discountAmount': double.parse(_amountController.text),
      'isActive': true,
      'createdAt': FieldValue.serverTimestamp(),
    });

    _codeController.clear();
    _amountController.clear();
    Navigator.pop(context); // Đóng dialog
  }

  void _showAddDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Tạo mã giảm giá mới"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: _codeController, decoration: const InputDecoration(labelText: "Mã (VD: TET2024)")),
            TextField(controller: _amountController, decoration: const InputDecoration(labelText: "Số tiền giảm (VNĐ)"), keyboardType: TextInputType.number),
          ],
        ),
        actions: [
          ElevatedButton(onPressed: _addVoucher, child: const Text("Tạo mã")),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Quản lý Voucher")),
      floatingActionButton: FloatingActionButton(onPressed: _showAddDialog, child: const Icon(Icons.add)),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('vouchers').orderBy('createdAt', descending: true).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final docs = snapshot.data!.docs;

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final voucher = VoucherModel.fromFirestore(docs[index]);
              return Card(
                child: ListTile(
                  title: Text(voucher.code, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.orange)),
                  subtitle: Text("Giảm: ${voucher.discountAmount}đ"),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => FirebaseFirestore.instance.collection('vouchers').doc(voucher.id).delete(),
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