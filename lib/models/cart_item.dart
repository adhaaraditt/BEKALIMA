import 'menu_item.dart';

class CartItem {
  final MenuItem menu;
  int quantity;
  String? specialNote;

  CartItem({
    required this.menu,
    required this.quantity,
    this.specialNote,
  });

  int get subtotal => menu.price * quantity;
}
