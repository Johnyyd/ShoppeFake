import 'package:flutter/foundation.dart' hide Category;
import '../services/api_client.dart';
import '../models/user.dart';
import '../models/product.dart';
import '../models/order.dart';
import '../models/seller.dart';
import '../models/voucher.dart';
import '../models/category.dart';
import '../models/cart_item.dart';
import '../models/product_review.dart';

class ShoppeProvider with ChangeNotifier {
  final ApiClient _apiClient = ApiClient();
  
  User? _currentUser;
  List<VirtualProduct> _products = [];
  List<Seller> _sellers = [];
  List<Voucher> _activeVouchers = [];
  List<UserVoucher> _myVouchers = [];
  List<Category> _categories = [];
  List<CartItem> _cartItems = [];
  List<VirtualOrderModel> _orders = [];
  Category? _selectedCategory;
  String _searchQuery = '';
  String _sortBy = '';
  bool _isLoading = false;
  String? _errorMessage;
  String _tailscaleUrl = 'https://app.taild6d848.ts.net';

  User? get currentUser => _currentUser;
  List<VirtualProduct> get products => _products;
  List<Seller> get sellers => _sellers;
  List<Voucher> get activeVouchers => _activeVouchers;
  List<UserVoucher> get myVouchers => _myVouchers;
  List<Category> get categories => _categories;
  List<CartItem> get cartItems => _cartItems;
  List<VirtualOrderModel> get orders => _orders;
  Category? get selectedCategory => _selectedCategory;
  String get searchQuery => _searchQuery;
  String get sortBy => _sortBy;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get tailscaleUrl => _tailscaleUrl;
  bool get isAuthenticated => _currentUser != null;

  double get cartTotalAmount => _cartItems
      .where((i) => i.isSelected)
      .fold(0.0, (sum, i) => sum + i.product.priceVirtual * i.quantity);

  int get cartTotalCount => _cartItems.fold(0, (sum, i) => sum + i.quantity);

  void updateTailscaleUrl(String newUrl) {
    _tailscaleUrl = newUrl;
    _apiClient.setBaseUrl(newUrl);
    notifyListeners();
  }

  Future<bool> register(String username, String password) async {
    _setLoading(true);
    try {
      await _apiClient.register(username, password);
      await login(username, password);
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _setLoading(false);
      return false;
    }
  }

  Future<bool> login(String username, String password) async {
    _setLoading(true);
    try {
      final data = await _apiClient.login(username, password);
      _currentUser = User(
        id: 0,
        username: data['username'] ?? username,
        virtualBalance: (data['virtual_balance'] ?? 5000.0).toDouble(),
        dopamineLevel: data['dopamine_level'] ?? 0,
      );
      await fetchInitialData();
      _setLoading(false);
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _setLoading(false);
      return false;
    }
  }

  Future<void> fetchInitialData() async {
    await Future.wait([
      fetchCategories(),
      fetchProducts(),
      fetchSellers(),
      fetchActiveVouchers(),
      if (isAuthenticated) fetchMyVouchers(),
      if (isAuthenticated) fetchCart(),
      if (isAuthenticated) fetchOrders(),
    ]);
  }

  Future<void> fetchCategories() async {
    try {
      _categories = await _apiClient.getCategories();
      notifyListeners();
    } catch (e) {
      // Non-fatal error
    }
  }

  Future<void> fetchCart() async {
    try {
      _cartItems = await _apiClient.getCart();
      notifyListeners();
    } catch (e) {
      // Non-fatal
    }
  }

  Future<void> fetchOrders() async {
    if (!isAuthenticated) return;
    try {
      _orders = await _apiClient.getOrders();
      notifyListeners();
    } catch (e) {
      _handleAuthError(e);
    }
  }

