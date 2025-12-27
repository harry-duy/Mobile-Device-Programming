import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import '../../models/product_model.dart';
import '../../providers/cart_provider.dart';
import 'favorite_list_screen.dart';

// --- DỮ LIỆU MẪU ---
final List<ProductModel> localMockProducts = [
  ProductModel(id: '1', name: 'Gà Rán Giòn', description: 'Gà rán da giòn tan kèm sốt cay', price: 50000, category: 'Gà', imageUrl: 'https://images.unsplash.com/photo-1626082927389-6cd097cdc6ec?q=80&w=600&auto=format&fit=crop'),
  ProductModel(id: '2', name: 'Burger Bò Mỹ', description: 'Bò nướng lửa hồng, phô mai tan chảy', price: 65000, category: 'Burger', imageUrl: 'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?q=80&w=600&auto=format&fit=crop'),
  ProductModel(id: '3', name: 'Coca Cola Tươi', description: 'Nước ngọt giải khát có ga', price: 15000, category: 'Đồ uống', imageUrl: 'https://images.unsplash.com/photo-1622483767028-3f66f32aef97?q=80&w=600&auto=format&fit=crop'),
  ProductModel(id: '4', name: 'Cơm Gà Xối Mỡ', description: 'Cơm chiên giòn, gà xối mỡ mắm tỏi', price: 45000, category: 'Cơm', imageUrl: 'https://images.unsplash.com/photo-1604908176997-125f25cc6f3d?q=80&w=600&auto=format&fit=crop'),
  ProductModel(id: '5', name: 'Trà Sữa Trân Châu', description: 'Trân châu đường đen, sữa tươi', price: 30000, category: 'Đồ uống', imageUrl: 'https://images.unsplash.com/photo-1558857563-b371033873b8?q=80&w=600&auto=format&fit=crop'),
  ProductModel(id: '6', name: 'Pizza Hải Sản', description: 'Tôm, mực, nghêu, phô mai', price: 120000, category: 'Pizza', imageUrl: 'https://images.unsplash.com/photo-1565299624946-b28f40a0ae38?q=80&w=600&auto=format&fit=crop'),
];

class ProductListScreen extends StatefulWidget {
  const ProductListScreen({super.key});

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  final AuthService _authService = AuthService();
  String _searchQuery = '';
  String _selectedCategory = 'Tất cả';
  final List<String> _categories = ['Tất cả', 'Gà', 'Burger', 'Cơm', 'Đồ uống', 'Pizza'];
  late List<ProductModel> _recommendedProducts;

