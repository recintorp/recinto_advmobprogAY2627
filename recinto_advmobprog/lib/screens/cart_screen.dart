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
  
  // Tracks local quantity adjustments without hitting the API constantly
  Map<int, int> localQuantities = {};

  @override
  void initState() {
    super.initState();
    _cartFuture = _initCart(); 
  }

  // Fetches the user's cart safely, falling back to a default ID if missing
  Future<Cart> _initCart() async {
    final userData = await UserService().getUserData();
    final userId = (userData['id'] == 0 || userData['id'] == null) ? 1 : userData['id']; 
    return await _cartService.getUserCart(userId);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<ThemeProvider>(context).isDark;
    
    // Restored Original Color Palette
    final bgColor = isDark ? const Color(0xFF121212) : const Color(0xFFF5F7FA);
    final surfaceColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black87;
    final subTextColor = isDark ? Colors.grey.shade400 : Colors.grey.shade500;
    final borderColor = isDark ? const Color(0xFF333333) : Colors.grey.shade200;

    // Bottom padding to perfectly clear the custom floating nav bar in HomeScreen
    final bottomNavOffset = MediaQuery.of(context).padding.bottom + 100.0;

    return Scaffold(
      backgroundColor: bgColor,
      body: FutureBuilder<Cart>(
        future: _cartFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                color: Colors.amber,
                strokeWidth: 2,
              ),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text(
                'Something went wrong.',
                style: TextStyle(color: subTextColor, fontSize: 16),
              ),
            );
          } else if (!snapshot.hasData || snapshot.data!.products.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.shopping_bag_outlined, size: 48, color: borderColor),
                  const SizedBox(height: 16),
                  Text(
                    'Your cart is empty',
                    style: TextStyle(color: textColor, fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            );
          }

          final cart = snapshot.data!;
          
          double currentSubtotal = 0;
          for (var p in cart.products) {
            currentSubtotal += p.price * (localQuantities[p.id] ?? p.quantity);
          }

          return Column(
            children: [
              Expanded(
                child: ListView.separated(
                  // Added extra top padding to distance it from the app bar
                  padding: const EdgeInsets.only(left: 24, right: 24, top: 16, bottom: 8),
                  itemCount: cart.products.length,
                  separatorBuilder: (context, index) => Divider(
                    color: borderColor,
                    height: 32,
                    thickness: 1,
                  ),
                  itemBuilder: (context, index) {
                    final product = cart.products[index];
                    final currentQuantity = localQuantities[product.id] ?? product.quantity;

                    return GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () async {
                        try {
                          final realProduct = await ProductService().getProductById(product.id);
                          if (context.mounted) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ProductDetailsScreen(product: realProduct),
                              ),
                            );
                          }
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Failed to load product details.')),
                            );
                          }
                        }
                      },
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Premium product image framing
                          Container(
                            width: 96,
                            height: 96,
                            decoration: BoxDecoration(
                              color: surfaceColor,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: borderColor),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: Image.network(
                                product.thumbnail,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 4),
                                Text(
                                  product.title,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: -0.2,
                                    color: textColor,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  '\$${product.price.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.amber, 
                                  ),
                                ),
                                const SizedBox(height: 16),
                                // Minimalist pill-shaped quantity selector
                                Container(
                                  decoration: BoxDecoration(
                                    border: Border.all(color: borderColor, width: 1),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      GestureDetector(
                                        onTap: () {
                                          if (currentQuantity > 1) {
                                            setState(() {
                                              localQuantities[product.id] = currentQuantity - 1;
                                            });
                                          }
                                        },
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                          child: Icon(Icons.remove, size: 16, color: currentQuantity > 1 ? textColor : subTextColor),
                                        ),
                                      ),
                                      Text(
                                        '$currentQuantity',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 14,
                                          color: textColor,
                                        ),
                                      ),
                                      GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            localQuantities[product.id] = currentQuantity + 1;
                                          });
                                        },
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                          child: Icon(Icons.add, size: 16, color: textColor),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              
              // Refined checkout footer, padded to hover perfectly above the nav bar
              Container(
                padding: EdgeInsets.fromLTRB(24, 24, 24, bottomNavOffset),
                decoration: BoxDecoration(
                  color: surfaceColor,
                  border: Border(top: BorderSide(color: borderColor, width: 1)),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Subtotal:', style: TextStyle(color: subTextColor, fontSize: 15)),
                        Text(
                          '\$${currentSubtotal.toStringAsFixed(2)}',
                          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.amber, fontSize: 16),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Shipping Fee:', style: TextStyle(color: subTextColor, fontSize: 15)),
                        const Text(
                          '\$0.00',
                          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.amber, fontSize: 16),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.amber, 
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
                        minimumSize: const Size.fromHeight(54),
                      ),
                      onPressed: () {},
                      child: const Text(
                        'Confirm Order',
                        style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16),
                      ),
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