  Future<bool> updateOrderStatus(int orderId, String newStatus) async {
    try {
      await _apiClient.updateOrderStatus(orderId, newStatus);
      await fetchOrders();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  void _handleAuthError(Object e) {
    final msg = e.toString().replaceAll('Exception: ', '');
    _errorMessage = msg;
    if (msg.contains('Could not validate credentials') || msg.contains('401')) {
      logout();
    } else {
      notifyListeners();
    }
  }

  Future<void> addToCart(int productId, [int quantity = 1]) async {
    try {
      await _apiClient.addToCart(productId, quantity);
      await fetchCart();
    } catch (e) {
      _handleAuthError(e);
      rethrow;
    }
  }

  Future<void> updateCartQuantity(int cartItemId, int quantity) async {
    if (quantity <= 0) {
      await removeCartItem(cartItemId);
      return;
    }
    try {
      await _apiClient.updateCartItem(cartItemId, quantity);
      await fetchCart();
    } catch (e) {
      _handleAuthError(e);
    }
  }

  Future<void> removeCartItem(int cartItemId) async {
    try {
      await _apiClient.deleteCartItem(cartItemId);
      _cartItems.removeWhere((i) => i.id == cartItemId);
      notifyListeners();
    } catch (e) {
      _handleAuthError(e);
    }
  }

  void toggleCartItemSelection(int cartItemId) {
    final index = _cartItems.indexWhere((i) => i.id == cartItemId);
    if (index != -1) {
      _cartItems[index].isSelected = !_cartItems[index].isSelected;
      notifyListeners();
    }
  }

  void selectAllCartItems(bool select) {
    for (var item in _cartItems) {
      item.isSelected = select;
    }
    notifyListeners();
  }

  Future<void> fetchProducts({Category? category, String? searchQuery, String? sortBy}) async {
    _selectedCategory = category;
    if (searchQuery != null) _searchQuery = searchQuery;
    if (sortBy != null) _sortBy = sortBy;

    try {
      _products = await _apiClient.getProducts(
        categoryId: _selectedCategory?.id,
        searchQuery: _searchQuery.isNotEmpty ? _searchQuery : null,
        sortBy: _sortBy.isNotEmpty ? _sortBy : null,
      );
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
    }
  }

  Future<void> fetchSellers() async {
    try {
      _sellers = await _apiClient.getSellers();
      notifyListeners();
    } catch (e) {
      // Non-fatal
    }
  }

  Future<void> fetchActiveVouchers() async {
    try {
      _activeVouchers = await _apiClient.getActiveVouchers();
      notifyListeners();
    } catch (e) {
      // Non-fatal
    }
  }

  Future<bool> claimVoucher(int voucherId) async {
    if (!isAuthenticated) return false;
    try {
      final claimed = await _apiClient.claimVoucher(voucherId);
      _myVouchers.add(claimed);
      final idx = _activeVouchers.indexWhere((v) => v.id == voucherId);
      if (idx != -1) {
        _activeVouchers[idx] = _activeVouchers[idx].copyWith(isClaimed: true);
      }
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  Future<void> fetchMyVouchers() async {
    if (!isAuthenticated) return;
    try {
      _myVouchers = await _apiClient.getMyVouchers();
      notifyListeners();
    } catch (e) {
      // Non-fatal
    }
  }

  Future<Map<String, dynamic>> validateVoucher(String code, double orderAmount) async {
    try {
      return await _apiClient.validateVoucher(code, orderAmount);
    } catch (e) {
      return {'valid': false, 'discount_amount': 0.0, 'message': e.toString().replaceAll('Exception: ', '')};
    }
  }

  Future<CheckoutResult?> checkoutProduct(int productId, {int quantity = 1, String? voucherCode}) async {
    _setLoading(true);
    try {
      final result = await _apiClient.checkoutSingle(productId, quantity: quantity, voucherCode: voucherCode);
      if (_currentUser != null) {
        _currentUser = User(
          id: _currentUser!.id,
          username: _currentUser!.username,
          virtualBalance: result.newVirtualBalance,
          dopamineLevel: result.newDopamineLevel,
        );
      }
      await fetchOrders();
      _setLoading(false);
      return result;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _setLoading(false);
      return null;
    }
  }

  Future<CheckoutResult?> checkoutSelectedCartItems({String? voucherCode}) async {
    final selectedIds = _cartItems.where((i) => i.isSelected).map((i) => i.id).toList();
    if (selectedIds.isEmpty) return null;

    _setLoading(true);
    try {
      final result = await _apiClient.checkoutCart(selectedIds, voucherCode: voucherCode);
      if (_currentUser != null) {
        _currentUser = User(
          id: _currentUser!.id,
          username: _currentUser!.username,
          virtualBalance: result.newVirtualBalance,
          dopamineLevel: result.newDopamineLevel,
        );
      }
      await fetchCart();
      await fetchOrders();
      _setLoading(false);
      return result;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _setLoading(false);
      return null;
    }
  }

  Future<void> refreshUser() async {
    if (!isAuthenticated) return;
    try {
      final user = await _apiClient.getMe();
      _currentUser = user;
      notifyListeners();
    } catch (e) {
      // Non-fatal if refresh fails
    }
  }

  Future<DailyCheckinResult?> dailyCheckin() async {
    if (!isAuthenticated) return null;
    _errorMessage = null;
    try {
      final result = await _apiClient.dailyCheckin();
      await refreshUser();
      notifyListeners();
      return result;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return null;
    }
  }

  Future<ProductReview?> submitProductReview(int productId, int rating, String? comment) async {
    _setLoading(true);
    try {
      final review = await _apiClient.submitProductReview(productId, rating, comment);
      await refreshUser();
      await fetchProducts(); // refresh product list average ratings
      _setLoading(false);
      return review;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _setLoading(false);
      return null;
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void logout() {
    _currentUser = null;
    _apiClient.setToken(null);
    _products = [];
    _sellers = [];
    _activeVouchers = [];
    _myVouchers = [];
    _categories = [];
    _cartItems = [];
    _orders = [];
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    if (value) _errorMessage = null;
    notifyListeners();
  }
}
