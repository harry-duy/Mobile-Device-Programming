import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../models/product_model.dart'; // Đã chứa danh sách mockProducts

class FavoriteListScreen extends StatelessWidget {
  const FavoriteListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthService authService = AuthService();
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDarkMode ? const Color(0xFF1E1E1E) : Colors.white;
    final textColor = isDarkMode ? Colors.white : Colors.black;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Món yêu thích ❤️"),
        elevation: 0,
      ),
      body: StreamBuilder<List<String>>(
        stream: authService.getUserFavorites(),
        builder: (context, snapshot) {
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.favorite_border, size: 80, color: Colors.grey.shade400),
                  const SizedBox(height: 16),
                  Text("Chưa có món nào được tim!", style: TextStyle(color: textColor, fontSize: 16)),
                ],
              ),
            );
          }

          final favoriteIds = snapshot.data!;

          // Lọc ra các món có ID nằm trong danh sách yêu thích
          // Giờ đây biến mockProducts đã được lấy từ file product_model.dart
          final favoriteProducts = mockProducts
              .where((prod) => favoriteIds.contains(prod.id))
              .toList();

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: favoriteProducts.length,
            itemBuilder: (context, index) {
              final product = favoriteProducts[index];
              return Card(
                color: cardColor,
                elevation: 2,
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(10),
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.network(product.imageUrl, width: 60, height: 60, fit: BoxFit.cover, errorBuilder: (c,e,s)=>const Icon(Icons.fastfood)),
                  ),
                  title: Text(product.name, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: textColor)),
                  subtitle: Text("${product.price.toInt()}đ", style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.bold)),
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