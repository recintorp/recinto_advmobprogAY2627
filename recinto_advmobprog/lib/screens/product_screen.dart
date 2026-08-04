import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

// models
import '../models/product.dart';

// services
import '../services/product_service.dart';

// widgets
import '../widgets/custom_text.dart';

// screens
import 'product_details_screen.dart';

class ProductScreen extends StatefulWidget {
  const ProductScreen({super.key});

  @override
  State<ProductScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  late final Future<List<Product>> _productsFuture;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _productsFuture = ProductService().getAllProducts();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Reading colors from Theme.of(context) instead of hardcoding them means
    // this screen fades with the rest of the app when dark mode toggles.
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final surfaceColor = isDark ? const Color(0xFF1C1C1E) : Colors.white;
    final cardColor = isDark ? const Color(0xFF1C1C1E) : Colors.white;
    final borderColor =
        isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.06);
    final hintColor = isDark ? Colors.white54 : Colors.grey[600];
    final textColor = isDark ? Colors.white : Colors.black87;

    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              decoration: BoxDecoration(
                color: surfaceColor,
                borderRadius: BorderRadius.circular(28.r),
                border: Border.all(color: borderColor),
                boxShadow: isDark
                    ? null
                    : [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
              ),
              child: TextField(
                controller: _searchController,
                style: TextStyle(color: textColor, fontSize: 14.sp),
                cursorColor: theme.colorScheme.primary,
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value.toLowerCase();
                  });
                },
                decoration: InputDecoration(
                  hintText: 'Search products...',
                  hintStyle: TextStyle(color: hintColor),
                  prefixIcon: Icon(Icons.search, color: hintColor, size: 22.sp),
                  // Only show the little "x" when there's something to clear.
                  suffixIcon: _searchQuery.isEmpty
                      ? null
                      : IconButton(
                          icon: Icon(Icons.close, color: hintColor, size: 18.sp),
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _searchQuery = '');
                          },
                        ),
                  filled: true,
                  fillColor: Colors.transparent,
                  contentPadding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 14.h),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(28.r),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(28.r),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(28.r),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            SizedBox(height: 16.h),
            FutureBuilder<List<Product>>(
              future: _productsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: Padding(
                      padding: EdgeInsets.all(32.r),
                      child: CircularProgressIndicator(color: theme.colorScheme.primary),
                    ),
                  );
                }

                if (snapshot.hasError) {
                  return Center(
                    child: CustomText(
                      text: 'Error: ${snapshot.error}',
                      fontSize: 14.sp,
                    ),
                  );
                }

                final allProducts = snapshot.data ?? [];

                final products = allProducts.where((product) {
                  return product.title.toLowerCase().contains(_searchQuery);
                }).toList();

                if (products.isEmpty) {
                  return Center(
                    child: CustomText(
                      text: 'No products found.',
                      fontSize: 14.sp,
                    ),
                  );
                }

                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: products.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 10.w,
                    mainAxisSpacing: 10.h,
                    childAspectRatio: 0.75,
                  ),
                  itemBuilder: (context, index) {
                    final product = products[index];
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ProductDetailsScreen(product: product),
                          ),
                        );
                      },
                      child: Card(
                        color: cardColor,
                        elevation: isDark ? 0 : 2,
                        clipBehavior: Clip.antiAlias,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                          side: BorderSide(color: borderColor),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              // Product photos usually have white backgrounds,
                              // so keep this patch white even in dark mode.
                              child: Container(
                                color: isDark ? Colors.white : Colors.grey[50],
                                child: Image.network(
                                  product.thumbnail,
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  errorBuilder: (context, error, stackTrace) => Icon(
                                    Icons.image,
                                    size: 24.sp,
                                    color: hintColor,
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.all(8.r),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  CustomText(
                                    text: product.title,
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.bold,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  SizedBox(height: 4.h),
                                  CustomText(
                                    text: '\$${product.price.toStringAsFixed(2)}',
                                    fontSize: 13.sp,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}