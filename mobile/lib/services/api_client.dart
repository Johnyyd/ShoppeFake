import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user.dart';
import '../models/product.dart';
import '../models/order.dart';
import '../models/seller.dart';
import '../models/voucher.dart';
import '../models/category.dart';
import '../models/cart_item.dart';
import '../models/product_review.dart';

class ApiClient {
  // By default points to localhost/emulator or dynamic Tailscale URL from STATE.md
  // You can override baseUrl dynamically when consuming the public tunnel
  String baseUrl;
  String? _accessToken;

  ApiClient({this.baseUrl = 'https://app.taild6d848.ts.net'});

  void setBaseUrl(String newUrl) {
    baseUrl = newUrl.replaceAll(RegExp(r'/$'), '');
  }

  void setToken(String? token) {
    _accessToken = token;
  }

  Map<String, String> get _headers {
    final headers = {
      'Content-Type': 'application/json; charset=utf-8',
      'Accept': 'application/json; charset=utf-8',
    };
    if (_accessToken != null && _accessToken!.isNotEmpty) {
      headers['Authorization'] = 'Bearer $_accessToken';
    }
    return headers;
  }

  dynamic _decodeJson(http.Response response) {
    return json.decode(utf8.decode(response.bodyBytes));
  }

  Future<Map<String, dynamic>> login(String username, String password) async {
    final url = Uri.parse('$baseUrl/auth/login');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json; charset=utf-8', 'Accept': 'application/json; charset=utf-8'},
      body: json.encode({'username': username, 'password': password}),
    );
    if (response.statusCode == 200) {
      final data = _decodeJson(response);
      _accessToken = data['access_token'];
      return data;
    } else {
      throw Exception(_parseError(response));
    }
  }

  Future<User> register(String username, String password) async {
    final url = Uri.parse('$baseUrl/auth/register');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json; charset=utf-8', 'Accept': 'application/json; charset=utf-8'},
      body: json.encode({'username': username, 'password': password}),
    );
    if (response.statusCode == 201) {
      return User.fromJson(_decodeJson(response));
    } else {
      throw Exception(_parseError(response));
    }
  }

  Future<User> getMe() async {
    final url = Uri.parse('$baseUrl/auth/me');
    final response = await http.get(url, headers: _headers);
    if (response.statusCode == 200) {
      return User.fromJson(_decodeJson(response));
    } else {
      throw Exception(_parseError(response));
    }
  }

  Future<DailyCheckinResult> dailyCheckin() async {
    final url = Uri.parse('$baseUrl/auth/daily-checkin');
    final response = await http.post(url, headers: _headers);
    if (response.statusCode == 200) {
      return DailyCheckinResult.fromJson(_decodeJson(response));
    } else {
      throw Exception(_parseError(response));
    }
  }

  Future<ProductReview> submitProductReview(int productId, int rating, String? comment) async {
    final url = Uri.parse('$baseUrl/products/$productId/reviews');
    final response = await http.post(
      url,
      headers: _headers,
      body: json.encode({
        'rating': rating,
        'comment': comment,
      }),
    );
    if (response.statusCode == 200) {
      return ProductReview.fromJson(_decodeJson(response));
    } else {
      throw Exception(_parseError(response));
    }
  }

  Future<List<VirtualProduct>> getProducts({int? categoryId, String? searchQuery, String? sortBy}) async {
    final queryParams = <String, String>{};
    if (categoryId != null) queryParams['category_id'] = categoryId.toString();
    if (searchQuery != null && searchQuery.trim().isNotEmpty) queryParams['search_query'] = searchQuery.trim();
    if (sortBy != null && sortBy.isNotEmpty) queryParams['sort_by'] = sortBy;

    final uri = Uri.parse('$baseUrl/products').replace(queryParameters: queryParams.isNotEmpty ? queryParams : null);
    final response = await http.get(uri, headers: _headers);
    if (response.statusCode == 200) {
      final List<dynamic> data = _decodeJson(response);
      return data.map((json) => VirtualProduct.fromJson(json)).toList();
    } else {
      throw Exception(_parseError(response));
    }
  }

  Future<List<Category>> getCategories() async {
    final url = Uri.parse('$baseUrl/categories');
    final response = await http.get(url, headers: _headers);
    if (response.statusCode == 200) {
      final List<dynamic> data = _decodeJson(response);
      return data.map((json) => Category.fromJson(json)).toList();
    } else {
      throw Exception(_parseError(response));
    }
  }

  Future<List<CartItem>> getCart() async {
    final url = Uri.parse('$baseUrl/cart');
    final response = await http.get(url, headers: _headers);
    if (response.statusCode == 200) {
      final data = _decodeJson(response);
      final List<dynamic> items = data['items'] ?? [];
      return items.map((json) => CartItem.fromJson(json)).toList();
    } else {
      throw Exception(_parseError(response));
    }
  }

  Future<CartItem> addToCart(int productId, [int quantity = 1]) async {
    final url = Uri.parse('$baseUrl/cart/add');
    final response = await http.post(
      url,
      headers: _headers,
      body: json.encode({'product_id': productId, 'quantity': quantity}),
    );
    if (response.statusCode == 200) {
      return CartItem.fromJson(_decodeJson(response));
    } else {
      throw Exception(_parseError(response));
    }
  }

  Future<CartItem> updateCartItem(int cartItemId, int quantity) async {
    final url = Uri.parse('$baseUrl/cart/$cartItemId');
    final response = await http.put(
      url,
      headers: _headers,
      body: json.encode({'quantity': quantity}),
    );
    if (response.statusCode == 200) {
      return CartItem.fromJson(_decodeJson(response));
    } else {
      throw Exception(_parseError(response));
    }
  }

  Future<void> deleteCartItem(int cartItemId) async {
    final url = Uri.parse('$baseUrl/cart/$cartItemId');
    final response = await http.delete(url, headers: _headers);
    if (response.statusCode != 200) {
      throw Exception(_parseError(response));
    }
  }

  Future<List<Seller>> getSellers() async {
    final url = Uri.parse('$baseUrl/sellers');
    final response = await http.get(url, headers: _headers);
    if (response.statusCode == 200) {
      final List<dynamic> data = _decodeJson(response);
      return data.map((json) => Seller.fromJson(json)).toList();
    } else {
      throw Exception(_parseError(response));
    }
  }

  Future<List<Voucher>> getActiveVouchers() async {
    final url = Uri.parse('$baseUrl/vouchers/active');
    final response = await http.get(url, headers: _headers);
    if (response.statusCode == 200) {
      final List<dynamic> data = _decodeJson(response);
      return data.map((json) => Voucher.fromJson(json)).toList();
    } else {
      throw Exception(_parseError(response));
    }
  }

  Future<Map<String, dynamic>> validateVoucher(String code, double orderAmount) async {
    final url = Uri.parse('$baseUrl/vouchers/validate');
    final response = await http.post(
      url,
      headers: _headers,
      body: json.encode({'code': code, 'order_amount': orderAmount}),
    );
    if (response.statusCode == 200) {
      return _decodeJson(response);
    } else {
      throw Exception(_parseError(response));
    }
  }

  Future<UserVoucher> claimVoucher(int voucherId) async {
    final url = Uri.parse('$baseUrl/vouchers/$voucherId/claim');
    final response = await http.post(url, headers: _headers);
    if (response.statusCode == 200) {
      return UserVoucher.fromJson(_decodeJson(response));
    } else {
      throw Exception(_parseError(response));
    }
  }

  Future<List<UserVoucher>> getMyVouchers() async {
    final url = Uri.parse('$baseUrl/vouchers/my-vouchers');
    final response = await http.get(url, headers: _headers);
    if (response.statusCode == 200) {
      final List<dynamic> data = _decodeJson(response);
      return data.map((json) => UserVoucher.fromJson(json)).toList();
    } else {
      throw Exception(_parseError(response));
    }
  }

  Future<CheckoutResult> checkoutSingle(int productId, {int quantity = 1, String? voucherCode}) async {
    final url = Uri.parse('$baseUrl/checkout');
    final body = <String, dynamic>{'product_id': productId, 'quantity': quantity};
    if (voucherCode != null && voucherCode.isNotEmpty) {
      body['voucher_code'] = voucherCode;
    }
    final response = await http.post(
      url,
      headers: _headers,
      body: json.encode(body),
    );
    if (response.statusCode == 200) {
      return CheckoutResult.fromJson(_decodeJson(response));
    } else {
      throw Exception(_parseError(response));
    }
  }

  Future<CheckoutResult> checkoutCart(List<int> itemIds, {String? voucherCode}) async {
    final url = Uri.parse('$baseUrl/checkout');
    final body = <String, dynamic>{'item_ids': itemIds};
    if (voucherCode != null && voucherCode.isNotEmpty) {
      body['voucher_code'] = voucherCode;
    }
    final response = await http.post(
      url,
      headers: _headers,
      body: json.encode(body),
    );
    if (response.statusCode == 200) {
      return CheckoutResult.fromJson(_decodeJson(response));
    } else {
      throw Exception(_parseError(response));
    }
  }

  Future<CheckoutResult> checkout(int productId, {String? voucherCode}) async {
    return checkoutSingle(productId, voucherCode: voucherCode);
  }

  Future<List<VirtualOrderModel>> getOrders() async {
    final url = Uri.parse('$baseUrl/orders');
    final response = await http.get(url, headers: _headers);
    if (response.statusCode == 200) {
      final List<dynamic> data = _decodeJson(response);
      return data.map((json) => VirtualOrderModel.fromJson(json)).toList();
    } else {
      throw Exception(_parseError(response));
    }
  }

  Future<VirtualOrderModel> updateOrderStatus(int orderId, String newStatus) async {
    final url = Uri.parse('$baseUrl/orders/$orderId/status');
    final response = await http.put(
      url,
      headers: _headers,
      body: json.encode({'status': newStatus}),
    );
    if (response.statusCode == 200) {
      return VirtualOrderModel.fromJson(_decodeJson(response));
    } else {
      throw Exception(_parseError(response));
    }
  }

  String _parseError(http.Response response) {
    try {
      final data = _decodeJson(response);
      if (data['detail'] != null) {
        return data['detail'].toString();
      }
    } catch (_) {}
    return 'Error ${response.statusCode}: ${response.reasonPhrase}';
  }
}
