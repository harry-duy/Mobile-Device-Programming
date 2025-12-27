import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../models/product_model.dart'; // Đảm bảo bạn đã có file model này
import 'favorite_list_screen.dart'; // Import màn hình danh sách yêu thích

class ProductListScreen extends StatefulWidget {
  const ProductListScreen({super.key});

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  final AuthService _authService = AuthService();

  // Biến quản lý tìm kiếm và bộ lọc
  String _searchQuery = '';
  String _selectedCategory = 'Tất cả';
  final List<String> _categories = ['Tất cả', 'Gà', 'Burger', 'Cơm', 'Đồ uống'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Thực đơn', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false, // Ẩn nút back nếu ở trang chủ
        actions: [
          // Nút mở Danh sách yêu thích
          IconButton(
            icon: const Icon(Icons.favorite, color: Colors.red),
            tooltip: 'Món yêu thích',
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const FavoriteListScreen()));
            },
          )
        ],
      ),
      body: Column(
        children: [
          // 1. THANH TÌM KIẾM (SEARCH BAR)
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              onChanged: (value) {
                setState(() => _searchQuery = value);
              },
              decoration: InputDecoration(
                hintText: 'Tìm món ăn (vd: Gà, Trà sữa...)',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.grey.shade100,
                contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 20),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30), // Bo tròn mềm mại hơn
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          // 2. BỘ LỌC DANH MỤC (CATEGORY CHIPS)
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: _categories.map((category) {
                final isSelected = _selectedCategory == category;
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: FilterChip(
                    label: Text(category),
                    selected: isSelected,
                    selectedColor: Colors.orange.shade100,
                    checkmarkColor: Colors.orange,
                    backgroundColor: Colors.white,
                    side: BorderSide(color: isSelected ? Colors.orange : Colors.grey.shade300),
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.orange : Colors.black87,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                    onSelected: (bool selected) {
                      setState(() => _selectedCategory = category);
                    },
                  ),
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 10),

          // 3. DANH SÁCH SẢN PHẨM (Có xử lý Tim đỏ)
          Expanded(
            child: StreamBuilder<List<String>>(
              stream: _authService.getUserFavorites(), // Lắng nghe thay đổi tim
              builder: (context, snapshot) {
                // Lấy danh sách ID các món đã tim
                final favoriteIds = snapshot.data ?? [];

                // Logic lọc sản phẩm (Mock Data)
                final filteredProducts = mockProducts.where((product) {
                  final matchName = product.name.toLowerCase().contains(_searchQuery.toLowerCase());
                  final matchCategory = _selectedCategory == 'Tất cả' || product.category == _selectedCategory;
                  return matchName && matchCategory;
                }).toList();

                if (filteredProducts.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search_off, size: 50, color: Colors.grey.shade400),
                        const SizedBox(height: 10),
                        const Text('Không tìm thấy món ăn nào!', style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: filteredProducts.length,
                  itemBuilder: (context, index) {
                    final product = filteredProducts[index];
                    // Kiểm tra món này có được tim chưa
                    final isFavorite = favoriteIds.contains(product.id);

                    return Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      elevation: 2,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      child: InkWell(
                        onTap: () {
                          // TODO: Chuyển sang màn hình chi tiết sản phẩm nếu cần
                        },
                        borderRadius: BorderRadius.circular(15),
                        child: Row(
                          children: [
                            // Ảnh sản phẩm
                            Container(
                              width: 110,
                              height: 110,
                              decoration: BoxDecoration(
                                color: Colors.grey.shade200,
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(15),
                                  bottomLeft: Radius.circular(15),
                                ),
                                image: DecorationImage(
                                  image: NetworkImage(product.imageUrl),
                                  fit: BoxFit.cover,
                                  onError: (exception, stackTrace) => const Icon(Icons.broken_image),
                                ),
                              ),
                            ),

                            // Thông tin sản phẩm
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      product.name,
                                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      product.description,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          '${product.price.toStringAsFixed(0)}đ',
                                          style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.w900, fontSize: 16),
                                        ),

                                        // NÚT TIM (HEART BUTTON)
                                        Material(
                                          color: Colors.transparent,
                                          child: InkWell(
                                            borderRadius: BorderRadius.circular(50),
                                            onTap: () {
                                              // Gọi hàm toggle trong AuthService
                                              _authService.toggleFavorite(product.id, isFavorite);
                                            },
                                            child: Padding(
                                              padding: const EdgeInsets.all(8.0),
                                              child: Icon(
                                                isFavorite ? Icons.favorite : Icons.favorite_border,
                                                color: isFavorite ? Colors.red : Colors.grey,
                                                size: 26,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}