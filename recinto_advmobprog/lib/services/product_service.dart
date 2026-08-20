import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants.dart';
import '../models/product.dart';

class ProductService {
  // Grabs the whole list of products from the internet for the shop screen.
  Future<List<Product>> getAllProducts() async {
    final response = await http.get(Uri.parse('$host/products'));

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      final List productsJson = data['products'] ?? [];
      return productsJson.map((json) => Product.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load products');
    }
  }

  // You give this an ID number, it runs to the internet, 
  // and brings back the full VIP details for just that ONE specific item.
  Future<Product> getProductById(int id) async {
    final response = await http.get(Uri.parse('$host/products/$id'));

    if (response.statusCode == 200) {
      // It's just one item, so we don't need a list. 
      // Just take the internet data (JSON) and stuff it directly into a Product box.
      return Product.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load product details');
    }
  }
}