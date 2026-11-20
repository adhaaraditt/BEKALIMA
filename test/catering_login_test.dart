import 'package:flutter_test/flutter_test.dart';

import 'package:bekalima/data/sample_data.dart';
import 'package:bekalima/models/order_item.dart';
import 'package:bekalima/services/catering_service.dart';
import 'package:bekalima/services/sheets_service.dart';

void main() {
  setUp(() {
    SheetsService.instance.scriptUrl = '';
  });

  test(
    'login memakai akun yang terdaftar dan menolak password salah',
    () async {
      final service = CateringService();
      service.register(
        email: 'login.test@bekalima.com',
        username: 'Login Test',
        phone: '081234567890',
        password: 'Bekalima123!',
      );

      expect(
        await service.login(
          usernameOrEmail: 'Login Test',
          password: 'Bekalima123!',
        ),
        isTrue,
      );
      expect(
        await service.login(
          usernameOrEmail: 'login.test@bekalima.com',
          password: 'Salah123!',
        ),
        isFalse,
      );
    },
  );

  test('riwayat pesanan terpisah per akun', () async {
    final service = CateringService();

    service.register(
      email: 'akun.a@bekalima.com',
      username: 'Akun A',
      phone: '0811',
      password: 'AkunA123!',
    );
    expect(service.orders, isEmpty);

    service.createOrder(
      recipientName: 'Akun A',
      recipientPhone: '0811',
      deliveryAddress: 'Jl. A',
      paymentMethod: 'QRIS',
    );
    expect(service.orders, hasLength(1));
    final orderA = service.orders.single.id;

    service.register(
      email: 'akun.b@bekalima.com',
      username: 'Akun B',
      phone: '0822',
      password: 'AkunB123!',
    );
    expect(service.orders, isEmpty);

    service.createOrder(
      recipientName: 'Akun B',
      recipientPhone: '0822',
      deliveryAddress: 'Jl. B',
      paymentMethod: 'QRIS',
    );
    expect(service.orders.single.id, isNot(orderA));

    await service.login(
      usernameOrEmail: 'akun.a@bekalima.com',
      password: 'AkunA123!',
    );
    expect(service.orders.single.id, orderA);
  });

  test(
    'menu bisa diedit saat menunggu pembayaran, terkunci setelah terbayar',
    () {
      final service = CateringService();
      service.register(
        email: 'edit.order@bekalima.com',
        username: 'Edit Order',
        phone: '0833',
        password: 'Edit123!',
      );

      final first = SampleData.menuItems[0];
      final second = SampleData.menuItems[1];
      service.addToCart(first, 2);
      final order = service.createOrder(
        recipientName: 'Edit Order',
        recipientPhone: '0833',
        deliveryAddress: 'Jl. Edit',
        paymentMethod: 'QRIS',
      );

      expect(order.totalPrice, first.price * 2);

      service.addOrderItem(order.id, second);
      service.updateOrderItemQuantity(order.id, first.id, 4);
      expect(order.items, hasLength(2));
      expect(order.totalPrice, first.price * 4 + second.price);

      service.confirmPayment(order.id);
      expect(order.status, OrderStatus.paid);
      expect(order.canBeEdited, isFalse);

      service.updateOrderItemQuantity(order.id, first.id, 1);
      expect(order.items.first.quantity, 4);
    },
  );
}