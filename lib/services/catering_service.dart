import 'package:flutter/material.dart';
import '../data/sample_data.dart';
import '../models/cart_item.dart';
import '../models/category_item.dart';
import '../models/menu_item.dart';
import '../models/order_item.dart';
import '../models/review_item.dart';

class CateringService extends ChangeNotifier {
  static final CateringService _instance = CateringService._internal();
  factory CateringService() => _instance;

  CateringService._internal() {
    _initSampleOrders();
  }

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
      final matchesCategory = _selectedCategoryId == 'all' || item.categoryId == _selectedCategoryId;
      final matchesSearch = _searchQuery.trim().isEmpty ||
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

  int get cartItemCount => _cartItems.fold(0, (sum, item) => sum + item.quantity);

  int get cartTotalPrice => _cartItems.fold(0, (sum, item) => sum + item.subtotal);

  void addToCart(MenuItem menu, int quantity, {String? note}) {
    final existingIndex = _cartItems.indexWhere((item) => item.menu.id == menu.id);
    if (existingIndex >= 0) {
      _cartItems[existingIndex].quantity += quantity;
      if (note != null && note.isNotEmpty) {
        _cartItems[existingIndex].specialNote = note;
      }
    } else {
      _cartItems.add(CartItem(
        menu: menu,
        quantity: quantity,
        specialNote: note,
      ));
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

  // --- Pesanan ---
  final List<OrderItem> _orders = [];
  List<OrderItem> get orders => List.unmodifiable(_orders);

  void _initSampleOrders() {
    _orders.add(
      OrderItem(
        id: 'BKL-20261025-01',
        orderDate: DateTime.now().subtract(const Duration(days: 1)),
        eventDate: '28 Oktober 2026',
        eventTime: '11:30 WIB',
        recipientName: 'Raditya Pratama',
        recipientPhone: '081234567890',
        deliveryAddress: 'Jl. Merpati No. 12, Kebayoran Baru, Jakarta Selatan',
        paymentMethod: 'Transfer Virtual Account BCA',
        status: OrderStatus.waitingPayment,
        items: [
          CartItem(
            menu: SampleData.menuItems[0],
            quantity: 25,
            specialNote: 'Mohon pisahkan sambalnya dalam wadah khusus.',
          ),
        ],
        totalPrice: SampleData.menuItems[0].price * 25,
        notes: 'Pintu gerbang hitam samping pos satpam.',
      ),
    );

    _orders.add(
      OrderItem(
        id: 'BKL-20261020-04',
        orderDate: DateTime.now().subtract(const Duration(days: 6)),
        eventDate: '21 Oktober 2026',
        eventTime: '10:00 WIB',
        recipientName: 'Raditya Pratama',
        recipientPhone: '081234567890',
        deliveryAddress: 'Jl. Merpati No. 12, Kebayoran Baru, Jakarta Selatan',
        paymentMethod: 'QRIS Gopay',
        status: OrderStatus.completed,
        items: [
          CartItem(
            menu: SampleData.menuItems[5],
            quantity: 15,
          ),
        ],
        totalPrice: SampleData.menuItems[5].price * 15,
        notes: 'Acara syukuran keluarga.',
        review: SampleData.initialReviews[2],
      ),
    );
  }

  OrderItem createOrder({
    required String recipientName,
    required String recipientPhone,
    required String deliveryAddress,
    required String eventDate,
    required String eventTime,
    required String paymentMethod,
    String? notes,
  }) {
    final now = DateTime.now();
    final orderId = 'BKL-${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}-${(_orders.length + 1).toString().padLeft(3, '0')}';

    final newOrder = OrderItem(
      id: orderId,
      orderDate: now,
      eventDate: eventDate,
      eventTime: eventTime,
      recipientName: recipientName,
      recipientPhone: recipientPhone,
      deliveryAddress: deliveryAddress,
      paymentMethod: paymentMethod,
      status: OrderStatus.waitingPayment,
      items: List.from(_cartItems),
      totalPrice: cartTotalPrice,
      notes: notes,
    );

    _orders.insert(0, newOrder);
    _cartItems.clear();
    notifyListeners();
    return newOrder;
  }

  void cancelOrder(String orderId) {
    final index = _orders.indexWhere((o) => o.id == orderId);
    if (index >= 0 && _orders[index].canBeCancelled) {
      _orders[index].status = OrderStatus.cancelled;
      notifyListeners();
    }
  }

  void confirmPayment(String orderId) {
    final index = _orders.indexWhere((o) => o.id == orderId);
    if (index >= 0) {
      _orders[index].status = OrderStatus.processing;
      notifyListeners();
    }
  }

  void reorder(OrderItem previousOrder) {
    for (final item in previousOrder.items) {
      addToCart(item.menu, item.quantity, note: item.specialNote);
    }
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

    // Tandai pesanan sebagai sudah diulas
    final orderIndex = _orders.indexWhere((o) => o.id == orderId);
    if (orderIndex >= 0) {
      _orders[orderIndex].review = newReview;
    }

    notifyListeners();
  }

  String userName = 'Raditya Pratama';
  String userEmail = 'raditya@bekalima.com';
  String userPhone = '0812-3456-7890';
  List<String> savedAddresses = [
    'Jl. Merpati No. 12, Kebayoran Baru, Jakarta Selatan (Rumah)',
    'Gedung Cyber 2 Tower Lt. 15, Jl. H.R. Rasuna Said, Kuningan (Kantor)',
  ];
  int selectedAddressIndex = 0;

  String get currentAddress => savedAddresses.isNotEmpty
      ? savedAddresses[selectedAddressIndex]
      : 'Belum ada alamat tersimpan';

  void updateProfile({required String name, required String phone, required String email}) {
    userName = name;
    userPhone = phone;
    userEmail = email;
    notifyListeners();
  }

  void login({required String usernameOrEmail}) {
    if (usernameOrEmail.trim().isNotEmpty) {
      if (usernameOrEmail.contains('@')) {
        userEmail = usernameOrEmail.trim();
        userName = usernameOrEmail.split('@').first;
      } else {
        userName = usernameOrEmail.trim();
      }
      notifyListeners();
    }
  }

  void register({required String email, required String username, required String phone}) {
    if (username.trim().isNotEmpty) userName = username.trim();
    if (email.trim().isNotEmpty) userEmail = email.trim();
    if (phone.trim().isNotEmpty) userPhone = phone.trim();
    notifyListeners();
  }

  void addAddress(String address) {
    savedAddresses.add(address);
    notifyListeners();
  }

  void selectAddress(int index) {
    if (index >= 0 && index < savedAddresses.length) {
      selectedAddressIndex = index;
      notifyListeners();
    }
  }
}