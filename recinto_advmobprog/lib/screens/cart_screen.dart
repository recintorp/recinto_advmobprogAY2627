import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/cart.dart';
import '../services/cart_service.dart';
import '../services/product_service.dart';
import '../services/user_service.dart';
import '../providers/theme_provider.dart';
import 'detail_screen.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  late Future<Cart> _cartFuture;
  final CartService _cartService = CartService();
  
  // Remembers your +/- quantity changes on this screen without breaking the original internet data.
  Map<int, int> localQuantities = {};

  @override
  void initState() {
    super.initState();
    _cartFuture = _initCart(); 
  }

  // Grabs the saved User ID from storage, then asks the internet for that specific user's cart.
  Future<Cart> _initCart() async {
    final userData = await UserService().getUserData();
    // Fallback to 1 if user ID is missing so the screen doesn't crash
    final userId = (userData['id'] == 0 || userData['id'] == null) ? 1 : userData['id']; 
    return await _cartService.getUserCart(userId);
  }

  @override
  Widget build(BuildContext context) {
    // Checks if the app is in dark mode and sets the colors automatically.
    final isDark = Provider.of<ThemeProvider>(context).isDark;
    final bgColor = isDark ? const Color(0xFF121212) : const Color(0xFFF5F7FA);
    final cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black87;
    final subTextColor = isDark ? Colors.grey.shade400 : Colors.grey.shade500;
    final borderColor = isDark ? const Color(0xFF333333) : Colors.grey.shade200;

    return Scaffold(
      backgroundColor: bgColor,
      // Removed the AppBar completely so we don't have double headers!
      body: FutureBuilder<Cart>(
        future: _cartFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}', style: TextStyle(color: textColor)));
          } else if (!snapshot.hasData) {
            return Center(child: Text('Cart is empty', style: TextStyle(color: textColor)));
          }

          final cart = snapshot.data!;
          
          // Calculates the total price based on the local quantity changes.
          double currentSubtotal = 0;
          for (var p in cart.products) {
            currentSubtotal += p.price * (localQuantities[p.id] ?? p.quantity);
          }

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.only(top: 16, bottom: 16),
                  itemCount: cart.products.length,
                  itemBuilder: (context, index) {
                    final product = cart.products[index];
                    final currentQuantity = localQuantities[product.id] ?? product.quantity;

                    return GestureDetector(
                      // Goes to the details page only when you tap the main card area.
                      onTap: () async {
                        try {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Loading product details...'),
                              duration: Duration(milliseconds: 500),
                            ),
                          );

                          final realProduct = await ProductService().getProductById(product.id);

                          if (context.mounted) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ProductDetailsScreen(
                                  product: realProduct,
                                ),
                              ),
                            );
                          }
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Failed to load product details. Please try again.')),
                            );
                          }
                        }
                      },
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                        padding: const EdgeInsets.all(16.0),
                        decoration: BoxDecoration(
                          color: cardColor,
                          borderRadius: BorderRadius.circular(16.0),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.04),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8.0),
                              child: Image.network(product.thumbnail, width: 60, height: 60, fit: BoxFit.cover),
                            ),
                            const SizedBox(width: 16.0),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    product.title,
                                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: textColor),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4.0),
                                  Text(
                                    '\$${product.price}',
                                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.amber),
                                  ),
                                  const SizedBox(height: 2.0),
                                  Text(
                                    '${product.discountPercentage}% off',
                                    style: TextStyle(fontSize: 11, color: subTextColor),
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              children: [
                                GestureDetector(
                                  // Traps the tap here so it doesn't open the details screen, and adds 1 to the quantity.
                                  onTap: () {
                                    setState(() {
                                      localQuantities[product.id] = currentQuantity + 1;
                                    });
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(4.0),
                                    decoration: BoxDecoration(
                                      color: Colors.amber,
                                      borderRadius: BorderRadius.circular(6.0),
                                    ),
                                    child: const Icon(Icons.add, size: 14, color: Colors.white),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 6.0),
                                  child: Text(
                                    '$currentQuantity',
                                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: textColor),
                                  ),
                                ),
                                GestureDetector(
                                  // Traps the tap here so it doesn't open the details screen, and subtracts 1 (if above 1).
                                  onTap: () {
                                    if (currentQuantity > 1) {
                                      setState(() {
                                        localQuantities[product.id] = currentQuantity - 1;
                                      });
                                    }
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(4.0),
                                    decoration: BoxDecoration(
                                      color: isDark ? const Color(0xFF333333) : Colors.grey.shade300,
                                      borderRadius: BorderRadius.circular(6.0),
                                    ),
                                    child: Icon(Icons.remove, size: 14, color: isDark ? Colors.white : Colors.black54),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              Container(
                padding: const EdgeInsets.all(20.0),
                decoration: BoxDecoration(
                  color: cardColor,
                  border: Border(top: BorderSide(color: borderColor)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 10,
                      offset: const Offset(0, -5),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Subtotal:', style: TextStyle(color: subTextColor, fontSize: 14)),
                        Text('\$${currentSubtotal.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.amber, fontSize: 16)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Shipping Fee:', style: TextStyle(color: subTextColor, fontSize: 14)),
                        const Text('\$0.00', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.amber, fontSize: 16)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.amber,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
                        minimumSize: const Size.fromHeight(54),
                      ),
                      onPressed: () {},
                      child: const Text('Confirm Order', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16)),
                    )
                  ],
                ),
              )
            ],
          );
        },
      ),
    );
  }
}