  @override
  void initState() {
    super.initState();
    _recommendedProducts = List.from(localMockProducts)..shuffle();
    if (_recommendedProducts.length > 5) {
      _recommendedProducts = _recommendedProducts.sublist(0, 5);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Kiểm tra xem đang ở chế độ tối hay sáng để chọn màu text
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDarkMode ? Colors.white : Colors.black;
    final subTextColor = isDarkMode ? Colors.grey.shade400 : Colors.black54;
    final cardColor = isDarkMode ? const Color(0xFF1E1E1E) : Colors.white; // Màu thẻ card

    final filteredProducts = localMockProducts.where((product) {
      final matchName = product.name.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchCategory = _selectedCategory == 'Tất cả' || product.category == _selectedCategory;
      return matchName && matchCategory;
    }).toList();

    return Scaffold(
      // Bỏ background cứng, để nó tự ăn theo Theme
      appBar: AppBar(
        // backgroundColor: Colors.transparent, // Để tự động theo theme
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Chào bạn, đói chưa? 😋', style: TextStyle(color: subTextColor, fontSize: 14, fontWeight: FontWeight.normal)),
            Text('Thực đơn hôm nay', style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 22)),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16, top: 8, bottom: 8),
            decoration: BoxDecoration(
                color: isDarkMode ? Colors.grey.shade800 : Colors.red.shade50,
                shape: BoxShape.circle
            ),
            child: IconButton(
              icon: const Icon(Icons.favorite, color: Colors.red, size: 24),
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const FavoriteListScreen())),
            ),
          )
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. SEARCH BAR (Đổi màu nền theo theme)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 20),
              child: TextField(
                onChanged: (val) => setState(() => _searchQuery = val),
                style: TextStyle(color: textColor), // Màu chữ nhập vào
                decoration: InputDecoration(
                  hintText: 'Tìm món ngon...',
                  hintStyle: TextStyle(color: Colors.grey.shade500),
                  prefixIcon: const Icon(Icons.search, color: Colors.orange),
                  filled: true,
                  // Nền search bar: Tối thì xám đậm, Sáng thì xám nhạt
                  fillColor: isDarkMode ? Colors.grey.shade900 : Colors.grey.shade100,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
                ),
              ),
            ),

            // 2. BANNER
            if (_searchQuery.isEmpty && _selectedCategory == 'Tất cả') ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text("Món ngon phải thử 🔥", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: textColor)),
              ),
              const SizedBox(height: 15),
              SizedBox(
                height: 180,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _recommendedProducts.length,
                  itemBuilder: (context, index) {
                    final product = _recommendedProducts[index];
                    return Container(
                      width: 280,
                      margin: const EdgeInsets.only(right: 16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 10, offset: const Offset(0,5))],
                        image: DecorationImage(image: NetworkImage(product.imageUrl), fit: BoxFit.cover),
                      ),
                      child: Stack(
                        children: [
                          Positioned.fill(
                            child: Container(decoration: BoxDecoration(borderRadius: BorderRadius.circular(20), gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.transparent, Colors.black.withOpacity(0.8)]))),
                          ),
                          Positioned(
                            bottom: 15, left: 15, right: 15,
                            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: Colors.orange, borderRadius: BorderRadius.circular(8)), child: const Text("Best Seller", style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold))),
                              const SizedBox(height: 5),
                              Text(product.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                              Text("${product.price.toInt()}đ", style: const TextStyle(color: Colors.orangeAccent, fontWeight: FontWeight.bold, fontSize: 16)),
                            ],
                            ),
                          )
                        ],
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 25),
            ],

            // 3. CATEGORY CHIPS
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
                          color: isSelected ? Colors.orange : cardColor, // Dùng cardColor thay vì White cứng
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: isSelected ? Colors.orange : (isDarkMode ? Colors.grey.shade800 : Colors.grey.shade300)),
                        ),
                        child: Text(
                          category,
                          style: TextStyle(
                            color: isSelected ? Colors.white : textColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: 20),

            // 4. LIST ITEMS
            StreamBuilder<List<String>>(
              stream: _authService.getUserFavorites(),
              builder: (context, snapshot) {
                final favoriteIds = snapshot.data ?? [];
                if (filteredProducts.isEmpty) return const Center(child: Padding(padding: EdgeInsets.all(30), child: Text("Không tìm thấy món nào!")));

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: filteredProducts.length,
                  itemBuilder: (context, index) {
                    final product = filteredProducts[index];
                    final isFavorite = favoriteIds.contains(product.id);

                    return Container(
                      margin: const EdgeInsets.only(bottom: 20),
                      decoration: BoxDecoration(
                        color: cardColor, // Dùng màu thẻ động (Đen/Trắng)
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 15, offset: const Offset(0, 5))],
                      ),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: const BorderRadius.only(topLeft: Radius.circular(20), bottomLeft: Radius.circular(20)),
                            child: Image.network(product.imageUrl, width: 120, height: 120, fit: BoxFit.cover, errorBuilder: (ctx,e,s)=>Container(width: 120, height: 120, color: Colors.grey)),
                          ),
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
                                      InkWell(onTap: () => _authService.toggleFavorite(product.id, isFavorite), child: Icon(isFavorite ? Icons.favorite : Icons.favorite_border, color: isFavorite ? Colors.red : Colors.grey.shade400, size: 22))
                                    ],
                                  ),
                                  const SizedBox(height: 5),
                                  Text(product.description, maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
                                  const SizedBox(height: 10),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text('${product.price.toInt()}đ', style: const TextStyle(color: Colors.orange, fontSize: 18, fontWeight: FontWeight.w900)),
                                      InkWell(
                                        onTap: () {
                                          Provider.of<CartProvider>(context, listen: false).addItem(product.id, product.price, product.name, product.imageUrl);
                                          ScaffoldMessenger.of(context).hideCurrentSnackBar();
                                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Đã thêm ${product.name} vào giỏ!'), duration: const Duration(seconds: 1), backgroundColor: Colors.green, behavior: SnackBarBehavior.floating));
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                              color: isDarkMode ? Colors.white : Colors.black, // Đảo màu nút cộng cho nổi
                                              borderRadius: BorderRadius.circular(10)
                                          ),
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
                    );
                  },
                );
              },
            ),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }
}