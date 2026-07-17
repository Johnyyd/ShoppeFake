import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user.dart';
import '../models/product.dart';
import '../models/order.dart';

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
    final headers = {'Content-Type': 'application/json'};
    if (_accessToken != null && _accessToken!.isNotEmpty) {
      headers['Authorization'] = 'Bearer $_accessToken';
    }
    return headers;
  }

  Future<Map<String, dynamic>> login(String username, String password) async {
    final url = Uri.parse('$baseUrl/auth/login');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'username': username, 'password': password}),
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
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
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'username': username, 'password': password}),
    );
    if (response.statusCode == 201) {
      return User.fromJson(json.decode(response.body));
    } else {
      throw Exception(_parseError(response));
    }
  }

  Future<List<VirtualProduct>> getProducts() async {
    final url = Uri.parse('$baseUrl/products');
    final response = await http.get(url, headers: _headers);
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => VirtualProduct.fromJson(json)).toList();
    } else {
      throw Exception(_parseError(response));
    }
  }

  Future<CheckoutResult> checkout(int productId) async {
    final url = Uri.parse('$baseUrl/checkout');
    final response = await http.post(
      url,
      headers: _headers,
      body: json.encode({'product_id': productId}),
    );
    if (response.statusCode == 200) {
      return CheckoutResult.fromJson(json.decode(response.body));
    } else {
      throw Exception(_parseError(response));
    }
  }

  String _parseError(http.Response response) {
    try {
      final data = json.decode(response.body);
      if (data['detail'] != null) {
        return data['detail'].toString();
      }
    } catch (_) {}
    return 'Error ${response.statusCode}: ${response.reasonPhrase}';
  }
}
