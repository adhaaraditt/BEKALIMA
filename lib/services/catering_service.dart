import 'package:flutter/material.dart';
import '../data/sample_data.dart';
import '../models/cart_item.dart';
import '../models/category_item.dart';
import '../models/menu_item.dart';
import '../models/order_item.dart';
import '../models/review_item.dart';
import '../models/user_account.dart';
import 'sheets_service.dart';

class CateringService extends ChangeNotifier {
  static final CateringService _instance = CateringService._internal();
  factory CateringService() => _instance;

  CateringService._internal();

  final List<CategoryItem> _categories = SampleData.categories;
  final List<MenuItem> _menus = List.from(SampleData.menuItems);
  String _selectedCategoryId = 'all';
  String _searchQuery = '';

  List<CategoryItem> get categories => _categories;
  List<MenuItem> get menus => _menus;
  String get selectedCategoryId => _selectedCategoryId;
  String get searchQuery => _searchQuery;

  List<MenuItem> get filteredMenus {
    return _menus.where((item) {
      final matchesCategory =
          _selectedCategoryId == 'all' ||
          item.categoryId == _selectedCategoryId;
      final matchesSearch =
          _searchQuery.trim().isEmpty ||
          item.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          item.description.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesCategory && matchesSearch;
    }).toList();
  }

