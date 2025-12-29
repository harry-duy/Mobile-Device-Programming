import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../models/product_model.dart';
import '../../models/review_model.dart';
import '../../providers/cart_provider.dart';

class ProductDetailScreen extends StatefulWidget {
  final ProductModel product;
  const ProductDetailScreen({super.key, required this.product});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int _quantity = 1;

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDarkMode ? Colors.grey.shade900 : Colors.white;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // 1. ẢNH HEADER
          SliverAppBar(
            expandedHeight: 300.0,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(widget.product.name,
                  style: const TextStyle(color: Colors.white, shadows: [Shadow(color: Colors.black, blurRadius: 10)])),
              background: Image.network(widget.product.imageUrl, fit: BoxFit.cover,
                  errorBuilder: (_,__,___) => Container(color: Colors.grey, child: const Icon(Icons.fastfood, size: 50))),
            ),
          ),

          // 2. NỘI DUNG
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // GIÁ & KHO
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("${widget.product.price.toInt()}đ",
                          style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: Colors.orange)),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                            color: widget.product.stock > 0 ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10)
                        ),
                        child: Text(
                          widget.product.stock > 0 ? "Còn hàng: ${widget.product.stock}" : "HẾT HÀNG",
                          style: TextStyle(color: widget.product.stock > 0 ? Colors.green : Colors.red, fontWeight: FontWeight.bold),
                        ),
                      )
                    ],
                  ),
                  const SizedBox(height: 15),

                  const Text("Mô tả món ăn", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  const SizedBox(height: 5),
                  Text(widget.product.description.isEmpty ? "Chưa có mô tả." : widget.product.description,
                      style: TextStyle(fontSize: 16, color: isDarkMode ? Colors.grey.shade300 : Colors.grey.shade700, height: 1.5)),

                  const SizedBox(height: 25),
                  const Divider(),

                  // --- KHU VỰC ĐÁNH GIÁ (ĐÃ NÂNG CẤP) ---
                  StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('reviews')
                        .where('productId', isEqualTo: widget.product.id)
                        .orderBy('date', descending: true)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      final reviews = snapshot.data?.docs ?? [];

                      // Tính điểm trung bình
                      double totalRating = 0;
                      if (reviews.isNotEmpty) {
                        for (var doc in reviews) {
                          totalRating += (doc.data() as Map<String, dynamic>)['rating'] ?? 0;
                        }
                      }
                      double averageRating = reviews.isEmpty ? 0 : totalRating / reviews.length;

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header Đánh giá (Hiện số sao trung bình)
                          Row(
                            children: [
                              const Text("Đánh giá khách hàng", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                              const Spacer(),
                              if (reviews.isNotEmpty) ...[
                                Text(averageRating.toStringAsFixed(1), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.amber)),
                                const Icon(Icons.star, color: Colors.amber, size: 20),
                                Text(" (${reviews.length})", style: const TextStyle(color: Colors.grey)),
                              ]
                            ],
                          ),
                          const SizedBox(height: 10),

                          if (reviews.isEmpty)
                            const Padding(padding: EdgeInsets.symmetric(vertical: 20), child: Text("Chưa có đánh giá nào. Hãy thử ngay!", style: TextStyle(color: Colors.grey)))
                          else
                            ListView.separated(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: reviews.length,
                              separatorBuilder: (_,__) => const SizedBox(height: 10),
                              itemBuilder: (context, index) {
                                final reviewData = reviews[index].data() as Map<String, dynamic>;
                                final review = ReviewModel.fromFirestore(reviews[index]);

                                return Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: cardColor,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: Colors.grey.withOpacity(0.1)),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(review.userName, style: const TextStyle(fontWeight: FontWeight.bold)),
                                          // HIỂN THỊ SAO VÀNG CỦA TỪNG REVIEW
                                          Row(
                                            children: List.generate(5, (i) => Icon(
                                                i < review.rating ? Icons.star : Icons.star_border,
                                                color: Colors.amber,
                                                size: 16
                                            )),
                                          )
                                        ],
                                      ),
                                      const SizedBox(height: 5),
                                      Text(review.comment),
                                      const SizedBox(height: 5),
                                      Text(DateFormat('dd/MM/yyyy HH:mm').format(review.date),
                                          style: const TextStyle(fontSize: 10, color: Colors.grey)),
                                    ],
                                  ),
                                );
                              },
                            ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 80),
                ],
              ),
            ),
          )
        ],
      ),

      // 3. THANH ĐẶT HÀNG (GIỮ NGUYÊN)
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: cardColor, boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: const Offset(0, -5))]),
        child: Row(
          children: [
            Container(
              decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(10)),
              child: Row(
                children: [
                  IconButton(onPressed: _quantity > 1 ? () => setState(() => _quantity--) : null, icon: const Icon(Icons.remove)),
                  Text("$_quantity", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  IconButton(onPressed: _quantity < widget.product.stock ? () => setState(() => _quantity++) : null,
                      icon: Icon(Icons.add, color: _quantity < widget.product.stock ? Colors.orange : Colors.grey)),
                ],
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: ElevatedButton(
                onPressed: widget.product.stock <= 0 ? null : () {
                  final cart = Provider.of<CartProvider>(context, listen: false);
                  int currentInCart = 0;
                  if (cart.items.containsKey(widget.product.id)) {
                    currentInCart = cart.items[widget.product.id]!.quantity;
                  }
                  if (currentInCart + _quantity > widget.product.stock) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Kho chỉ còn ${widget.product.stock} món. Bạn đã có $currentInCart trong giỏ."), backgroundColor: Colors.red));
                    return;
                  }
                  for(int i=0; i<_quantity; i++) {
                    cart.addItem(widget.product.id, widget.product.price, widget.product.name, widget.product.imageUrl, widget.product.stock);
                  }
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Đã thêm $_quantity món vào giỏ!")));
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange, padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: Text(widget.product.stock <= 0 ? "HẾT HÀNG" : "THÊM VÀO GIỎ", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}