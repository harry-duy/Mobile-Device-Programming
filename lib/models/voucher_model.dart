import 'package:cloud_firestore/cloud_firestore.dart';

class VoucherModel {
  final String id;
  final String code; // Ví dụ: SALE50
  final double discountAmount; // Số tiền giảm (VD: 50000)
  final bool isActive; // Còn hạn hay không

  VoucherModel({required this.id, required this.code, required this.discountAmount, required this.isActive});

  factory VoucherModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return VoucherModel(
      id: doc.id,
      code: data['code'] ?? '',
      discountAmount: (data['discountAmount'] ?? 0).toDouble(),
      isActive: data['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'code': code.toUpperCase(), // Luôn lưu chữ in hoa
      'discountAmount': discountAmount,
      'isActive': isActive,
    };
  }
}