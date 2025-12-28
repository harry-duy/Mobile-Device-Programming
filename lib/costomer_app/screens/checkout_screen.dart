import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../providers/cart_provider.dart';
import '../../services/address_service.dart';
import '../../models/voucher_model.dart'; // Import Model Voucher
import 'address/address_list_screen.dart';
import '../main_customer.dart'; // Import màn hình chính (sửa lại import cho đúng file)

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  // --- CẤU HÌNH NGÂN HÀNG CỦA BẠN ---
  final String myBankId = 'MB';
  final String myAccountNo = '0334966666';
  final String myAccountName = 'NGUYEN VAN A';
  // ----------------------------------

  AddressModel? _selectedAddress;
  String _paymentMethod = 'Tiền mặt (COD)';
  bool _isLoading = false;

  // --- BIẾN CHO VOUCHER ---
  final _voucherController = TextEditingController();
  double _discountAmount = 0; // Số tiền được giảm
  String? _appliedVoucherCode; // Mã voucher đã áp dụng thành công

  @override
  void initState() {
    super.initState();
    _loadDefaultAddress();
  }

  void _loadDefaultAddress() async {
    final addressService = AddressService();
    final addresses = await addressService.getUserAddresses().first;
    if (addresses.isNotEmpty) {
      setState(() {
        _selectedAddress = addresses.firstWhere((a) => a.isDefault, orElse: () => addresses.first);
      });
    }
  }

  // --- HÀM KIỂM TRA MÃ GIẢM GIÁ ---
  void _checkVoucher() async {
    final code = _voucherController.text.trim().toUpperCase();
    if (code.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Vui lòng nhập mã!")));
      return;
    }

    // Tìm mã trong Firestore
    final query = await FirebaseFirestore.instance
        .collection('vouchers')
        .where('code', isEqualTo: code)
        .where('isActive', isEqualTo: true)
        .get();

    if (query.docs.isNotEmpty) {
      final voucher = VoucherModel.fromFirestore(query.docs.first);
      setState(() {
        _discountAmount = voucher.discountAmount;
        _appliedVoucherCode = voucher.code;
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Áp dụng mã thành công! Giảm ${_discountAmount.toStringAsFixed(0)}đ")));
    } else {
      setState(() {
        _discountAmount = 0;
        _appliedVoucherCode = null;
      });
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Mã không hợp lệ hoặc đã hết hạn!")));
    }
  }

  // Hàm xử lý nút Đặt hàng
  void _handlePlaceOrder(CartProvider cart) {
    if (_selectedAddress == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Vui lòng chọn địa chỉ giao hàng!')));
      return;
    }

    if (_paymentMethod == 'Chuyển khoản') {
      _showQRDialog(cart);
    } else {
      _placeOrderToFirebase(cart);
    }
  }

  // Hiển thị QR Code (Số tiền đã trừ giảm giá)
  void _showQRDialog(CartProvider cart) {
    final shippingFee = 15000;
    // TÍNH TỔNG TIỀN SAU KHI GIẢM GIÁ
    final totalAmount = (cart.totalAmount + shippingFee - _discountAmount).toInt();
    // Đảm bảo không âm
    final finalAmount = totalAmount > 0 ? totalAmount : 0;

    final content = "THANH TOAN DON HANG";
    final qrUrl = 'https://img.vietqr.io/image/$myBankId-$myAccountNo-compact2.png?amount=$finalAmount&addInfo=$content&accountName=$myAccountName';

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
                errorBuilder: (context, error, stackTrace) => const Text("Lỗi tải mã QR"),
              ),
            ),
            const SizedBox(height: 10),
            Text("Số tiền: ${finalAmount}đ", style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.orange)),
            Text("Chủ TK: $myAccountName", style: const TextStyle(fontWeight: FontWeight.bold)),
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

  // Lưu đơn hàng lên Firebase
  void _placeOrderToFirebase(CartProvider cart) async {
    setState(() => _isLoading = true);
    try {
      final uid = FirebaseAuth.instance.currentUser!.uid;
      final shippingFee = 15000;
      final finalTotal = cart.totalAmount + shippingFee - _discountAmount;

      final orderItems = cart.items.values.map((item) => {
        'id': item.id, 'name': item.title, 'quantity': item.quantity, 'price': item.price, 'image': item.imageUrl,
      }).toList();

      await FirebaseFirestore.instance.collection('orders').add({
        'userId': uid,
        'items': orderItems,
        'totalPrice': finalTotal > 0 ? finalTotal : 0, // Lưu tổng tiền cuối cùng
        'originalPrice': cart.totalAmount, // Lưu tiền gốc để tham khảo
        'shippingFee': shippingFee,
        'discount': _discountAmount,      // Lưu số tiền giảm
        'voucherCode': _appliedVoucherCode, // Lưu mã voucher
        'address': "${_selectedAddress!.name} - ${_selectedAddress!.phone}\n${_selectedAddress!.detail}",
        'paymentMethod': _paymentMethod,
        'status': 'pending',
        'isPaid': _paymentMethod == 'Chuyển khoản',
        'date': FieldValue.serverTimestamp(),
      });

      cart.clear(); // Xóa giỏ hàng

      if (!mounted) return;

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

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lỗi: $e')));
    } finally {
      setState(() => _isLoading = false);
    }
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
            // 1. ĐỊA CHỈ
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
                  await Navigator.push(context, MaterialPageRoute(builder: (_) => const AddressListScreen()));
                  _loadDefaultAddress();
                },
              ),
            ),

            const SizedBox(height: 25),

            // 2. PHƯƠNG THỨC THANH TOÁN
            const Text('Phương thức thanh toán', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 10),
            _buildPaymentOption('Tiền mặt (COD)', Icons.money, 'Tiền mặt (COD)'),
            _buildPaymentOption('Chuyển khoản', Icons.qr_code, 'Chuyển khoản'),

            const SizedBox(height: 25),

            // 3. MÃ GIẢM GIÁ (VOUCHER)
            const Text('Mã ưu đãi', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _voucherController,
                    style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
                    decoration: InputDecoration(
                      hintText: 'Nhập mã giảm giá (VD: SALE50)',
                      hintStyle: TextStyle(color: Colors.grey),
                      fillColor: cardColor,
                      filled: true,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 15),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: _checkVoucher,
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueGrey,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12)
                  ),
                  child: const Text("Áp dụng", style: TextStyle(color: Colors.white)),
                )
              ],
            ),
            // Hiển thị mã đang dùng
            if (_appliedVoucherCode != null)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle, color: Colors.green, size: 16),
                    const SizedBox(width: 5),
                    Text("Đang dùng mã: $_appliedVoucherCode (-${_discountAmount.toStringAsFixed(0)}đ)", style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                    const SizedBox(width: 10),
                    InkWell(
                      onTap: () {
                        setState(() { _discountAmount = 0; _appliedVoucherCode = null; _voucherController.clear(); });
                      },
                      child: const Text("Gỡ bỏ", style: TextStyle(color: Colors.red, decoration: TextDecoration.underline, fontSize: 12)),
                    )
                  ],
                ),
              ),

            const SizedBox(height: 25),

            // 4. TÓM TẮT ĐƠN HÀNG
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade800),
              ),
              child: Column(
                children: [
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text('Tổng tiền hàng'), Text('${cart.totalAmount.toStringAsFixed(0)}đ')]),
                  const SizedBox(height: 8),
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text('Phí giao hàng'), Text('${shippingFee.toStringAsFixed(0)}đ')]),

                  // Dòng giảm giá
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
        decoration: BoxDecoration(
          color: cardColor,
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: const Offset(0,-5))],
        ),
        child: ElevatedButton(
          onPressed: _isLoading ? null : () => _handlePlaceOrder(cart),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.orange,
            padding: const EdgeInsets.symmetric(vertical: 15),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
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