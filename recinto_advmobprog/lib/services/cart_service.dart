import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants.dart';
import '../models/cart.dart';

class CartService {
  // Fetch a specific user's cart (e.g., user ID 5)
  Future<Cart> getUserCart(int userId) async {
    final response = await http.get(Uri.parse('$host/carts/user/$userId'));

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      final List cartsJson = data['carts'] ?? [];
      
      if (cartsJson.isNotEmpty) {
        // Return the first cart for this user
        return Cart.fromJson(cartsJson[0]);
      } else {
        throw Exception('No cart found for this user');
      }
    } else {
      throw Exception('Failed to load cart');
    }
  }
}