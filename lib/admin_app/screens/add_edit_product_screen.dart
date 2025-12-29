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

  // Các controller để lấy dữ liệu nhập vào
  final _nameController = TextEditingController();
  final _descController = TextEditingController(); // Mô tả chi tiết
  final _priceController = TextEditingController();
  final _imageController = TextEditingController();
  final _stockController = TextEditingController(); // Số lượng tồn kho

  String _category = 'Gà'; // Mặc định
  final List<String> _categories = ['Gà', 'Burger', 'Cơm', 'Đồ uống', 'Pizza', 'Khác'];

  @override
  void initState() {
    super.initState();
    // Nếu là sửa -> Điền sẵn dữ liệu cũ
    if (widget.product != null) {
      _nameController.text = widget.product!.name;
      _descController.text = widget.product!.description;
      _priceController.text = widget.product!.price.toStringAsFixed(0);
      _imageController.text = widget.product!.imageUrl;
      _stockController.text = widget.product!.stock.toString();
      _category = widget.product!.category;
    }
  }

  void _saveProduct() async {
    if (!_formKey.currentState!.validate()) return;

    final name = _nameController.text;
    final desc = _descController.text;
    final price = double.tryParse(_priceController.text) ?? 0;
    final stock = int.tryParse(_stockController.text) ?? 0;
    final image = _imageController.text;

    final productService = ProductService();

    final newProduct = ProductModel(
      id: widget.product?.id ?? '', // Giữ ID cũ nếu sửa, rỗng nếu thêm
      name: name,
      description: desc,
      price: price,
      imageUrl: image,
      category: _category,
      stock: stock,
    );

    if (widget.product == null) {
      // THÊM MỚI
      await productService.addProduct(newProduct);
    } else {
      // CẬP NHẬT
      await productService.updateProduct(newProduct);
    }

    if (mounted) {
      Navigator.pop(context); // Quay về danh sách
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đã lưu món ăn thành công!')),
      );
    }
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
              // 1. TÊN MÓN
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Tên món ăn', border: OutlineInputBorder()),
                validator: (v) => v!.isEmpty ? 'Vui lòng nhập tên' : null,
              ),
              const SizedBox(height: 15),

              // 2. GIÁ & KHO (Nằm cùng 1 hàng cho gọn)
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _priceController,
                      decoration: const InputDecoration(labelText: 'Giá tiền (VNĐ)', border: OutlineInputBorder()),
                      keyboardType: TextInputType.number,
                      validator: (v) => v!.isEmpty ? 'Nhập giá' : null,
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: TextFormField(
                      controller: _stockController,
                      decoration: const InputDecoration(labelText: 'Tồn kho (Số lượng)', border: OutlineInputBorder()),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 15),

              // 3. MÔ TẢ CHI TIẾT
              TextFormField(
                controller: _descController,
                maxLines: 3, // Cho phép nhập nhiều dòng
                decoration: const InputDecoration(
                  labelText: 'Mô tả chi tiết (Thành phần, hương vị...)',
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: 15),

              // 4. LINK ẢNH
              TextFormField(
                controller: _imageController,
                decoration: const InputDecoration(labelText: 'Link ảnh (URL)', border: OutlineInputBorder(), hintText: 'https://...'),
              ),
              const SizedBox(height: 15),

              // 5. DANH MỤC
              DropdownButtonFormField<String>(
                value: _category,
                decoration: const InputDecoration(labelText: 'Danh mục', border: OutlineInputBorder()),
                items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                onChanged: (v) => setState(() => _category = v!),
              ),

              const SizedBox(height: 30),

              // 6. NÚT LƯU
              SizedBox(
                height: 50,
                child: ElevatedButton(
                  onPressed: _saveProduct,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blueGrey),
                  child: const Text('LƯU SẢN PHẨM', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}