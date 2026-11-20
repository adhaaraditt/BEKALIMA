import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/order_item.dart';
import '../models/user_account.dart';

class SheetsService {
  SheetsService._();
  static final SheetsService instance = SheetsService._();

  String scriptUrl =
      'https://script.google.com/macros/s/AKfycbwJ5KDQb5zQ9RXQzQhVZ_5JV0FHeB0-Z_g81638HI9r8iJ36X0fl5PgYDc5ukatIt1J8g/exec';

  bool get isConfigured => scriptUrl.trim().isNotEmpty;

  Future<bool> registerUser({
    required String name,
    required String email,
    required String phone,
    String? password,
  }) async {
    if (!isConfigured) return true;

    try {
      final response = await http.post(
        Uri.parse(scriptUrl),
        headers: {'Content-Type': 'text/plain'},
        body: jsonEncode({
          'action': 'saveUser',
          'user': {
            'name': name,
            'phone': phone,
            'email': email,
            'password': password ?? '',
          },
        }),
      );
      return response.statusCode == 200 || response.statusCode == 302;
    } catch (e) {
      debugPrint('SheetsService.registerUser error: $e');
      return false;
    }
  }

  Future<UserAccount?> loginUser({
    required String usernameOrEmail,
    required String password,
  }) async {
    if (!isConfigured) return null;

    try {
      final response = await http
          .post(
            Uri.parse(scriptUrl),
            headers: {'Content-Type': 'text/plain'},
            body: jsonEncode({
              'action': 'login',
              'username': usernameOrEmail,
              'password': password,
            }),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode != 200 && response.statusCode != 302) {
        return null;
      }

      final data = jsonDecode(response.body);
      if (data is! Map || data['status'] != 'ok' || data['user'] is! Map) {
        return null;
      }

      final user = data['user'] as Map;
      final name = (user['name'] ?? usernameOrEmail).toString();
      return UserAccount(
        username: name,
        name: name,
        email: (user['email'] ?? '').toString(),
        phone: (user['phone'] ?? '').toString(),
        password: password,
      );
    } catch (e) {
      debugPrint('SheetsService.loginUser error: $e');
      return null;
    }
  }


  Future<Map<String, String>> fetchOrderStatuses() async {
    if (!isConfigured) return const {};

    try {
      final response = await http
          .post(
            Uri.parse(scriptUrl),
            headers: {'Content-Type': 'text/plain'},
            body: jsonEncode({'action': 'getOrderStatuses'}),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode != 200 && response.statusCode != 302) {
        return const {};
      }

      final data = jsonDecode(response.body);
      if (data is! Map || data['status'] != 'ok' || data['orders'] is! List) {
        return const {};
      }

      return {
        for (final row in data['orders'] as List)
          if (row is Map && row['id'] != null)
            row['id'].toString(): (row['status'] ?? '').toString(),
      };
    } catch (e) {
      debugPrint('SheetsService.fetchOrderStatuses error: $e');
      return const {};
    }
  }

  Future<bool> sendOrder(OrderItem order) async {
    if (!isConfigured) return true;

    try {
      final itemsSummary = order.items
          .map((i) => '${i.menu.name} x${i.quantity}')
          .join(', ');

      final response = await http.post(
        Uri.parse(scriptUrl),
        headers: {'Content-Type': 'text/plain'},
        body: jsonEncode({
          'action': 'createOrder',
          'order': {
            'id': order.id,
            'orderDate':
                '${order.orderDate.day}/${order.orderDate.month}/${order.orderDate.year}',
            'eventTime': order.eventTime,
            'recipientName': order.recipientName,
            'recipientPhone': order.recipientPhone,
            'deliveryAddress': order.deliveryAddress,
            'paymentMethod': order.paymentMethod,
            'status': order.status.label,
            'totalPrice': order.totalPrice,
            'itemsSummary': itemsSummary,
            'notes': order.notes ?? '-',
          },
        }),
      );
      return response.statusCode == 200 || response.statusCode == 302;
    } catch (e) {
      debugPrint('SheetsService.sendOrder error: $e');
      return false;
    }
  }

  Future<bool> updateOrderItems(OrderItem order) async {
    if (!isConfigured) return true;

    try {
      final itemsSummary = order.items
          .map((i) => '${i.menu.name} x${i.quantity}')
          .join(', ');

      final response = await http.post(
        Uri.parse(scriptUrl),
        headers: {'Content-Type': 'text/plain'},
        body: jsonEncode({
          'action': 'updateOrderItems',
          'orderId': order.id,
          'itemsSummary': itemsSummary,
          'totalPrice': order.totalPrice,
        }),
      );
      return response.statusCode == 200 || response.statusCode == 302;
    } catch (e) {
      debugPrint('SheetsService.updateOrderItems error: $e');
      return false;
    }
  }

  Future<bool> updateOrderStatus(String orderId, String newStatus) async {
    if (!isConfigured) return true;

    try {
      final response = await http.post(
        Uri.parse(scriptUrl),
        headers: {'Content-Type': 'text/plain'},
        body: jsonEncode({
          'action': 'updateOrderStatus',
          'orderId': orderId,
          'status': newStatus,
        }),
      );
      return response.statusCode == 200 || response.statusCode == 302;
    } catch (e) {
      debugPrint('SheetsService.updateOrderStatus error: $e');
      return false;
    }
  }
}