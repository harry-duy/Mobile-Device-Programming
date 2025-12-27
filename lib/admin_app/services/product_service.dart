import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../../models/models.dart';

class ProductService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Get all products
  Stream<List<Product>> getProducts() {
    return _db.collection('products').snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => Product.fromFirestore(doc.data(), doc.id)).toList());
  }

  // Upload image to Firebase Storage
  Future<String> uploadImage(File imageFile) async {
    String fileName = DateTime.now().millisecondsSinceEpoch.toString();
    Reference ref = _storage.ref().child('product_images').child(fileName);
    UploadTask uploadTask = ref.putFile(imageFile);
    TaskSnapshot snapshot = await uploadTask;
    return await snapshot.ref.getDownloadURL();
  }

  // Add product
  Future<void> addProduct(Product product, {File? imageFile}) async {
    String imageUrl = product.imageUrl;
    if (imageFile != null) {
      imageUrl = await uploadImage(imageFile);
    }

    await _db.collection('products').add({
      'name': product.name,
      'price': product.price,
      'description': product.description,
      'imageUrl': imageUrl,
      'isAvailable': product.isAvailable,
      'category': (product as dynamic).category, // Giả định có thêm category
    });
  }

  // Update product
  Future<void> updateProduct(Product product, {File? imageFile}) async {
    String imageUrl = product.imageUrl;
    if (imageFile != null) {
      imageUrl = await uploadImage(imageFile);
    }

    await _db.collection('products').doc(product.id).update({
      'name': product.name,
      'price': product.price,
      'description': product.description,
      'imageUrl': imageUrl,
      'isAvailable': product.isAvailable,
      'category': (product as dynamic).category,
    });
  }

  // Delete product
  Future<void> deleteProduct(String id) async {
    await _db.collection('products').doc(id).delete();
  }
}
