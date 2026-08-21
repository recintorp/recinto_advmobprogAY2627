import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'product_screen.dart';
import 'cart_screen.dart';
import 'profile_screen.dart'; 
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
    final Map<String, dynamic>? userData = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final displayUsername = userData?['username'] ?? widget.username;
    final firstName = userData?['firstName'] ?? 'Profile';

    const appBarBgColor = Color(0xFF3949AB);
    const appBarTextColor = Colors.white;

    return PopScope(
      canPop: false,
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(75.h), // Slightly taller to fit the stacked text beautifully
          child: Container(
            decoration: const BoxDecoration(
              color: appBarBgColor,
            ),
            child: SafeArea(
              bottom: false,
              child: Padding(
                // Added vertical padding to give the header breathing room
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                child: Row(
                  // THIS is what fixes the awkward floating! It forces everything to the vertical center.
                  crossAxisAlignment: CrossAxisAlignment.center, 
                  children: [
                    Expanded(
                      child: _selectedIndex == 0
                          ? _buildHomeHeader(displayUsername)
                          : CustomText(
                              text: (_selectedIndex == 1) ? 'Cart' : firstName,
                              fontSize: 22.sp,
                              fontWeight: FontWeight.w700,
                              color: appBarTextColor,
                            ),
                    ),
                    _buildHeaderIconButton(
                      icon: Icons.settings,
                      color: Colors.white,
                      bgColor: Colors.transparent, 
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
            ProfileScreen(), 
          ],
          onPageChanged: (page) {
            setState(() {
              _selectedIndex = page;
            });
          },
        ),
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

  Widget _buildHomeHeader(String username) {
    final hasName = username.trim().isNotEmpty;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Image.asset(
          'assets/images/nubdexchange_logo.png',
          height: 38.h, 
          fit: BoxFit.contain,
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Welcome Back',
                style: TextStyle(
                  fontFamily: 'Poppins', 
                  fontSize: 12.sp, // Slightly smaller subtitle
                  fontWeight: FontWeight.w400,
                  color: Colors.white70, 
                  height: 1.0, // Removes the invisible padding below the text
                ),
              ),
              if (hasName)
                Text(
                  username,
                  style: TextStyle(
                    fontFamily: 'Poppins', 
                    fontSize: 20.sp, // Larger username
                    fontWeight: FontWeight.bold,
                    color: Colors.amber, 
                    height: 1.2, // Tucks it nicely under the subtitle
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHeaderIconButton({
    required IconData icon,
    required Color color,
    required Color bgColor,
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
            color: bgColor,
          ),
          // Ensured the icon perfectly centers within its own invisible box
          alignment: Alignment.center, 
          child: Icon(icon, size: 24.sp, color: color),
        ),
      ),
    );
  }

  void _onTappedBar(int value) {
    setState(() {
      _selectedIndex = value;
    });
    _pageController.jumpToPage(value);
  }
}