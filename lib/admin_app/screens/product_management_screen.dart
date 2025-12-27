import 'package:flutter/material.dart';
import '../../models/models.dart';
import '../services/product_service.dart';
import 'product_form_screen.dart';

class ProductManagementScreen extends StatelessWidget {
  const ProductManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final productService = ProductService();

    return Scaffold(
      appBar: AppBar(title: const Text("Quản lý sản phẩm"), backgroundColor: Colors.blueGrey),
      body: StreamBuilder<List<Product>>(
        stream: productService.getProducts(),
        builder: (context, snapshot) {
          if (snapshot.hasError) return const Center(child: Text("Đã xảy ra lỗi"));
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());

          final products = snapshot.data!;

          return ListView.builder(
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index];
              return ListTile(
                leading: product.imageUrl.isNotEmpty 
                  ? Image.network(product.imageUrl, width: 50, height: 50, fit: BoxFit.cover)
                  : const Icon(Icons.fastfood),
                title: Text(product.name),
                subtitle: Text("${product.price.toStringAsFixed(0)}đ"),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.blue),
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => ProductFormScreen(product: product)),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => productService.deleteProduct(product.id),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ProductFormScreen()),
        ),
        backgroundColor: Colors.blueGrey,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
