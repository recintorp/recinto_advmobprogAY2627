import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../models/product.dart';
import '../widgets/custom_text.dart';
import '../providers/theme_provider.dart';

class ProductDetailsScreen extends StatefulWidget {
  final Product product;

  const ProductDetailsScreen({super.key, required this.product});

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

// Remembers your choices for size, color, and how many items you want.
class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  String selectedSize = 'M';
  int selectedColorIndex = 0;
  int quantity = 1;

  final List<String> sizes = ['XS', 'S', 'M', 'L', 'XL'];
  final List<Color> colors = [
    Colors.black,
    Colors.grey.shade300,
    Colors.blueGrey,
    Colors.brown.shade300
  ];

  @override
  Widget build(BuildContext context) {
    bool isDark = Provider.of<ThemeProvider>(context).isDark;

    Color bgColor = isDark ? const Color(0xFF121212) : Colors.white;
    Color surfaceColor = isDark ? const Color(0xFF1E1E1E) : const Color(0xFFF9F9F9);
    Color searchBgColor = isDark ? const Color(0xFF2C2C2C) : Colors.grey.shade100;
    Color textColor = isDark ? Colors.white : Colors.black87;
    Color subTextColor = isDark ? Colors.grey.shade400 : Colors.grey.shade600;
    Color borderColor = isDark ? const Color(0xFF333333) : Colors.grey.shade200;
    Color buttonBg = isDark ? Colors.white : Colors.black;
    Color buttonText = isDark ? Colors.black : Colors.white;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: bgColor,
        iconTheme: IconThemeData(color: textColor),
        titleSpacing: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Container(
          height: 36.h,
          padding: EdgeInsets.symmetric(horizontal: 12.w),
          decoration: BoxDecoration(
            color: searchBgColor,
            borderRadius: BorderRadius.circular(6.r),
          ),
          child: Row(
            children: [
              Expanded(
                child: CustomText(
                  text: widget.product.title,
                  fontSize: 14.sp,
                  color: subTextColor,
                ),
              ),
              Icon(Icons.search, color: subTextColor, size: 20),
            ],
          ),
        ),
        actions: [
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_cart_outlined),
                onPressed: () {},
              ),
              Positioned(
                right: 6,
                top: 6,
                child: Container(
                  padding: EdgeInsets.all(3.r),
                  decoration: const BoxDecoration(
                    color: Colors.deepOrange,
                    shape: BoxShape.circle,
                  ),
                  constraints: BoxConstraints(
                    minWidth: 16.w,
                    minHeight: 16.h,
                  ),
                  child: Text(
                    '34',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10.sp,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              )
            ],
          ),
          IconButton(
            icon: const Icon(Icons.ios_share),
            onPressed: () {},
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            color: bgColor,
            offset: const Offset(0, 40),
            onSelected: (value) {},
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              PopupMenuItem<String>(
                value: 'home',
                child: Row(
                  children: [
                    Icon(Icons.home_outlined, color: subTextColor),
                    SizedBox(width: 12.w),
                    Text('Home', style: TextStyle(color: textColor)),
                  ],
                ),
              ),
              PopupMenuItem<String>(
                value: 'wishlist',
                child: Row(
                  children: [
                    Icon(Icons.favorite_border, color: subTextColor),
                    SizedBox(width: 12.w),
                    Text('Wishlist', style: TextStyle(color: textColor)),
                  ],
                ),
              ),
              PopupMenuItem<String>(
                value: 'recently_viewed',
                child: Row(
                  children: [
                    Icon(Icons.access_time, color: subTextColor),
                    SizedBox(width: 12.w),
                    Text('Recently Viewed', style: TextStyle(color: textColor)),
                  ],
                ),
              ),
              PopupMenuItem<String>(
                value: 'customer_service',
                child: Row(
                  children: [
                    Icon(Icons.headset_mic_outlined, color: subTextColor),
                    SizedBox(width: 12.w),
                    Text('Customer Service', style: TextStyle(color: textColor)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              height: 440.h,
              decoration: BoxDecoration(
                color: surfaceColor,
                border: Border(bottom: BorderSide(color: borderColor)),
              ),
              child: SafeArea(
                top: false,
                bottom: false,
                child: Center(
                  child: CachedNetworkImage(
                    imageUrl: widget.product.thumbnail,
                    fit: BoxFit.contain,
                    height: double.infinity,
                    width: double.infinity,
                    placeholder: (context, url) => Center(
                      child: CircularProgressIndicator(color: textColor),
                    ),
                    errorWidget: (context, url, error) => Icon(
                      Icons.broken_image_outlined,
                      size: 50.r,
                      color: subTextColor,
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 24.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomText(
                    text: widget.product.title,
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w400,
                    color: textColor,
                  ),
                  SizedBox(height: 8.h),
                  Row(
                    children: [
                      Icon(Icons.star, color: const Color(0xFFD4AF37), size: 16.sp),
                      Icon(Icons.star, color: const Color(0xFFD4AF37), size: 16.sp),
                      Icon(Icons.star, color: const Color(0xFFD4AF37), size: 16.sp),
                      Icon(Icons.star, color: const Color(0xFFD4AF37), size: 16.sp),
                      Icon(Icons.star_half, color: const Color(0xFFD4AF37), size: 16.sp),
                      SizedBox(width: 8.w),
                      CustomText(
                        text: '4.8 (124 Reviews)',
                        fontSize: 12.sp,
                        color: subTextColor,
                      ),
                    ],
                  ),
                  SizedBox(height: 16.h),
                  CustomText(
                    text: '\$${widget.product.price}',
                    fontSize: 24.sp,
                    fontWeight: FontWeight.w600,
                    color: textColor,
                  ),
                  SizedBox(height: 32.h),
                  Divider(color: borderColor, height: 1),
                  SizedBox(height: 24.h),
                  CustomText(
                    text: 'Color',
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: textColor,
                  ),
                  SizedBox(height: 16.h),
                  Row(
                    children: List.generate(colors.length, (index) {
                      return GestureDetector(
                        onTap: () => setState(() => selectedColorIndex = index),
                        child: Container(
                          margin: EdgeInsets.only(right: 16.w),
                          padding: EdgeInsets.all(3.r),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: selectedColorIndex == index
                                  ? textColor
                                  : Colors.transparent,
                              width: 1.5,
                            ),
                          ),
                          child: CircleAvatar(
                            radius: 14.r,
                            backgroundColor: colors[index],
                          ),
                        ),
                      );
                    }),
                  ),
                  SizedBox(height: 32.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      CustomText(
                        text: 'Size',
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: textColor,
                      ),
                      CustomText(
                        text: 'Size Guide',
                        fontSize: 12.sp,
                        color: subTextColor,
                        fontWeight: FontWeight.w400,
                      ),
                    ],
                  ),
                  SizedBox(height: 16.h),
                  Wrap(
                    spacing: 12.w,
                    runSpacing: 12.h,
                    children: sizes.map((size) {
                      bool isSelected = selectedSize == size;
                      return GestureDetector(
                        onTap: () => setState(() => selectedSize = size),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
                          decoration: BoxDecoration(
                            color: isSelected ? buttonBg : bgColor,
                            border: Border.all(
                              color: isSelected ? buttonBg : borderColor,
                            ),
                          ),
                          child: CustomText(
                            text: size,
                            fontSize: 14.sp,
                            color: isSelected ? buttonText : textColor,
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  SizedBox(height: 32.h),
                  Divider(color: borderColor, height: 1),
                  SizedBox(height: 24.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      CustomText(
                        text: 'Quantity',
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: textColor,
                      ),
                      Container(
                        height: 40.h,
                        decoration: BoxDecoration(
                          border: Border.all(color: borderColor),
                          borderRadius: BorderRadius.circular(20.r),
                        ),
                        child: Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.remove, size: 18),
                              color: textColor,
                              onPressed: () {
                                if (quantity > 1) {
                                  setState(() => quantity--);
                                }
                              },
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 12.w),
                              child: CustomText(
                                text: quantity.toString(),
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w600,
                                color: textColor,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.add, size: 18),
                              color: textColor,
                              onPressed: () {
                                setState(() => quantity++);
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 32.h),
                  Divider(color: borderColor, height: 1),
                  Theme(
                    data: Theme.of(context).copyWith(
                      dividerColor: Colors.transparent,
                      unselectedWidgetColor: textColor,
                      colorScheme: ColorScheme.light(primary: textColor),
                    ),
                    child: ExpansionTile(
                      tilePadding: EdgeInsets.zero,
                      iconColor: textColor,
                      collapsedIconColor: textColor,
                      title: CustomText(
                        text: 'Details & Care',
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: textColor,
                      ),
                      children: [
                        Padding(
                          padding: EdgeInsets.only(bottom: 16.h),
                          child: CustomText(
                            text: widget.product.description,
                            fontSize: 14.sp,
                            color: subTextColor,
                            textAlign: TextAlign.justify, 
                          ),
                        ),
                      ],
                    ),
                  ),
                  Divider(color: borderColor, height: 1),
                  SizedBox(height: 20.h),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
          decoration: BoxDecoration(
            color: bgColor,
            border: Border(top: BorderSide(color: borderColor)),
          ),
          child: Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: borderColor),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: Icon(Icons.favorite_border, size: 24, color: textColor),
                  onPressed: () {},
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: ElevatedButton(
                  // Shows a success message confirming your items were added.
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Added $quantity x ${widget.product.title} to cart!'),
                        backgroundColor: Colors.green,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: buttonBg,
                    foregroundColor: buttonText,
                    elevation: 0,
                    padding: EdgeInsets.symmetric(vertical: 18.h),
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.zero,
                    ),
                  ),
                  child: CustomText(
                    text: 'ADD TO CART',
                    color: buttonText,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}