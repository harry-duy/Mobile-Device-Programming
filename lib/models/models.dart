import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

enum OrderStatus { pending, accepted, shipping, delivered, completed, cancelled }

extension OrderStatusExtension on OrderStatus {
  String get displayName {
    switch (this) {
      case OrderStatus.pending: return 'Chờ xác nhận';
      case OrderStatus.accepted: return 'Đã xác nhận';
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

  Product({required this.id, required this.name, required this.price, required this.description, required this.imageUrl});

  factory Product.fromFirestore(Map<String, dynamic> data, String id) {
    return Product(
      id: id,
      name: data['name'] ?? '',
      price: (data['price'] ?? 0).toDouble(),
      description: data['description'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
    );
  }
}

class OrderModel {
  final String id;
  final String customerName;
  final List<dynamic> items;
  final double totalAmount;
  final OrderStatus status;
  final DateTime orderDate;
  final String deliveryAddress;

  OrderModel({
    required this.id, required this.customerName, required this.items,
    required this.totalAmount, required this.status, required this.orderDate, required this.deliveryAddress
  });

  factory OrderModel.fromFirestore(Map<String, dynamic> data, String id) {
    return OrderModel(
      id: id,
      customerName: data['customerName'] ?? '',
      items: data['items'] ?? [],
      totalAmount: (data['totalAmount'] ?? 0).toDouble(),
      status: OrderStatus.values.firstWhere(
            (e) => e.toString().split('.').last == (data['status'] ?? 'pending'),
        orElse: () => OrderStatus.pending,
      ),
      orderDate: (data['orderDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      deliveryAddress: data['deliveryAddress'] ?? '',
    );
  }
}