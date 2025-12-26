import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

enum OrderStatus {
  pending,        // Chờ xác nhận
  accepted,       // Đã xác nhận

=======
  preparing,      // Đang chuẩn bị
  readyToShip,    // Sẵn sàng giao

  shipping,       // Đang giao
  delivered,      // Đã giao hàng
  completed,      // Hoàn thành
  cancelled       // Đã hủy
}

extension OrderStatusExtension on OrderStatus {
  String get displayName {
    switch (this) {
      case OrderStatus.pending: return 'Chờ xác nhận';
      case OrderStatus.accepted: return 'Đã xác nhận';
      case OrderStatus.preparing: return 'Đang chuẩn bị';
      case OrderStatus.readyToShip: return 'Sẵn sàng giao';
      case OrderStatus.shipping: return 'Đang giao';
      case OrderStatus.delivered: return 'Đã giao hàng';
      case OrderStatus.completed: return 'Hoàn thành';
      case OrderStatus.cancelled: return 'Đã hủy';
    }
  }

  Color get color {
    switch (this) {
      case OrderStatus.pending: return Colors.orange;
      case OrderStatus.accepted: return Colors.blue;



      case OrderStatus.preparing: return Colors.indigo;
      case OrderStatus.readyToShip: return Colors.cyan;

      case OrderStatus.shipping: return Colors.purple;
      case OrderStatus.delivered: return Colors.green;
      case OrderStatus.completed: return Colors.grey;
      case OrderStatus.cancelled: return Colors.red;
    }
  }
}

class Product {
  final String id;
  final String name;
  final double price;
  final String description;
  final String imageUrl;
  final bool isAvailable;

  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.description,
    required this.imageUrl,
    this.isAvailable = true,
  });

  factory Product.fromFirestore(Map<String, dynamic> data, String id) {
    return Product(
      id: id,
      name: data['name'] ?? '',
      price: (data['price'] ?? 0).toDouble(),
      description: data['description'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      isAvailable: data['isAvailable'] ?? true,

    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'price': price,
      'description': description,
      'imageUrl': imageUrl,
      'isAvailable': isAvailable,
    };
  }
}

class ShipperInfo {
  final String id;
  final String name;
  final String phone;
  final String vehicleNumber;

  ShipperInfo({
    required this.id,
    required this.name,
    required this.phone,
    required this.vehicleNumber,
  });

  factory ShipperInfo.fromMap(Map<String, dynamic>? data) {
    if (data == null) return ShipperInfo.empty();

    return ShipperInfo(
      id: data['id'] ?? '',
      name: data['name'] ?? '',
      phone: data['phone'] ?? '',
      vehicleNumber: data['vehicleNumber'] ?? '',

    );
  }

  Map<String, dynamic> toMap() {
    return {


      'name': name,
      'price': price,
      'description': description,
      'imageUrl': imageUrl,
      'isAvailable': isAvailable,
    };
  }
}

class ShipperInfo {
  final String id;
  final String name;
  final String phone;
  final String vehicleNumber;

  ShipperInfo({
    required this.id,
    required this.name,
    required this.phone,
    required this.vehicleNumber,
  });

  factory ShipperInfo.fromMap(Map<String, dynamic>? data) {
    if (data == null) return ShipperInfo.empty();

    return ShipperInfo(
      id: data['id'] ?? '',
      name: data['name'] ?? '',
      phone: data['phone'] ?? '',
      vehicleNumber: data['vehicleNumber'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {

      'id': id,
      'name': name,
      'phone': phone,
      'vehicleNumber': vehicleNumber,
    };
  }

  factory ShipperInfo.empty() {
    return ShipperInfo(
      id: '',
      name: '',
      phone: '',
      vehicleNumber: '',
    );
  }

  bool get isEmpty => id.isEmpty;
}

class OrderModel {
  final String id;
  final String userId;
  final String customerName;
  final String customerPhone;
  final List<dynamic> items;
  final double totalAmount;
  final OrderStatus status;
  final DateTime orderDate;
  final String deliveryAddress;
  final String? notes;
  final ShipperInfo? shipperInfo;
  final DateTime? deliveredAt;
  final DateTime? completedAt;

  OrderModel({
    required this.id,
    required this.userId,
    required this.customerName,
    required this.customerPhone,
    required this.items,
    required this.totalAmount,
    required this.status,
    required this.orderDate,
    required this.deliveryAddress,
    this.notes,
    this.shipperInfo,
    this.deliveredAt,
    this.completedAt,
  });

  factory OrderModel.fromFirestore(Map<String, dynamic> data, String id) {
    return OrderModel(
      id: id,
      userId: data['userId'] ?? '',
      customerName: data['customerName'] ?? '',
      customerPhone: data['customerPhone'] ?? '',
      items: data['items'] ?? [],
      totalAmount: (data['totalAmount'] ?? 0).toDouble(),
      status: OrderStatus.values.firstWhere(
            (e) => e.toString().split('.').last == (data['status'] ?? 'pending'),
        orElse: () => OrderStatus.pending,
      ),
      orderDate: (data['orderDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      deliveryAddress: data['deliveryAddress'] ?? '',
      notes: data['notes'],
      shipperInfo: ShipperInfo.fromMap(data['shipperInfo']),
      deliveredAt: (data['deliveredAt'] as Timestamp?)?.toDate(),
      completedAt: (data['completedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'customerName': customerName,
      'customerPhone': customerPhone,
      'items': items,
      'totalAmount': totalAmount,
      'status': status.name,
      'orderDate': Timestamp.fromDate(orderDate),
      'deliveryAddress': deliveryAddress,
      'notes': notes,
      'shipperInfo': shipperInfo?.toMap(),
      'deliveredAt': deliveredAt != null ? Timestamp.fromDate(deliveredAt!) : null,
      'completedAt': completedAt != null ? Timestamp.fromDate(completedAt!) : null,
    };
  }

  // Tính tổng số món
  int get totalItems {
    return items.fold(0, (sum, item) => sum + (item['quantity'] as int));
  }
}