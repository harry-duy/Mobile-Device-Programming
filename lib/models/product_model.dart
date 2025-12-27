class ProductModel {
  final String id;
  final String name;
  final String description;
  final double price;
  final String imageUrl;
  final String category; // Ví dụ: 'Gà', 'Đồ uống', 'Burger'

  ProductModel({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
    required this.category,
  });
}

// Dữ liệu mẫu (Mock Data) để test tìm kiếm
final List<ProductModel> mockProducts = [
  ProductModel(id: '1', name: 'Gà Rán Giòn', description: 'Gà rán da giòn tan', price: 50000, category: 'Gà', imageUrl: 'https://via.placeholder.com/150'),
  ProductModel(id: '2', name: 'Burger Bò', description: 'Bò nướng lửa hồng', price: 65000, category: 'Burger', imageUrl: 'https://via.placeholder.com/150'),
  ProductModel(id: '3', name: 'Coca Cola', description: 'Nước ngọt giải khát', price: 15000, category: 'Đồ uống', imageUrl: 'https://via.placeholder.com/150'),
  ProductModel(id: '4', name: 'Cơm Gà', description: 'Cơm gà xối mỡ', price: 45000, category: 'Cơm', imageUrl: 'https://via.placeholder.com/150'),
  ProductModel(id: '5', name: 'Trà Sữa', description: 'Trân châu đường đen', price: 30000, category: 'Đồ uống', imageUrl: 'https://via.placeholder.com/150'),
];