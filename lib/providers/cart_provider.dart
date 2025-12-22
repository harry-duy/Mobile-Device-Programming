import 'package:flutter/foundation.dart';
import '../models/models.dart';

class CartItem {
  final Product product;
  int quantity;

  CartItem({required this.product, this.quantity = 1});

  double get totalPrice => product.price * quantity;
}

class CartProvider extends ChangeNotifier {
  final Map<String, CartItem> _items = {};

  Map<String, CartItem> get items => {..._items};

  int get itemCount => _items.length;

  int get totalQuantity {
    return _items.values.fold(0, (sum, item) => sum + item.quantity);
  }

  double get totalAmount {
    return _items.values.fold(0.0, (sum, item) => sum + item.totalPrice);
  }

  bool isInCart(String productId) {
    return _items.containsKey(productId);
  }

  void addItem(Product product, {int quantity = 1}) {
    if (_items.containsKey(product.id)) {
      // Nếu đã có trong giỏ, tăng số lượng
      _items[product.id]!.quantity += quantity;
    } else {
      // Thêm mới vào giỏ
      _items[product.id] = CartItem(product: product, quantity: quantity);
    }
    notifyListeners();
  }

  void removeItem(String productId) {
    _items.remove(productId);
    notifyListeners();
  }

  void updateQuantity(String productId, int newQuantity) {
    if (!_items.containsKey(productId)) return;

    if (newQuantity <= 0) {
      removeItem(productId);
    } else {
      _items[productId]!.quantity = newQuantity;
      notifyListeners();
    }
  }

  void increaseQuantity(String productId) {
    if (_items.containsKey(productId)) {
      _items[productId]!.quantity++;
      notifyListeners();
    }
  }

  void decreaseQuantity(String productId) {
    if (!_items.containsKey(productId)) return;

    if (_items[productId]!.quantity > 1) {
      _items[productId]!.quantity--;
    } else {
      removeItem(productId);
    }
    notifyListeners();
  }

  void clear() {
    _items.clear();
    notifyListeners();
  }

  // Convert cart items cho Firebase
  List<Map<String, dynamic>> getCartItemsForOrder() {
    return _items.values.map((item) {
      return {
        'id': item.product.id,
        'name': item.product.name,
        'price': item.product.price,
        'quantity': item.quantity,
      };
    }).toList();
  }
}