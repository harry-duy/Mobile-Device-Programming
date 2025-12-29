import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import '../../models/product_model.dart';
import '../../providers/cart_provider.dart';
import '../../services/product_service.dart';
import 'favorite_list_screen.dart';
import 'product_detail_screen.dart';

class ProductListScreen extends StatefulWidget {
  const ProductListScreen({super.key});

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  final AuthService _authService = AuthService();
  final ProductService _productService = ProductService();

  String _searchQuery = '';
  String _selectedCategory = 'Tất cả';
  final List<String> _categories = ['Tất cả', 'Gà', 'Burger', 'Cơm', 'Đồ uống', 'Pizza', 'Khác'];

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDarkMode ? Colors.white : Colors.black;
    final cardColor = isDarkMode ? const Color(0xFF1E1E1E) : Colors.white;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        elevation: 0,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Chào bạn, đói chưa? 😋', style: TextStyle(color: isDarkMode ? Colors.grey : Colors.black54, fontSize: 14, fontWeight: FontWeight.normal)),
            Text('Thực đơn hôm nay', style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 22)),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16, top: 8, bottom: 8),
            decoration: BoxDecoration(color: isDarkMode ? Colors.grey.shade800 : Colors.red.shade50, shape: BoxShape.circle),
            child: IconButton(
              icon: const Icon(Icons.favorite, color: Colors.red, size: 24),
              tooltip: 'Món yêu thích',
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const FavoriteListScreen())),
            ),
          )
        ],
      ),
      body: Column(
        children: [
          // 1. THANH TÌM KIẾM
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
            child: TextField(
              onChanged: (val) => setState(() => _searchQuery = val),
              style: TextStyle(color: textColor),
              decoration: InputDecoration(
                hintText: 'Tìm món ngon...',
                hintStyle: TextStyle(color: Colors.grey.shade500),
                prefixIcon: const Icon(Icons.search, color: Colors.orange),
                filled: true,
                fillColor: isDarkMode ? Colors.grey.shade900 : Colors.grey.shade100,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              ),
            ),
          ),

          // 2. DANH MỤC (CATEGORY)
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: _categories.map((category) {
                final isSelected = _selectedCategory == category;
                return Padding(
                  padding: const EdgeInsets.only(right: 10.0),
                  child: InkWell(
                    onTap: () => setState(() => _selectedCategory = category),
                    borderRadius: BorderRadius.circular(20),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.orange : cardColor,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: isSelected ? Colors.orange : Colors.grey.shade300),
                      ),
                      child: Text(
                        category,
                        style: TextStyle(color: isSelected ? Colors.white : textColor, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 10),

          // 3. DANH SÁCH MÓN ĂN
          Expanded(
            child: StreamBuilder<List<ProductModel>>(
              stream: _productService.getProducts(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text("Chưa có món ăn nào!", style: TextStyle(color: textColor)));
                }

                final allProducts = snapshot.data!;
                final filteredProducts = allProducts.where((product) {
                  final matchName = product.name.toLowerCase().contains(_searchQuery.toLowerCase());
                  final matchCategory = _selectedCategory == 'Tất cả' || product.category == _selectedCategory;
                  return matchName && matchCategory;
                }).toList();

                if (filteredProducts.isEmpty) {
                  return Center(child: Text("Không tìm thấy món nào!", style: TextStyle(color: textColor)));
                }

                return StreamBuilder<List<String>>(
                    stream: _authService.getUserFavorites(),
                    builder: (context, favSnapshot) {
                      final favoriteIds = favSnapshot.data ?? [];

                      return ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: filteredProducts.length,
                        itemBuilder: (context, index) {
                          final product = filteredProducts[index];
                          final isFavorite = favoriteIds.contains(product.id);
                          final isOutOfStock = product.stock <= 0;

                          return InkWell(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (_) => ProductDetailScreen(product: product))
                              );
                            },
                            borderRadius: BorderRadius.circular(20),
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 20),
                              decoration: BoxDecoration(
                                color: cardColor,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: const Offset(0, 5))],
                              ),
                              child: Row(
                                children: [
                                  // ẢNH SẢN PHẨM
                                  ClipRRect(
                                    borderRadius: const BorderRadius.only(topLeft: Radius.circular(20), bottomLeft: Radius.circular(20)),
                                    child: ColorFiltered(
                                      colorFilter: isOutOfStock
                                          ? const ColorFilter.mode(Colors.grey, BlendMode.saturation)
                                          : const ColorFilter.mode(Colors.transparent, BlendMode.multiply),
                                      child: Image.network(
                                        product.imageUrl,
                                        width: 120, height: 120,
                                        fit: BoxFit.cover,
                                        errorBuilder: (ctx,e,s) => Container(width: 120, height: 120, color: Colors.grey.shade300, child: const Icon(Icons.broken_image)),
                                      ),
                                    ),
                                  ),

                                  // THÔNG TIN
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.all(12),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Expanded(child: Text(product.name, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textColor), maxLines: 1, overflow: TextOverflow.ellipsis)),
                                              InkWell(
                                                onTap: () => _authService.toggleFavorite(product.id, isFavorite),
                                                child: Icon(isFavorite ? Icons.favorite : Icons.favorite_border, color: isFavorite ? Colors.red : Colors.grey.shade400, size: 22),
                                              )
                                            ],
                                          ),
                                          const SizedBox(height: 5),
                                          Text(product.description, maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 12, color: isDarkMode ? Colors.grey : Colors.grey.shade600)),
                                          const SizedBox(height: 10),

                                          // GIÁ VÀ NÚT MUA NHANH
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text('${product.price.toInt()}đ', style: const TextStyle(color: Colors.orange, fontSize: 18, fontWeight: FontWeight.w900)),

                                              if (isOutOfStock)
                                                Container(
                                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                                  decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(5)),
                                                  child: const Text("Hết hàng", style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold)),
                                                )
                                              else
                                                InkWell(
                                                  onTap: () {
                                                    // --- LOGIC KIỂM TRA TRƯỚC KHI THÊM ---
                                                    final cart = Provider.of<CartProvider>(context, listen: false);

                                                    // 1. Xem trong giỏ đã có bao nhiêu
                                                    int currentInCart = 0;
                                                    if (cart.items.containsKey(product.id)) {
                                                      currentInCart = cart.items[product.id]!.quantity;
                                                    }

                                                    // 2. Nếu đã bằng hoặc hơn kho -> Chặn
                                                    if (currentInCart >= product.stock) {
                                                      ScaffoldMessenger.of(context).hideCurrentSnackBar();
                                                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                                                        content: Text('Số lượng đã đạt giới hạn kho!'),
                                                        backgroundColor: Colors.red,
                                                        duration: Duration(seconds: 1),
                                                      ));
                                                      return;
                                                    }

                                                    // 3. Thêm được
                                                    cart.addItem(product.id, product.price, product.name, product.imageUrl, product.stock);

                                                    ScaffoldMessenger.of(context).hideCurrentSnackBar();
                                                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Đã thêm ${product.name} vào giỏ!'), duration: const Duration(seconds: 1), backgroundColor: Colors.green));
                                                  },
                                                  child: Container(
                                                    padding: const EdgeInsets.all(8),
                                                    decoration: BoxDecoration(color: isDarkMode ? Colors.white : Colors.black, borderRadius: BorderRadius.circular(10)),
                                                    child: Icon(Icons.add, color: isDarkMode ? Colors.black : Colors.white, size: 20),
                                                  ),
                                                )
                                            ],
                                          )
                                        ],
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    }
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}