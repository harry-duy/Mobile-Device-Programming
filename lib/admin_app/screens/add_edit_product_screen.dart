import 'package:flutter/material.dart';
import '../../models/product_model.dart';
import '../../services/product_service.dart';

class AddEditProductScreen extends StatefulWidget {
  final ProductModel? product; // Nếu null là Thêm, có dữ liệu là Sửa

  const AddEditProductScreen({super.key, this.product});

  @override
  State<AddEditProductScreen> createState() => _AddEditProductScreenState();
}

class _AddEditProductScreenState extends State<AddEditProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  final _priceController = TextEditingController();
  final _imageController = TextEditingController();
  String _category = 'Gà'; // Mặc định
  final List<String> _categories = ['Gà', 'Burger', 'Cơm', 'Đồ uống', 'Pizza', 'Khác'];

  @override
  void initState() {
    super.initState();
    if (widget.product != null) {
      _nameController.text = widget.product!.name;
      _descController.text = widget.product!.description;
      _priceController.text = widget.product!.price.toStringAsFixed(0);
      _imageController.text = widget.product!.imageUrl;
      _category = widget.product!.category;
    }
  }

  void _saveProduct() async {
    if (!_formKey.currentState!.validate()) return;

    final name = _nameController.text;
    final desc = _descController.text;
    final price = double.tryParse(_priceController.text) ?? 0;
    final image = _imageController.text;

    final productService = ProductService();

    if (widget.product == null) {
      // THÊM MỚI
      final newProduct = ProductModel(id: '', name: name, description: desc, price: price, imageUrl: image, category: _category);
      await productService.addProduct(newProduct);
    } else {
      // CẬP NHẬT
      final updatedProduct = ProductModel(id: widget.product!.id, name: name, description: desc, price: price, imageUrl: image, category: _category);
      await productService.updateProduct(updatedProduct);
    }

    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.product == null ? 'Thêm món mới' : 'Sửa món ăn')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(controller: _nameController, decoration: const InputDecoration(labelText: 'Tên món'), validator: (v) => v!.isEmpty ? 'Nhập tên' : null),
              TextFormField(controller: _priceController, decoration: const InputDecoration(labelText: 'Giá tiền'), keyboardType: TextInputType.number, validator: (v) => v!.isEmpty ? 'Nhập giá' : null),
              TextFormField(controller: _descController, decoration: const InputDecoration(labelText: 'Mô tả ngắn')),
              TextFormField(controller: _imageController, decoration: const InputDecoration(labelText: 'Link ảnh (URL)')),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: _category,
                decoration: const InputDecoration(labelText: 'Danh mục'),
                items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                onChanged: (v) => setState(() => _category = v!),
              ),
              const SizedBox(height: 20),
              ElevatedButton(onPressed: _saveProduct, style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, foregroundColor: Colors.white), child: const Text('LƯU SẢN PHẨM')),
            ],
          ),
        ),
      ),
    );
  }
}