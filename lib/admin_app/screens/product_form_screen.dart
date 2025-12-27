import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/models.dart';
import '../services/product_service.dart';
import '../services/category_service.dart';

class ProductFormScreen extends StatefulWidget {
  final Product? product;
  const ProductFormScreen({super.key, this.product});

  @override
  State<ProductFormScreen> createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends State<ProductFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _productService = ProductService();
  final _categoryService = CategoryService();

  late TextEditingController _nameController;
  late TextEditingController _priceController;
  late TextEditingController _descriptionController;
  String? _selectedCategory;
  File? _imageFile;
  bool _isAvailable = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.product?.name ?? '');
    _priceController = TextEditingController(text: widget.product?.price.toString() ?? '');
    _descriptionController = TextEditingController(text: widget.product?.description ?? '');
    _isAvailable = widget.product?.isAvailable ?? true;
    // _selectedCategory = (widget.product as dynamic)?.category;
  }

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() => _imageFile = File(pickedFile.path));
    }
  }

  void _saveProduct() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      final product = Product(
        id: widget.product?.id ?? '',
        name: _nameController.text.trim(),
        price: double.parse(_priceController.text.trim()),
        description: _descriptionController.text.trim(),
        imageUrl: widget.product?.imageUrl ?? '',
        isAvailable: _isAvailable,
      );
      
      // Hack to add category since model doesn't have it yet
      (product as dynamic).category = _selectedCategory;

      if (widget.product == null) {
        await _productService.addProduct(product, imageFile: _imageFile);
      } else {
        await _productService.updateProduct(product, imageFile: _imageFile);
      }

      if (mounted) Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.product == null ? "Thêm sản phẩm" : "Sửa sản phẩm"),
        backgroundColor: Colors.blueGrey,
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  GestureDetector(
                    onTap: _pickImage,
                    child: Container(
                      height: 200,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(12),
                        image: _imageFile != null 
                          ? DecorationImage(image: FileImage(_imageFile!), fit: BoxFit.cover)
                          : (widget.product?.imageUrl.isNotEmpty == true 
                              ? DecorationImage(image: NetworkImage(widget.product!.imageUrl), fit: BoxFit.cover)
                              : null),
                      ),
                      child: _imageFile == null && (widget.product?.imageUrl.isEmpty ?? true)
                        ? const Icon(Icons.add_a_photo, size: 50, color: Colors.grey)
                        : null,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(labelText: "Tên sản phẩm", border: OutlineInputBorder()),
                    validator: (v) => v!.isEmpty ? "Vui lòng nhập tên" : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _priceController,
                    decoration: const InputDecoration(labelText: "Giá", border: OutlineInputBorder()),
                    keyboardType: TextInputType.number,
                    validator: (v) => v!.isEmpty ? "Vui lòng nhập giá" : null,
                  ),
                  const SizedBox(height: 16),
                  StreamBuilder<QuerySnapshot>(
                    stream: _categoryService.getCategories(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) return const CircularProgressIndicator();
                      final categories = snapshot.data!.docs;
                      return DropdownButtonFormField<String>(
                        value: _selectedCategory,
                        decoration: const InputDecoration(labelText: "Danh mục", border: OutlineInputBorder()),
                        items: categories.map((cat) => DropdownMenuItem(
                          value: cat['name'] as String,
                          child: Text(cat['name']),
                        )).toList(),
                        onChanged: (v) => setState(() => _selectedCategory = v),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(labelText: "Mô tả", border: OutlineInputBorder()),
                    maxLines: 3,
                  ),
                  SwitchListTile(
                    title: const Text("Còn hàng"),
                    value: _isAvailable,
                    onChanged: (v) => setState(() => _isAvailable = v),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _saveProduct,
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.blueGrey),
                      child: const Text("LƯU SẢN PHẨM", style: TextStyle(color: Colors.white)),
                    ),
                  ),
                ],
              ),
            ),
          ),
    );
  }
}
