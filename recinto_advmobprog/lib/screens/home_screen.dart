import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import 'product_screen.dart';
import 'cart_screen.dart';
import 'profile_screen.dart';
import '../widgets/custom_text.dart';
import '../providers/theme_provider.dart';

const _indigo = Color(0xFF3949AB);
const _indigoDeep = Color(0xFF262E7A);
const _amber = Colors.amber;

// Main navigation hub
class HomeScreen extends StatefulWidget {
  final String username;
  const HomeScreen({super.key, this.username = ''});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  final PageController _pageController = PageController();

  static const _navIcons = [
    Icons.storefront_rounded,
    Icons.shopping_bag_rounded,
    Icons.person_rounded,
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<ThemeProvider>(context).isDark;
    final bgColor = isDark ? const Color(0xFF121212) : Colors.white;

    final Map<String, dynamic>? userData =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final displayUsername = userData?['username'] ?? widget.username;
    final firstName = userData?['firstName'] ?? 'Profile';

    // Get bottom system inset to avoid overlapping the system swipe indicator
    final bottomInset = MediaQuery.of(context).padding.bottom;

    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: bgColor,
        appBar: _buildAppBar(displayUsername, firstName),
        body: Stack(
          children: [
            PageView(
              physics: const NeverScrollableScrollPhysics(),
              controller: _pageController,
              children: const <Widget>[
                ProductScreen(),
                CartScreen(),
                ProfileScreen(),
              ],
              onPageChanged: (page) => setState(() => _selectedIndex = page),
            ),
            
            // Floating Action Button
            if (_selectedIndex == 0)
              Positioned(
                right: 20.w,
                bottom: 84.h + bottomInset, // Adjusted to match the lowered nav bar
                child: _buildFab(),
              ),

            // True floating nav bar overlay
            Positioned(
              left: 20.w,
              right: 20.w,
              bottom: 12.h + bottomInset, // Lowered closer to the screen edge
              child: _buildFloatingNavBar(),
            ),
          ],
        ),
      ),
    );
  }

  // Gradient app bar with user info
  PreferredSizeWidget _buildAppBar(String displayUsername, String firstName) {
    return PreferredSize(
      preferredSize: Size.fromHeight(92.h),
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [_indigo, _indigoDeep],
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: _selectedIndex == 0
                      ? _buildHomeHeader(displayUsername)
                      : CustomText(
                          text: (_selectedIndex == 1) ? 'Your Cart' : firstName,
                          fontSize: 24.sp,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.2,
                          color: Colors.white,
                        ),
                ),
                _buildHeaderIconButton(
                  icon: Icons.settings_outlined,
                  onTap: () => Navigator.pushNamed(context, '/settings'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHomeHeader(String username) {
    final hasName = username.trim().isNotEmpty;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 44.w,
          height: 44.w,
          padding: EdgeInsets.all(6.w),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            // ignore: deprecated_member_use
            color: Colors.white.withOpacity(0.06),
            border: Border.all(color: Colors.white24, width: 1),
          ),
          child: Image.asset(
            'assets/images/nubdexchange_logo.png',
            fit: BoxFit.contain,
          ),
        ),
        SizedBox(width: 14.w),
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomText(
                text: 'WELCOME BACK',
                fontSize: 11.sp,
                fontWeight: FontWeight.w500,
                letterSpacing: 1.2,
                color: Colors.white60,
              ),
              SizedBox(height: 2.h),
              if (hasName)
                CustomText(
                  text: username,
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
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
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22.r),
        child: Container(
          width: 42.w,
          height: 42.w,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white24, width: 1),
          ),
          child: Icon(icon, size: 20.sp, color: Colors.white),
        ),
      ),
    );
  }

  // Floating action button for the shop tab
  Widget _buildFab() {
    return Material(
      color: Colors.transparent,
      shape: const CircleBorder(),
      child: InkWell(
        onTap: () {},
        customBorder: const CircleBorder(),
        child: Container(
          width: 52.w,
          height: 52.w,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _amber,
            boxShadow: [
              BoxShadow(
                // ignore: deprecated_member_use
                color: Colors.black.withOpacity(0.18),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Icon(Icons.chat_bubble_rounded, size: 22.sp, color: Colors.black87),
        ),
      ),
    );
  }

  // Bottom floating navigation bar overlay
  Widget _buildFloatingNavBar() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(32.r),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          height: 56.h, // Slimmer profile
          decoration: BoxDecoration(
            // ignore: deprecated_member_use
            color: _indigoDeep.withOpacity(0.92),
            borderRadius: BorderRadius.circular(32.r),
            // ignore: deprecated_member_use
            border: Border.all(color: Colors.white.withOpacity(0.08)),
            boxShadow: [
              BoxShadow(
                // ignore: deprecated_member_use
                color: Colors.black.withOpacity(0.2),
                blurRadius: 24,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(_navIcons.length, (index) {
              return _buildNavItem(
                icon: _navIcons[index],
                selected: _selectedIndex == index,
                onTap: () => _onTappedBar(index),
              );
            }),
          ),
        ),
      ),
    );
  }

  // Individual navigation item centered with a circular active state
  Widget _buildNavItem({
    required IconData icon,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Center(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOut,
            width: 42.w, // Slightly smaller highlight
            height: 42.w,
            decoration: BoxDecoration(
              // ignore: deprecated_member_use
              color: selected ? Colors.white.withOpacity(0.12) : Colors.transparent,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Icon(icon, size: 26.sp, color: selected ? _amber : Colors.white60), // Slightly smaller icon
            ),
          ),
        ),
      ),
    );
  }

  // Handles navigation transitions
  void _onTappedBar(int value) {
    setState(() => _selectedIndex = value);
    _pageController.jumpToPage(value);
  }
}