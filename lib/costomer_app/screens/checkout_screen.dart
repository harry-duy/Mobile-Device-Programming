import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../providers/cart_provider.dart';
import '../../services/address_service.dart';
import '../../models/voucher_model.dart';
import '../../models/address_model.dart'; // <--- QUAN TRỌNG: Đã thêm dòng này để sửa lỗi
import 'address/address_list_screen.dart';
import '../main_customer.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  // --- CẤU HÌNH NGÂN HÀNG ---
  final String myBankId = 'VPBank'; // Viết liền, không dấu cách
  final String myAccountNo = '0937217013';
  final String myAccountName = 'NGO THANH DUY';
  // ---------------------------

  AddressModel? _selectedAddress; // Bây giờ App đã hiểu AddressModel là gì
  String _paymentMethod = 'Tiền mặt (COD)';
  bool _isLoading = false;

  final _voucherController = TextEditingController();
  double _discountAmount = 0;
  String? _appliedVoucherCode;
  String? _appliedVoucherId;

  @override
  void initState() {
    super.initState();
    _loadDefaultAddress();
  }

  void _loadDefaultAddress() async {
    final addressService = AddressService();
    try {
      final addresses = await addressService.getUserAddresses().first;
      if (mounted && addresses.isNotEmpty) {
        setState(() {
          _selectedAddress = addresses.firstWhere((a) => a.isDefault, orElse: () => addresses.first);
        });
      }
    } catch (e) {
      // Bỏ qua lỗi nếu chưa có địa chỉ
    }
  }

  void _checkVoucher(double currentCartTotal) async {
    final code = _voucherController.text.trim().toUpperCase();
    if (code.isEmpty) return;

    setState(() { _discountAmount = 0; _appliedVoucherCode = null; _appliedVoucherId = null; });

    final query = await FirebaseFirestore.instance
        .collection('vouchers')
        .where('code', isEqualTo: code)
        .where('isActive', isEqualTo: true)
        .get();

    if (query.docs.isEmpty) {
      _showSnack("Mã không tồn tại hoặc đã bị khóa!");
      return;
    }

    final voucher = VoucherModel.fromFirestore(query.docs.first);

    if (voucher.usedCount >= voucher.maxUsage) {
      _showSnack("Mã này đã hết lượt sử dụng!");
      return;
    }

    if (currentCartTotal < voucher.minOrderAmount) {
      _showSnack("Đơn hàng phải từ ${voucher.minOrderAmount.toStringAsFixed(0)}đ!");
      return;
    }

    double tempDiscount = 0;
    if (voucher.type == 'percent') {
      tempDiscount = currentCartTotal * (voucher.discountValue / 100);
    } else {
      tempDiscount = voucher.discountValue;
    }

    if (tempDiscount > currentCartTotal) tempDiscount = currentCartTotal;

    setState(() {
      _discountAmount = tempDiscount;
      _appliedVoucherCode = voucher.code;
      _appliedVoucherId = voucher.id;
    });
    _showSnack("Áp dụng thành công! Giảm ${_discountAmount.toStringAsFixed(0)}đ");
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), duration: const Duration(seconds: 2)));
  }

  void _handlePlaceOrder(CartProvider cart) {
    if (_selectedAddress == null) {
      _showSnack('Vui lòng chọn địa chỉ giao hàng!');
      return;
    }
    if (_paymentMethod == 'Chuyển khoản') {
      _showQRDialog(cart);
    } else {
      _placeOrderToFirebase(cart);
    }
  }

  void _placeOrderToFirebase(CartProvider cart) async {
    setState(() => _isLoading = true);
    try {
      final uid = FirebaseAuth.instance.currentUser!.uid;
      final shippingFee = 15000;
      final finalTotal = cart.totalAmount + shippingFee - _discountAmount;

      final orderItems = cart.items.values.map((item) => {
        'id': item.id, 'name': item.title, 'quantity': item.quantity, 'price': item.price, 'image': item.imageUrl,
      }).toList();

      final batch = FirebaseFirestore.instance.batch();

      // 1. Tạo Đơn
      final orderRef = FirebaseFirestore.instance.collection('orders').doc();
      batch.set(orderRef, {
        'userId': uid,
        'items': orderItems,
        'totalPrice': finalTotal > 0 ? finalTotal : 0,
        'originalPrice': cart.totalAmount,
        'shippingFee': shippingFee,
        'discount': _discountAmount,
        'voucherCode': _appliedVoucherCode,
        'address': "${_selectedAddress!.name} - ${_selectedAddress!.phone}\n${_selectedAddress!.detail}",
        'paymentMethod': _paymentMethod,
        'status': 'pending',
        'isRated': false,
        'isPaid': _paymentMethod == 'Chuyển khoản',
        'date': FieldValue.serverTimestamp(),
      });

      // 2. Trừ Kho
      for (var item in cart.items.values) {
        final productRef = FirebaseFirestore.instance.collection('products').doc(item.id);
        batch.update(productRef, {
          'stock': FieldValue.increment(-item.quantity)
        });
      }

      // 3. Trừ Voucher
      if (_appliedVoucherId != null) {
        final voucherRef = FirebaseFirestore.instance.collection('vouchers').doc(_appliedVoucherId);
        batch.update(voucherRef, {'usedCount': FieldValue.increment(1)});
      }

      await batch.commit();

      cart.clear();
      if (!mounted) return;
      _showSuccessDialog();

    } catch (e) {
      _showSnack('Lỗi đặt hàng: $e. Hãy thử xóa giỏ hàng và thêm lại món.');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showQRDialog(CartProvider cart) {
    final shippingFee = 15000;
    final totalAmount = (cart.totalAmount + shippingFee - _discountAmount).toInt();
    final finalAmount = totalAmount > 0 ? totalAmount : 0;

    final qrUrl = 'https://img.vietqr.io/image/$myBankId-$myAccountNo-compact2.png?amount=$finalAmount&addInfo=THANHTOAN&accountName=$myAccountName';

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: const Text("Quét mã thanh toán", textAlign: TextAlign.center),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(border: Border.all(color: Colors.orange), borderRadius: BorderRadius.circular(10)),
              child: Image.network(
                qrUrl, width: 250, height: 250, fit: BoxFit.contain,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return const SizedBox(height: 200, child: Center(child: CircularProgressIndicator()));
                },
                errorBuilder: (context, error, stackTrace) => const Column(
                  children: [
                    Icon(Icons.error, color: Colors.red, size: 50),
                    Text("Lỗi tải mã QR.", textAlign: TextAlign.center),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
            Text("Số tiền: ${finalAmount}đ", style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.orange)),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Hủy", style: TextStyle(color: Colors.grey))),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              _placeOrderToFirebase(cart);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            child: const Text("Đã chuyển khoản", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text('Đặt hàng thành công! 🎉'),
        content: const Text('Cảm ơn bạn đã ủng hộ.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const MainCustomerScreen()),
                    (route) => false,
              );
            },
            child: const Text('Về trang chủ'),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDarkMode ? Colors.grey.shade900 : Colors.white;
    final shippingFee = 15000.0;
    final finalTotal = cart.totalAmount + shippingFee - _discountAmount;

    return Scaffold(
      appBar: AppBar(title: const Text('Xác nhận đơn hàng')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Địa chỉ nhận hàng', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 10),
            Card(
              elevation: 0,
              color: cardColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.orange.withOpacity(0.5))),
              child: ListTile(
                leading: const Icon(Icons.location_on, color: Colors.orange),
                title: Text(_selectedAddress?.name ?? 'Chưa chọn địa chỉ', style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(_selectedAddress != null ? "${_selectedAddress!.phone}\n${_selectedAddress!.detail}" : "Vui lòng bấm để chọn địa chỉ"),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () async {
                  final result = await Navigator.push(context, MaterialPageRoute(builder: (_) => const AddressListScreen()));
                  if (result != null && result is AddressModel) {
                    setState(() => _selectedAddress = result);
                  } else {
                    _loadDefaultAddress();
                  }
                },
              ),
            ),

            const SizedBox(height: 25),

            const Text('Mã ưu đãi', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _voucherController,
                    style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
                    decoration: InputDecoration(
                      hintText: 'Nhập mã (VD: SALE123)',
                      fillColor: cardColor, filled: true,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 15),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () => _checkVoucher(cart.totalAmount),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blueGrey, padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12)),
                  child: const Text("Áp dụng", style: TextStyle(color: Colors.white)),
                )
              ],
            ),
            if (_appliedVoucherCode != null)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle, color: Colors.green, size: 16),
                    const SizedBox(width: 5),
                    Text("Mã: $_appliedVoucherCode (-${_discountAmount.toStringAsFixed(0)}đ)", style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                    const SizedBox(width: 10),
                    InkWell(
                      onTap: () => setState(() { _discountAmount = 0; _appliedVoucherCode = null; _appliedVoucherId = null; _voucherController.clear(); }),
                      child: const Text("Gỡ bỏ", style: TextStyle(color: Colors.red, decoration: TextDecoration.underline, fontSize: 12)),
                    )
                  ],
                ),
              ),

            const SizedBox(height: 25),

            const Text('Phương thức thanh toán', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 10),
            _buildPaymentOption('Tiền mặt (COD)', Icons.money, 'Tiền mặt (COD)'),
            _buildPaymentOption('Chuyển khoản', Icons.qr_code, 'Chuyển khoản'),

            const SizedBox(height: 25),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade800)),
              child: Column(
                children: [
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text('Tổng tiền hàng'), Text('${cart.totalAmount.toStringAsFixed(0)}đ')]),
                  const SizedBox(height: 8),
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text('Phí giao hàng'), Text('${shippingFee.toStringAsFixed(0)}đ')]),
                  if (_discountAmount > 0)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                        const Text('Giảm giá voucher', style: TextStyle(color: Colors.green)),
                        Text('-${_discountAmount.toStringAsFixed(0)}đ', style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                      ]),
                    ),
                  const Divider(height: 20),
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    const Text('THÀNH TIỀN', style: TextStyle(fontWeight: FontWeight.bold)),
                    Text('${(finalTotal > 0 ? finalTotal : 0).toStringAsFixed(0)}đ', style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.w900, fontSize: 18)),
                  ]),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: cardColor, boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: const Offset(0,-5))]),
        child: ElevatedButton(
          onPressed: _isLoading ? null : () => _handlePlaceOrder(cart),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.orange, padding: const EdgeInsets.symmetric(vertical: 15), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
          child: _isLoading
              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
              : const Text("ĐẶT HÀNG NGAY", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }

  Widget _buildPaymentOption(String label, IconData icon, String value) {
    final isSelected = _paymentMethod == value;
    return RadioListTile<String>(
      title: Row(children: [Icon(icon, size: 24, color: isSelected ? Colors.orange : Colors.grey), const SizedBox(width: 10), Text(label)]),
      value: value,
      groupValue: _paymentMethod,
      activeColor: Colors.orange,
      contentPadding: EdgeInsets.zero,
      onChanged: (val) => setState(() => _paymentMethod = val!),
    );
  }
}