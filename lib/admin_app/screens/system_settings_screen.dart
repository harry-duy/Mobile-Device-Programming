import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SystemSettingsScreen extends StatefulWidget {
  const SystemSettingsScreen({super.key});

  @override
  State<SystemSettingsScreen> createState() => _SystemSettingsScreenState();
}

class _SystemSettingsScreenState extends State<SystemSettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = true;
  
  final _appNameController = TextEditingController();
  final _businessHoursController = TextEditingController();
  final _deliveryFeeController = TextEditingController();
  bool _isAppOpen = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    var doc = await FirebaseFirestore.instance.collection('settings').doc('app_config').get();
    if (doc.exists) {
      var data = doc.data()!;
      setState(() {
        _appNameController.text = data['appName'] ?? 'My App';
        _businessHoursController.text = data['businessHours'] ?? '08:00 - 22:00';
        _deliveryFeeController.text = (data['deliveryFee'] ?? 0).toString();
        _isAppOpen = data['isAppOpen'] ?? true;
        _isLoading = false;
      });
    } else {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _saveSettings() async {
    await FirebaseFirestore.instance.collection('settings').doc('app_config').set({
      'appName': _appNameController.text,
      'businessHours': _businessHoursController.text,
      'deliveryFee': double.tryParse(_deliveryFeeController.text) ?? 0,
      'isAppOpen': _isAppOpen,
    });
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Đã lưu cài đặt")));
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Center(child: CircularProgressIndicator());

    return Scaffold(
      appBar: AppBar(title: const Text("Cài đặt hệ thống")),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _appNameController,
              decoration: const InputDecoration(labelText: "Tên ứng dụng"),
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: _businessHoursController,
              decoration: const InputDecoration(labelText: "Giờ hoạt động"),
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: _deliveryFeeController,
              decoration: const InputDecoration(labelText: "Phí giao hàng mặc định"),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 20),
            SwitchListTile(
              title: const Text("Trạng thái cửa hàng (Mở/Đóng)"),
              value: _isAppOpen,
              onChanged: (val) => setState(() => _isAppOpen = val),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: _saveSettings,
              style: ElevatedButton.styleFrom(padding: const EdgeInsets.all(16)),
              child: const Text("LƯU CÀI ĐẶT"),
            ),
          ],
        ),
      ),
    );
  }
}
