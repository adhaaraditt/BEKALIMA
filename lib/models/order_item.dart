import 'cart_item.dart';
import 'review_item.dart';

enum OrderStatus {
  waitingPayment('Menunggu Pembayaran'),
  processing('Diproses'),
  shipped('Dikirim'),
  completed('Selesai'),
  cancelled('Dibatalkan');

  final String label;
  const OrderStatus(this.label);
}

class OrderItem {
  final String id;
  final DateTime orderDate;
  final String eventDate;
  final String eventTime;
  final String recipientName;
  final String recipientPhone;
  final String deliveryAddress;
  final String paymentMethod;
  OrderStatus status;
  final List<CartItem> items;
  final int totalPrice;
  final String? notes;
  ReviewItem? review;

  OrderItem({
    required this.id,
    required this.orderDate,
    required this.eventDate,
    required this.eventTime,
    required this.recipientName,
    required this.recipientPhone,
    required this.deliveryAddress,
    required this.paymentMethod,
    required this.status,
    required this.items,
    required this.totalPrice,
    this.notes,
    this.review,
  });

  bool get canBeCancelled => status == OrderStatus.waitingPayment;
  bool get canBeReviewed => status == OrderStatus.completed && review == null;
}