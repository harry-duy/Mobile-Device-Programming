import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product_model.dart';

class ProductService {
  final CollectionReference _productsRef = FirebaseFirestore.instance.collection('products');

  // 1. READ: Lấy danh sách sản phẩm (Stream Realtime)
  Stream<List<ProductModel>> getProducts() {
    return _productsRef.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => ProductModel.fromFirestore(doc)).toList();
    });
  }

  // 2. CREATE: Thêm sản phẩm mới
  Future<void> addProduct(ProductModel product) async {
    await _productsRef.add(product.toMap());
  }

  // 3. UPDATE: Cập nhật sản phẩm
  Future<void> updateProduct(ProductModel product) async {
    await _productsRef.doc(product.id).update(product.toMap());
  }

  // 4. DELETE: Xóa sản phẩm
  Future<void> deleteProduct(String id) async {
    await _productsRef.doc(id).delete();
  }
}