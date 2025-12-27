import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../models/product_model.dart'; // Import model sản phẩm

class FavoriteListScreen extends StatelessWidget {
  const FavoriteListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthService authService = AuthService();

    return Scaffold(
      appBar: AppBar(title: const Text("Món yêu thích ❤️")),
      body: StreamBuilder<List<String>>(
        stream: authService.getUserFavorites(),
        builder: (context, snapshot) {
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("Chưa có món nào được tim!"));
          }

          final favoriteIds = snapshot.data!;

          // Lọc ra các món có ID nằm trong danh sách yêu thích
          // (Lưu ý: mockProducts là list sản phẩm mẫu bạn đang dùng)
          final favoriteProducts = mockProducts
              .where((prod) => favoriteIds.contains(prod.id))
              .toList();

          return ListView.builder(
            itemCount: favoriteProducts.length,
            itemBuilder: (context, index) {
              final product = favoriteProducts[index];
              return Card(
                child: ListTile(
                  leading: Image.network(product.imageUrl, width: 50, height: 50, fit: BoxFit.cover),
                  title: Text(product.name),
                  subtitle: Text("${product.price}đ"),
                  trailing: IconButton(
                    icon: const Icon(Icons.favorite, color: Colors.red),
                    onPressed: () {
                      // Bấm vào đây là xóa khỏi danh sách yêu thích
                      authService.toggleFavorite(product.id, true);
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