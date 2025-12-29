import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert'; // Để mã hóa dữ liệu thành chuỗi JSON

class CartItem {
  final String id;
  final String title;
  final int quantity;
  final double price;
  final String imageUrl;
  final int stock;

  CartItem({
    required this.id,
    required this.title,
    required this.quantity,
    required this.price,
    required this.imageUrl,
    required this.stock,
  });

  // Chuyển CartItem thành Map để lưu
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'quantity': quantity,
      'price': price,
      'imageUrl': imageUrl,
      'stock': stock,
    };
  }

  // Tạo CartItem từ Map khi tải lại
  factory CartItem.fromMap(Map<String, dynamic> map) {
    return CartItem(
      id: map['id'],
      title: map['title'],
      quantity: map['quantity'],
      price: map['price'],
      imageUrl: map['imageUrl'],
      stock: map['stock'],
    );
  }
}

class CartProvider with ChangeNotifier {
  Map<String, CartItem> _items = {};

  Map<String, CartItem> get items => _items;

  int get itemCount => _items.length;

  double get totalAmount {
    var total = 0.0;
    _items.forEach((key, cartItem) {
      total += cartItem.price * cartItem.quantity;
    });
    return total;
  }

  // --- HÀM KHỞI TẠO: TỰ ĐỘNG TẢI GIỎ HÀNG ---
  CartProvider() {
    loadCartData();
  }

  // Thêm món
  void addItem(String productId, double price, String title, String imageUrl, int maxStock) {
    if (_items.containsKey(productId)) {
      if (_items[productId]!.quantity >= maxStock) return;
      _items.update(
        productId,
            (existing) => CartItem(
          id: existing.id,
          title: existing.title,
          price: existing.price,
          quantity: existing.quantity + 1,
          imageUrl: existing.imageUrl,
          stock: maxStock,
        ),
      );
    } else {
      if (maxStock < 1) return;
      _items.putIfAbsent(
        productId,
            () => CartItem(
          id: productId,
          title: title,
          price: price,
          quantity: 1,
          imageUrl: imageUrl,
          stock: maxStock,
        ),
      );
    }
    notifyListeners();
    saveCartData(); // <--- Lưu ngay sau khi thay đổi
  }

  // Xóa 1 món
  void removeSingleItem(String productId) {
    if (!_items.containsKey(productId)) return;
    if (_items[productId]!.quantity > 1) {
      _items.update(
          productId,
              (existing) => CartItem(
              id: existing.id,
              title: existing.title,
              price: existing.price,
              quantity: existing.quantity - 1,
              imageUrl: existing.imageUrl,
              stock: existing.stock));
    } else {
      _items.remove(productId);
    }
    notifyListeners();
    saveCartData(); // <--- Lưu
  }

  // Xóa hẳn món
  void removeItem(String productId) {
    _items.remove(productId);
    notifyListeners();
    saveCartData(); // <--- Lưu
  }

  // Xóa sạch giỏ (khi đặt hàng xong)
  void clear() {
    _items.clear();
    notifyListeners();
    saveCartData(); // <--- Lưu
  }

  // --- CÁC HÀM LƯU TRỮ ---
  Future<void> saveCartData() async {
    final prefs = await SharedPreferences.getInstance();
    // Chuyển Map _items thành chuỗi JSON
    final String encodedData = json.encode(
      _items.map((key, item) => MapEntry(key, item.toMap())),
    );
    prefs.setString('user_cart', encodedData);
  }

  Future<void> loadCartData() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('user_cart')) return;

    final String? extractedUserData = prefs.getString('user_cart');
    if (extractedUserData == null) return;

    final Map<String, dynamic> decodedData = json.decode(extractedUserData);
    _items = decodedData.map((key, itemData) => MapEntry(key, CartItem.fromMap(itemData)));
    notifyListeners();
  }
}