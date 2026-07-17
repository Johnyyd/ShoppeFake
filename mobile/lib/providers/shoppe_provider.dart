import 'package:flutter/foundation.dart';
import '../services/api_client.dart';
import '../models/user.dart';
import '../models/product.dart';
import '../models/order.dart';

class ShoppeProvider with ChangeNotifier {
  final ApiClient _apiClient = ApiClient();
  
  User? _currentUser;
  List<VirtualProduct> _products = [];
  bool _isLoading = false;
  String? _errorMessage;
  String _tailscaleUrl = 'https://app.taild6d848.ts.net';

  User? get currentUser => _currentUser;
  List<VirtualProduct> get products => _products;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get tailscaleUrl => _tailscaleUrl;
  bool get isAuthenticated => _currentUser != null;

  void updateTailscaleUrl(String newUrl) {
    _tailscaleUrl = newUrl;
    _apiClient.setBaseUrl(newUrl);
    notifyListeners();
  }

  Future<bool> register(String username, String password) async {
    _setLoading(true);
    try {
      final user = await _apiClient.register(username, password);
      // Auto login after registration
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
      await fetchProducts();
      _setLoading(false);
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _setLoading(false);
      return false;
    }
  }

  Future<void> fetchProducts() async {
    try {
      _products = await _apiClient.getProducts();
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
    }
  }

  Future<CheckoutResult?> checkoutProduct(int productId) async {
    _setLoading(true);
    try {
      final result = await _apiClient.checkout(productId);
      // Update local state with new balances
      if (_currentUser != null) {
        _currentUser = User(
          id: _currentUser!.id,
          username: _currentUser!.username,
          virtualBalance: result.newVirtualBalance,
          dopamineLevel: result.newDopamineLevel,
        );
      }
      _setLoading(false);
      return result;
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
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    if (value) _errorMessage = null;
    notifyListeners();
  }
}
