import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/product_model.dart';

class ApiService {
  static const String baseUrl = 'https://task.itprojects.web.id';

  // ─── AUTH ───────────────────────────────────────────────
  static Future<Map<String, dynamic>> login(
      String username, String password) async {
    final url = Uri.parse('$baseUrl/api/auth/login');
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({
        'username': username,
        'password': password,
      }),
    );

    final data = jsonDecode(response.body);
    if (response.statusCode == 200 && data['success'] == true) {
      return {'success': true, 'token': data['data']['token']};
    } else {
      return {
        'success': false,
        'message': data['message'] ?? 'Login gagal'
      };
    }
  }

  // ─── PRODUK ─────────────────────────────────────────────
  static Future<List<ProductModel>> getProducts(String token) async {
    final url = Uri.parse('$baseUrl/api/products');
    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List products = data['data']['products'];
      return products.map((e) => ProductModel.fromJson(e)).toList();
    } else {
      throw Exception('Gagal memuat produk');
    }
  }

  static Future<Map<String, dynamic>> tambahProduk(
    String token,
    String name,
    int price,
    String description,
  ) async {
    final url = Uri.parse('$baseUrl/api/products');
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'name': name,
        'price': price,
        'description': description,
      }),
    );

    final data = jsonDecode(response.body);
    if (response.statusCode == 200 || response.statusCode == 201) {
      return {'success': true};
    } else {
      return {
        'success': false,
        'message': data['message'] ?? 'Gagal menambah produk'
      };
    }
  }

  static Future<Map<String, dynamic>> deleteProduk(
      String token, int id) async {
    final url = Uri.parse('$baseUrl/api/products/$id');
    final response = await http.delete(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return {'success': true};
    } else {
      final data = jsonDecode(response.body);
      return {
        'success': false,
        'message': data['message'] ?? 'Gagal menghapus produk'
      };
    }
  }

  // ─── SUBMIT ─────────────────────────────────────────────
  static Future<Map<String, dynamic>> submitTugas(
    String token,
    String name,
    int price,
    String description,
    String githubUrl,
  ) async {
    final url = Uri.parse('$baseUrl/api/products/submit');
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'name': name,
        'price': price,
        'description': description,
        'github_url': githubUrl,
      }),
    );

    final data = jsonDecode(response.body);
    if (response.statusCode == 200 || response.statusCode == 201) {
      return {'success': true};
    } else {
      return {
        'success': false,
        'message': data['message'] ?? 'Gagal submit tugas'
      };
    }
  }
}