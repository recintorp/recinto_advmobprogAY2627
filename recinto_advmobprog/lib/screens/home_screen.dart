import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'product_screen.dart';
import 'cart_screen.dart';
import '../widgets/custom_text.dart';

class HomeScreen extends StatefulWidget {
  final String username;
  const HomeScreen({super.key, this.username = ''});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  final PageController _pageController = PageController();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final surfaceColor = isDark ? const Color(0xFF1C1C1E) : Colors.white;
    final borderColor =
        isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.06);
    final hintColor = isDark ? Colors.white54 : Colors.grey[600];
    final textColor = isDark ? Colors.white : Colors.black87;

    return PopScope(
      canPop: false,
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(72.h),
          child: Container(
            decoration: BoxDecoration(
              color: surfaceColor,
              border: Border(bottom: BorderSide(color: borderColor)),
            ),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Row(
                  children: [
                    Expanded(
                      child: _selectedIndex == 0
                          ? _buildHomeHeader(hintColor, textColor)
                          : CustomText(
                              text: (_selectedIndex == 1)
                                  ? 'Cart'
                                  : (_selectedIndex == 2)
                                      ? 'Profile'
                                      : 'Home',
                              fontSize: 20.sp,
                              fontWeight: FontWeight.w600,
                              color: textColor,
                            ),
                    ),
                    _buildHeaderIconButton(
                      icon: Icons.settings_outlined,
                      isDark: isDark,
                      onTap: () => Navigator.pushNamed(context, '/settings'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        body: PageView(
          physics: const NeverScrollableScrollPhysics(),
          controller: _pageController,
          children: const <Widget>[
            ProductScreen(),
            CartScreen(), 
            SizedBox(), 
          ],
          onPageChanged: (page) {
            setState(() {
              _selectedIndex = page;
            });
          },
        ),
        
        // Button goes poof on Cart screen (index 1). Shows up everywhere else.
        floatingActionButton: _selectedIndex == 1 
            ? null 
            : FloatingActionButton(
                onPressed: () {},
                backgroundColor: Colors.amber,
                child: const Icon(Icons.chat, color: Colors.black),
              ),
              
        bottomNavigationBar: BottomNavigationBar(
          showSelectedLabels: false,
          showUnselectedLabels: false,
          onTap: _onTappedBar,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.shop_2), label: 'Shop'),
            BottomNavigationBarItem(icon: Icon(Icons.shopping_cart), label: 'Cart'),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
          ],
          currentIndex: _selectedIndex,
        ),
      ),
    );
  }

  Widget _buildHomeHeader(Color? hintColor, Color textColor) {
    final hasName = widget.username.trim().isNotEmpty;

    return Row(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(10.r),
          child: Image.asset(
            'assets/images/nubdexchange_logo.png',
            height: 34.h,
            fit: BoxFit.contain,
          ),
        ),
        SizedBox(width: 10.w),
        Expanded(
          child: hasName
              ? Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomText(
                      text: 'Welcome back',
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w400,
                      color: hintColor,
                    ),
                    CustomText(
                      text: widget.username,
                      fontSize: 17.sp,
                      fontWeight: FontWeight.w700,
                      color: textColor,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                )
              : CustomText(
                  text: 'Welcome back',
                  fontSize: 17.sp,
                  fontWeight: FontWeight.w700,
                  color: textColor,
                ),
        ),
      ],
    );
  }

  Widget _buildHeaderIconButton({
    required IconData icon,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20.r),
        child: Container(
          width: 40.w,
          height: 40.w,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isDark
                ? Colors.white.withValues(alpha: 0.06)
                : Colors.black.withValues(alpha: 0.04),
          ),
          child: Icon(icon, size: 20.sp, color: isDark ? Colors.white70 : Colors.black87),
        ),
      ),
    );
  }

  // Syncs bottom bar clicks to change the screen. 
  void _onTappedBar(int value) {
    setState(() {
      _selectedIndex = value;
    });
    _pageController.jumpToPage(value);
  }
}