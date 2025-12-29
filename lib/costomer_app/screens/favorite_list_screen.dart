import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../models/product_model.dart';
import '../../services/product_service.dart'; // Import Service

class FavoriteListScreen extends StatelessWidget {
  const FavoriteListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthService authService = AuthService();
    final ProductService productService = ProductService(); // Khởi tạo Service

    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDarkMode ? const Color(0xFF1E1E1E) : Colors.white;
    final textColor = isDarkMode ? Colors.white : Colors.black;

    return Scaffold(
      appBar: AppBar(title: const Text("Món yêu thích ❤️"), elevation: 0),
      body: StreamBuilder<List<String>>(
        stream: authService.getUserFavorites(), // 1. Lấy danh sách ID yêu thích
        builder: (context, favSnapshot) {
          if (!favSnapshot.hasData || favSnapshot.data!.isEmpty) {
            return Center(child: Text("Chưa có món nào được tim!", style: TextStyle(color: textColor)));
          }

          final favoriteIds = favSnapshot.data!;

          // 2. Lấy danh sách TOÀN BỘ sản phẩm từ Firebase
          return StreamBuilder<List<ProductModel>>(
            stream: productService.getProducts(),
            builder: (context, prodSnapshot) {
              if (!prodSnapshot.hasData) return const Center(child: CircularProgressIndicator());

              // 3. Lọc ra những món có ID nằm trong danh sách yêu thích
              final allProducts = prodSnapshot.data!;
              final favoriteProducts = allProducts.where((prod) => favoriteIds.contains(prod.id)).toList();

              if (favoriteProducts.isEmpty) return Center(child: Text("Không tìm thấy thông tin món ăn!", style: TextStyle(color: textColor)));

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: favoriteProducts.length,
                itemBuilder: (context, index) {
                  final product = favoriteProducts[index];
                  return Card(
                    color: cardColor,
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(8),
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(product.imageUrl, width: 60, height: 60, fit: BoxFit.cover, errorBuilder: (_,__,___)=> const Icon(Icons.fastfood)),
                      ),
                      title: Text(product.name, style: TextStyle(fontWeight: FontWeight.bold, color: textColor)),
                      subtitle: Text("${product.price.toInt()}đ", style: const TextStyle(color: Colors.orange)),
                      trailing: IconButton(
                        icon: const Icon(Icons.favorite, color: Colors.red),
                        onPressed: () => authService.toggleFavorite(product.id, true),
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}