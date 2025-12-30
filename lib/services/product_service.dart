import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product_model.dart';

class ProductService {
  final CollectionReference _productsRef = FirebaseFirestore.instance.collection('products');


  Stream<List<ProductModel>> getProducts() {
    return _productsRef.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => ProductModel.fromFirestore(doc)).toList();
    });
  }


  Future<void> addProduct(ProductModel product) async {
    await _productsRef.add(product.toMap());
  }


  Future<void> updateProduct(ProductModel product) async {
    await _productsRef.doc(product.id).update(product.toMap());
  }


  Future<void> deleteProduct(String id) async {
    await _productsRef.doc(id).delete();
  }
}