  void selectCategory(String categoryId) {
    _selectedCategoryId = categoryId;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  final List<CartItem> _cartItems = [];

  List<CartItem> get cartItems => List.unmodifiable(_cartItems);

  int get cartItemCount =>
      _cartItems.fold(0, (sum, item) => sum + item.quantity);

  int get cartTotalPrice =>
      _cartItems.fold(0, (sum, item) => sum + item.subtotal);

  void addToCart(MenuItem menu, int quantity, {String? note}) {
    final existingIndex = _cartItems.indexWhere(
      (item) => item.menu.id == menu.id,
    );
    if (existingIndex >= 0) {
      _cartItems[existingIndex].quantity += quantity;
      if (note != null && note.isNotEmpty) {
        _cartItems[existingIndex].specialNote = note;
      }
    } else {
      _cartItems.add(
        CartItem(menu: menu, quantity: quantity, specialNote: note),
      );
    }
    notifyListeners();
  }

  void updateQuantity(String menuId, int newQuantity) {
    final index = _cartItems.indexWhere((item) => item.menu.id == menuId);
    if (index >= 0) {
      if (newQuantity <= 0) {
        _cartItems.removeAt(index);
      } else {
        _cartItems[index].quantity = newQuantity;
      }
      notifyListeners();
    }
  }

  void removeFromCart(String menuId) {
    _cartItems.removeWhere((item) => item.menu.id == menuId);
    notifyListeners();
  }

  void clearCart() {
    _cartItems.clear();
    notifyListeners();
  }

  final Map<String, List<OrderItem>> _ordersByUser = {};
  String _orderOwnerKey = '';
  int _orderSequence = 0;

  List<OrderItem> get orders =>
      List.unmodifiable(_ordersByUser[_orderOwnerKey] ?? const <OrderItem>[]);

  OrderItem createOrder({
    required String recipientName,
    required String recipientPhone,
    required String deliveryAddress,
    String? eventDate,
    String? eventTime,
    required String paymentMethod,
    String? notes,
  }) {
    final now = DateTime.now();
    final eta = now.add(const Duration(hours: 1));
    final etaStr =
        '${eta.hour.toString().padLeft(2, '0')}:${eta.minute.toString().padLeft(2, '0')} WIB';
    final userOrders = _ordersByUser.putIfAbsent(_orderOwnerKey, () => []);
    final orderId =
        'BKL-${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}-${now.millisecondsSinceEpoch}${_orderSequence++}';

    final newOrder = OrderItem(
      id: orderId,
      orderDate: now,
      eventDate: eventDate ?? 'Hari ini',
      eventTime: eventTime ?? '1 Jam (estimasi tiba ~$etaStr)',
      recipientName: recipientName,
      recipientPhone: recipientPhone,
      deliveryAddress: deliveryAddress,
      paymentMethod: paymentMethod,
      status: OrderStatus.waitingPayment,
      items: List.from(_cartItems),
      totalPrice: cartTotalPrice,
      notes: notes,
    );

    userOrders.insert(0, newOrder);
    _cartItems.clear();
    notifyListeners();

    SheetsService.instance.sendOrder(newOrder);

    return newOrder;
  }

  void cancelOrder(String orderId) {
    final userOrders = _ordersByUser[_orderOwnerKey];
    if (userOrders == null) return;

    final index = userOrders.indexWhere((o) => o.id == orderId);
    if (index >= 0 && userOrders[index].canBeCancelled) {
      userOrders[index].status = OrderStatus.cancelled;
      notifyListeners();
      SheetsService.instance.updateOrderStatus(
        orderId,
        OrderStatus.cancelled.label,
      );
    }
  }

  void confirmPayment(String orderId) {
    final userOrders = _ordersByUser[_orderOwnerKey];
    if (userOrders == null) return;

    final index = userOrders.indexWhere((o) => o.id == orderId);
    if (index >= 0) {
      userOrders[index].status = OrderStatus.paid;
      notifyListeners();
      SheetsService.instance.updateOrderStatus(orderId, OrderStatus.paid.label);
    }
  }

  OrderItem? _findOrder(String orderId) {
    final userOrders = _ordersByUser[_orderOwnerKey];
    if (userOrders == null) return null;

    final index = userOrders.indexWhere((o) => o.id == orderId);
    return index >= 0 ? userOrders[index] : null;
  }

  void updateOrderItemQuantity(String orderId, String menuId, int quantity) {
    final order = _findOrder(orderId);
    if (order == null || !order.canBeEdited) return;

    final index = order.items.indexWhere((item) => item.menu.id == menuId);
    if (index < 0) return;

    if (quantity <= 0) {
      if (order.items.length == 1) return;
      order.items.removeAt(index);
    } else {
      order.items[index].quantity = quantity;
    }
    _saveOrderItems(order);
  }

  void addOrderItem(String orderId, MenuItem menu, {int quantity = 1}) {
    final order = _findOrder(orderId);
    if (order == null || !order.canBeEdited) return;

    final index = order.items.indexWhere((item) => item.menu.id == menu.id);
    if (index >= 0) {
      order.items[index].quantity += quantity;
    } else {
      order.items.add(CartItem(menu: menu, quantity: quantity));
    }
    _saveOrderItems(order);
  }

  void _saveOrderItems(OrderItem order) {
    order.totalPrice = order.items.fold(0, (sum, item) => sum + item.subtotal);
    notifyListeners();
    SheetsService.instance.updateOrderItems(order);
  }

  void reorder(OrderItem previousOrder) {
    for (final item in previousOrder.items) {
      addToCart(item.menu, item.quantity, note: item.specialNote);
    }
  }

  Future<void> syncOrderStatuses() async {
    final statuses = await SheetsService.instance.fetchOrderStatuses();
    if (statuses.isEmpty) return;

    var changed = false;
    for (final userOrders in _ordersByUser.values) {
      for (final order in userOrders) {
        final label = statuses[order.id];
        if (label == null) continue;

        final status = OrderStatus.values.firstWhere(
          (value) => value.label == label,
          orElse: () => order.status,
        );
        if (status != order.status) {
          order.status = status;
          changed = true;
        }
      }
    }

    if (changed) notifyListeners();
  }

  final List<ReviewItem> _reviews = List.from(SampleData.initialReviews);
  List<ReviewItem> get reviews => _reviews;

  List<ReviewItem> getReviewsForMenu(String menuId) {
    return _reviews.where((r) => r.menuId == menuId).toList();
  }

  void addReview({
    required String orderId,
    required String menuId,
    required double rating,
    required String comment,
    required String userName,
  }) {
    final newReview = ReviewItem(
      id: 'rev_${DateTime.now().millisecondsSinceEpoch}',
      menuId: menuId,
      userName: userName,
      rating: rating,
      comment: comment,
      date: DateTime.now(),
    );

    _reviews.insert(0, newReview);

    final userOrders = _ordersByUser[_orderOwnerKey];
    final orderIndex = userOrders?.indexWhere((o) => o.id == orderId) ?? -1;
    if (orderIndex >= 0) {
      userOrders![orderIndex].review = newReview;
    }

    notifyListeners();
  }

  String userName = '';
  String userEmail = '';
  String userPhone = '';
  String password = '';
  bool isLoggedIn = false;
  final List<UserAccount> _registeredUsers = [];

  List<UserAccount> get registeredUsers => List.unmodifiable(_registeredUsers);

  bool isUserRegistered(String usernameOrEmail) {
    final query = usernameOrEmail.trim().toLowerCase();
    return _registeredUsers.any(
      (u) =>
          u.username.toLowerCase() == query || u.email.toLowerCase() == query,
    );
  }

  List<String> savedAddresses = [
    'Jl. Merpati No. 12, Kebayoran Baru, Jakarta Selatan (Rumah)',
    'Gedung Cyber 2 Tower Lt. 15, Jl. H.R. Rasuna Said, Kuningan (Kantor)',
  ];
  int selectedAddressIndex = 0;

  String get currentAddress => savedAddresses.isNotEmpty
      ? savedAddresses[selectedAddressIndex]
      : 'Belum ada alamat tersimpan';

  void updateProfile({
    required String name,
    required String phone,
    required String email,
  }) {
    userName = name;
    userPhone = phone;
    userEmail = email;
    notifyListeners();
  }

  String? changePassword({
    required String currentPassword,
    required String newPassword,
  }) {
    if (currentPassword != password) {
      return 'Password lama tidak sesuai.';
    }
    if (newPassword.length < 6) {
      return 'Password baru minimal 6 karakter.';
    }
    password = newPassword;
    notifyListeners();
    return null;
  }

  Future<bool> login({
    required String usernameOrEmail,
    String? password,
  }) async {
    final query = usernameOrEmail.trim().toLowerCase();

    UserAccount? user = _registeredUsers.cast<UserAccount?>().firstWhere((u) {
      final matchesIdentity =
          u!.username.toLowerCase() == query || u.email.toLowerCase() == query;
      if (password == null) return matchesIdentity;
      return matchesIdentity && u.password == password;
    }, orElse: () => null);

    if (user == null && password != null) {
      user = await SheetsService.instance.loginUser(
        usernameOrEmail: usernameOrEmail,
        password: password,
      );
    }

    if (user == null) {
      return false;
    }

    userName = user.name;
    userEmail = user.email;
    userPhone = user.phone;
    this.password = user.password;
    _orderOwnerKey = user.username.trim().toLowerCase();
    isLoggedIn = true;
    notifyListeners();
    return true;
  }

  bool register({
    required String email,
    required String username,
    required String phone,
    String password = '',
  }) {
    final cleanUsername = username.trim();
    final cleanEmail = email.trim();
    final cleanPhone = phone.trim();

    if (isUserRegistered(cleanUsername) || isUserRegistered(cleanEmail)) {
      return false;
    }

    final newUser = UserAccount(
      username: cleanUsername,
      name: cleanUsername,
      email: cleanEmail,
      phone: cleanPhone,
      password: password,
    );

    _registeredUsers.add(newUser);
    userName = newUser.name;
    userEmail = newUser.email;
    userPhone = newUser.phone;
    this.password = newUser.password;
    _orderOwnerKey = newUser.username.trim().toLowerCase();
    isLoggedIn = true;
    notifyListeners();

    SheetsService.instance.registerUser(
      name: newUser.name,
      email: newUser.email,
      phone: newUser.phone,
      password: password,
    );

    return true;
  }

  void addAddress(String address) {
    savedAddresses.add(address);
    notifyListeners();
  }

  void updateAddress(int index, String address) {
    if (index < 0 || index >= savedAddresses.length) return;
    final clean = address.trim();
    if (clean.isEmpty) return;
    savedAddresses[index] = clean;
    notifyListeners();
  }

  void removeAddress(int index) {
    if (index < 0 || index >= savedAddresses.length) return;
    savedAddresses.removeAt(index);
    if (selectedAddressIndex > index) {
      selectedAddressIndex--;
    } else if (selectedAddressIndex >= savedAddresses.length) {
      selectedAddressIndex = savedAddresses.isEmpty
          ? 0
          : savedAddresses.length - 1;
    }
    notifyListeners();
  }

  void selectAddress(int index) {
    if (index >= 0 && index < savedAddresses.length) {
      selectedAddressIndex = index;
      notifyListeners();
    }
  }
}