import 'package:cloud_firestore/cloud_firestore.dart';

class ProductModel {
  final String id;
  final String name;
  final String description;
  final double price;
  final String imageUrl;
  final String category;

  ProductModel({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
    required this.category,
  });

  factory ProductModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return ProductModel(
      id: doc.id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      price: (data['price'] ?? 0).toDouble(),
      imageUrl: data['imageUrl'] ?? '',
      category: data['category'] ?? 'Khác',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'price': price,
      'imageUrl': imageUrl,
      'category': category,
    };
  }
}

// --- DANH SÁCH MẪU DÙNG CHUNG TOÀN APP (Thêm vào đây) ---
final List<ProductModel> mockProducts = [
  ProductModel(id: '1', name: 'Gà Rán Giòn', description: 'Gà rán da giòn tan kèm sốt cay', price: 50000, category: 'Gà', imageUrl: 'https://images.unsplash.com/photo-1626082927389-6cd097cdc6ec?q=80&w=600&auto=format&fit=crop'),
  ProductModel(id: '2', name: 'Burger Bò Mỹ', description: 'Bò nướng lửa hồng, phô mai tan chảy', price: 65000, category: 'Burger', imageUrl: 'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?q=80&w=600&auto=format&fit=crop'),
  ProductModel(id: '3', name: 'Coca Cola Tươi', description: 'Nước ngọt giải khát có ga', price: 15000, category: 'Đồ uống', imageUrl: 'https://images.unsplash.com/photo-1622483767028-3f66f32aef97?q=80&w=600&auto=format&fit=crop'),
  ProductModel(id: '4', name: 'Cơm Gà Xối Mỡ', description: 'Cơm chiên giòn, gà xối mỡ mắm tỏi', price: 45000, category: 'Cơm', imageUrl: 'https://images.unsplash.com/photo-1604908176997-125f25cc6f3d?q=80&w=600&auto=format&fit=crop'),
  ProductModel(id: '5', name: 'Trà Sữa Trân Châu', description: 'Trân châu đường đen, sữa tươi', price: 30000, category: 'Đồ uống', imageUrl: 'https://images.unsplash.com/photo-1558857563-b371033873b8?q=80&w=600&auto=format&fit=crop'),
  ProductModel(id: '6', name: 'Pizza Hải Sản', description: 'Tôm, mực, nghêu, phô mai', price: 120000, category: 'Pizza', imageUrl: 'https://images.unsplash.com/photo-1565299624946-b28f40a0ae38?q=80&w=600&auto=format&fit=crop'),
];