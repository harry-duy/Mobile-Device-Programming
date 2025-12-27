import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/category_service.dart';

class CategoryManagementScreen extends StatefulWidget {
  const CategoryManagementScreen({super.key});

  @override
  State<CategoryManagementScreen> createState() => _CategoryManagementScreenState();
}

class _CategoryManagementScreenState extends State<CategoryManagementScreen> {
  final CategoryService _categoryService = CategoryService();
  final TextEditingController _nameController = TextEditingController();

  void _showAddCategoryDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Thêm danh mục mới"),
        content: TextField(
          controller: _nameController,
          decoration: const InputDecoration(labelText: "Tên danh mục"),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Hủy")),
          ElevatedButton(
            onPressed: () async {
              if (_nameController.text.isNotEmpty) {
                await _categoryService.addCategory(_nameController.text.trim());
                _nameController.clear();
                if (mounted) Navigator.pop(context);
              }
            },
            child: const Text("Thêm"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Quản lý danh mục"), backgroundColor: Colors.blueGrey),
      body: StreamBuilder<QuerySnapshot>(
        stream: _categoryService.getCategories(),
        builder: (context, snapshot) {
          if (snapshot.hasError) return const Center(child: Text("Đã xảy ra lỗi"));
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());

          final categories = snapshot.data!.docs;

          return ListView.builder(
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final category = categories[index];
              return ListTile(
                title: Text(category['name']),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _categoryService.deleteCategory(category.id),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddCategoryDialog,
        backgroundColor: Colors.blueGrey,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
