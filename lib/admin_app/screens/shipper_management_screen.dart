import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/models.dart';

class ShipperManagementScreen extends StatelessWidget {
  const ShipperManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Quản lý Shipper"),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showShipperForm(context),
          )
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('shippers').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          
          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var doc = snapshot.data!.docs[index];
              var data = doc.data() as Map<String, dynamic>;
              
              return ListTile(
                leading: const CircleAvatar(child: Icon(Icons.person)),
                title: Text(data['name'] ?? 'N/A'),
                subtitle: Text("SĐT: ${data['phone']} | Xe: ${data['vehicleNumber']}"),
                trailing: IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () => _showShipperForm(context, doc: doc),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _showShipperForm(BuildContext context, {DocumentSnapshot? doc}) {
    final nameController = TextEditingController(text: doc != null ? doc['name'] : '');
    final phoneController = TextEditingController(text: doc != null ? doc['phone'] : '');
    final vehicleController = TextEditingController(text: doc != null ? doc['vehicleNumber'] : '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(doc == null ? "Thêm Shipper" : "Sửa Shipper"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameController, decoration: const InputDecoration(labelText: "Tên")),
            TextField(controller: phoneController, decoration: const InputDecoration(labelText: "SĐT")),
            TextField(controller: vehicleController, decoration: const InputDecoration(labelText: "Biển số xe")),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Hủy")),
          ElevatedButton(
            onPressed: () async {
              final data = {
                'name': nameController.text,
                'phone': phoneController.text,
                'vehicleNumber': vehicleController.text,
              };
              if (doc == null) {
                await FirebaseFirestore.instance.collection('shippers').add(data);
              } else {
                await doc.reference.update(data);
              }
              Navigator.pop(context);
            },
            child: const Text("Lưu"),
          ),
        ],
      ),
    );
  }
}
