import 'package:cloud_firestore/cloud_firestore.dart';

class VoucherModel {
  final String id;
  final String code;
  final double discountValue; // Giá trị giảm (số tiền HOẶC số phần trăm)
  final String type; // 'fixed' (giảm tiền) hoặc 'percent' (giảm %)
  final double minOrderAmount; // Đơn tối thiểu để dùng mã
  final int maxUsage; // Tổng số lượng mã
  final int usedCount; // Số lượng đã dùng
  final bool isActive;

  VoucherModel({
    required this.id,
    required this.code,
    required this.discountValue,
    required this.type,
    required this.minOrderAmount,
    required this.maxUsage,
    required this.usedCount,
    required this.isActive
  });

  factory VoucherModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return VoucherModel(
      id: doc.id,
      code: data['code'] ?? '',
      discountValue: (data['discountValue'] ?? 0).toDouble(),
      type: data['type'] ?? 'fixed',
      minOrderAmount: (data['minOrderAmount'] ?? 0).toDouble(),
      maxUsage: data['maxUsage'] ?? 100,
      usedCount: data['usedCount'] ?? 0,
      isActive: data['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'code': code.toUpperCase(),
      'discountValue': discountValue,
      'type': type,
      'minOrderAmount': minOrderAmount,
      'maxUsage': maxUsage,
      'usedCount': usedCount,
      'isActive': isActive,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }
}