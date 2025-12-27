import 'package:cloud_firestore/cloud_firestore.dart';

class CategoryService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<QuerySnapshot> getCategories() {
    return _db.collection('categories').snapshots();
  }

  Future<void> addCategory(String name) async {
    await _db.collection('categories').add({'name': name});
  }

  Future<void> deleteCategory(String id) async {
    await _db.collection('categories').doc(id).delete();
  }
}
