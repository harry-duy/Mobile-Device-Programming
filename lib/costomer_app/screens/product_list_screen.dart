import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/firebase_service.dart';
import '../../models/models.dart';

class ProductListScreen extends StatelessWidget {
  const ProductListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final FirebaseService service = FirebaseService();

    return StreamBuilder<QuerySnapshot>(
      stream: service.getProducts(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text("Hiện chưa có món ăn nào trong thực đơn."));
        }

        return ListView.builder(
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            final doc = snapshot.data!.docs[index];
            final product = Product.fromFirestore(doc.data() as Map<String, dynamic>, doc.id);

            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              child: ListTile(
                leading: const Icon(Icons.fastfood, color: Colors.orange),
                title: Text(product.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text("${product.price.toInt()} VNĐ"),
                trailing: IconButton(
                  icon: const Icon(Icons.add_circle, color: Colors.green),
                  onPressed: () {
                    // Trong thực tế bạn sẽ thêm vào Provider/Cart State tại đây
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Đã thêm ${product.name} vào giỏ")),
                    );
                  },
                ),
              ),
            );
          },
        );
      },
    );
  }
}