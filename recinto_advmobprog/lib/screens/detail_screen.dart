import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

class _ProductDetailsScreenState extends State<ProductDetailsScreen>
    with SingleTickerProviderStateMixin {
  int quantity = 1;
  bool isWishlisted = false;

  late final AnimationController _entrance;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _entrance = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 550),
    );
    _fade = CurvedAnimation(parent: _entrance, curve: Curves.easeOut);
    _slide = Tween<Offset>(begin: const Offset(0, 0.04), end: Offset.zero)
        .animate(CurvedAnimation(parent: _entrance, curve: Curves.easeOutCubic));
    _entrance.forward();
  }

  @override
  void dispose() {
    _entrance.dispose();
    super.dispose();
  }

  void _showAddedToBagNotice(Color bgColor, Color textColor) {
    final overlay = Overlay.of(context);
    final entry = OverlayEntry(
      builder: (context) => Positioned(
        left: 24.w,
        right: 24.w,
        bottom: 100.h,
        child: _FloatingNotice(
          text: 'Added to your bag',
          bgColor: bgColor,
          textColor: textColor,
        ),
      ),
    );
    overlay.insert(entry);
    Future.delayed(const Duration(milliseconds: 1600), () => entry.remove());
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Provider.of<ThemeProvider>(context).isDark;
    final double topPadding = MediaQuery.of(context).padding.top;

    final Color bgColor = isDark ? const Color(0xFF121212) : const Color(0xFFFAF9F6);
    final Color heroColor = isDark ? const Color(0xFF1A1A1A) : const Color(0xFFF3F1EC);
    final Color cardColor = isDark ? const Color(0xFF161616) : const Color(0xFFFFFFFF);
    final Color textColor = isDark ? const Color(0xFFF5F5F0) : const Color(0xFF1C1C1C);
    final Color subTextColor = isDark ? const Color(0xFFA8A8A0) : const Color(0xFF7A7669);
    final Color borderColor = isDark ? const Color(0xFF2A2A2A) : const Color(0xFFEDEAE1);
    final Color accentColor = const Color(0xFFB08D57);
    final Color buttonBg = isDark ? Colors.white : const Color(0xFF1C1C1C);
    final Color buttonText = isDark ? Colors.black : Colors.white;
    // ignore: deprecated_member_use
    final Color glassTint = isDark ? Colors.black.withOpacity(0.35) : Colors.white.withOpacity(0.55);
    final Color glassIcon = textColor;

    final double heroHeight = MediaQuery.of(context).size.height * 0.38;

    return Scaffold(
      backgroundColor: bgColor,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            expandedHeight: heroHeight,
            pinned: false,
            floating: false,
            stretch: true,
            stretchTriggerOffset: 90,
            automaticallyImplyLeading: false,
            backgroundColor: bgColor,
            elevation: 0,
            scrolledUnderElevation: 0,
            surfaceTintColor: Colors.transparent,
            flexibleSpace: FlexibleSpaceBar(
              stretchModes: const [StretchMode.zoomBackground],
              background: Stack(
                fit: StackFit.expand,
                children: [
                Container(
                  width: double.infinity,
                  height: heroHeight,
                  color: heroColor,
                  child: Hero(
                    tag: 'product-${widget.product.title}',
                    child: CachedNetworkImage(
                      imageUrl: widget.product.thumbnail,
                      fit: BoxFit.contain,
                      width: double.infinity,
                      height: double.infinity,
                      placeholder: (context, url) => Center(
                        child: CircularProgressIndicator(color: subTextColor, strokeWidth: 1.5),
                      ),
                      errorWidget: (context, url, error) => Icon(
                        Icons.image_outlined,
                        size: 44.r,
                        color: subTextColor,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: topPadding + 12.h,
                  left: 20.w,
                  child: _GlassIconButton(
                    icon: Icons.arrow_back_ios_new_rounded,
                    tint: glassTint,
                    iconColor: glassIcon,
                    onTap: () => Navigator.pop(context),
                  ),
                ),
                Positioned(
                  top: topPadding + 12.h,
                  right: 20.w,
                  child: Row(
                    children: [
                      _GlassIconButton(
                        icon: Icons.ios_share_rounded,
                        tint: glassTint,
                        iconColor: glassIcon,
                        onTap: () {},
                      ),
                      SizedBox(width: 10.w),
                      Stack(
                        clipBehavior: Clip.none,
                        children: [
                          _GlassIconButton(
                            icon: Icons.shopping_bag_outlined,
                            tint: glassTint,
                            iconColor: glassIcon,
                            onTap: () {},
                          ),
                          Positioned(
                            top: -2,
                            right: -2,
                            child: Container(
                              width: 16.r,
                              height: 16.r,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: accentColor,
                                shape: BoxShape.circle,
                                border: Border.all(color: bgColor, width: 1.5),
                              ),
                              child: Text(
                                '3',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 9.sp,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Transform.translate(
            offset: Offset(0, -28.h),
              child: FadeTransition(
                opacity: _fade,
                child: SlideTransition(
                  position: _slide,
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(28.r),
                        topRight: Radius.circular(28.r),
                      ),
                    ),
                    padding: EdgeInsets.fromLTRB(24.w, 28.h, 24.w, 8.h),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Container(
                            width: 36.w,
                            height: 4.h,
                            margin: EdgeInsets.only(bottom: 24.h),
                            decoration: BoxDecoration(
                              color: borderColor,
                              borderRadius: BorderRadius.circular(4.r),
                            ),
                          ),
                        ),
                        CustomText(
                          text: widget.product.title,
                          fontSize: 21.sp,
                          fontWeight: FontWeight.w400,
                          letterSpacing: 0.2,
                          color: textColor,
                        ),
                        SizedBox(height: 10.h),
                        _RatingSummaryInline(
                          rating: 4.8,
                          reviewCount: 124,
                          accentColor: accentColor,
                          textColor: subTextColor,
                        ),
                        SizedBox(height: 22.h),
                        CustomText(
                          text: '\$${widget.product.price}',
                          fontSize: 25.sp,
                          fontWeight: FontWeight.w500,
                          color: textColor,
                        ),
                        SizedBox(height: 6.h),
                        CustomText(
                          text: 'Free shipping · 30-day returns',
                          fontSize: 12.sp,
                          color: subTextColor,
                        ),
                        SizedBox(height: 28.h),
                        Container(height: 1, color: borderColor),
                        SizedBox(height: 24.h),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            CustomText(
                              text: 'Quantity',
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w500,
                              color: textColor,
                            ),
                            Container(
                              height: 40.h,
                              decoration: BoxDecoration(
                                border: Border.all(color: borderColor),
                                borderRadius: BorderRadius.circular(20.r),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  _StepperButton(
                                    icon: Icons.remove_rounded,
                                    color: textColor,
                                    onTap: () {
                                      if (quantity > 1) {
                                        HapticFeedback.selectionClick();
                                        setState(() => quantity--);
                                      }
                                    },
                                  ),
                                  SizedBox(
                                    width: 28.w,
                                    child: AnimatedSwitcher(
                                      duration: const Duration(milliseconds: 180),
                                      transitionBuilder: (child, anim) => FadeTransition(
                                        opacity: anim,
                                        child: child,
                                      ),
                                      child: Text(
                                        quantity.toString(),
                                        key: ValueKey<int>(quantity),
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: 15.sp,
                                          fontWeight: FontWeight.w600,
                                          color: textColor,
                                        ),
                                      ),
                                    ),
                                  ),
                                  _StepperButton(
                                    icon: Icons.add_rounded,
                                    color: textColor,
                                    onTap: () {
                                      HapticFeedback.selectionClick();
                                      setState(() => quantity++);
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 28.h),
                        Container(height: 1, color: borderColor),
                        SizedBox(height: 20.h),
                        _RevealOnScroll(
                          child: IntrinsicHeight(
                            child: Row(
                              children: [
                                _TrustBadge(
                                  icon: Icons.local_shipping_outlined,
                                  label: 'Free Shipping',
                                  accentColor: accentColor,
                                  textColor: subTextColor,
                                ),
                                VerticalDivider(color: borderColor, width: 1),
                                _TrustBadge(
                                  icon: Icons.autorenew_rounded,
                                  label: 'Easy Returns',
                                  accentColor: accentColor,
                                  textColor: subTextColor,
                                ),
                                VerticalDivider(color: borderColor, width: 1),
                                _TrustBadge(
                                  icon: Icons.verified_outlined,
                                  label: 'Authentic',
                                  accentColor: accentColor,
                                  textColor: subTextColor,
                                ),
                              ],
                            ),
                          ),
                        ),
                        Container(height: 1, color: borderColor),
                        _RevealOnScroll(
                          child: _ExpandableSection(
                            title: 'Details & Care',
                            body: widget.product.description,
                            textColor: textColor,
                            subTextColor: subTextColor,
                          ),
                        ),
                        Container(height: 1, color: borderColor),
                        _RevealOnScroll(
                          child: _ExpandableSection(
                            title: 'Shipping & Returns',
                            body:
                                'Orders ship within 1-2 business days. Returns are accepted within 30 days of delivery, provided the item is unused and in its original packaging.',
                            textColor: textColor,
                            subTextColor: subTextColor,
                          ),
                        ),
                        Container(height: 1, color: borderColor),
                        SizedBox(height: 36.h),
                        _RevealOnScroll(
                          child: _ReviewsSection(
                            rating: 4.8,
                            reviewCount: 124,
                            accentColor: accentColor,
                            textColor: textColor,
                            subTextColor: subTextColor,
                            borderColor: borderColor,
                          ),
                        ),
                        SizedBox(height: 24.h),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: EdgeInsets.fromLTRB(24.w, 14.h, 24.w, 14.h),
          decoration: BoxDecoration(
            color: cardColor,
            border: Border(top: BorderSide(color: borderColor)),
          ),
          child: Row(
            children: [
              GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  setState(() => isWishlisted = !isWishlisted);
                },
                child: Container(
                  width: 52.w,
                  height: 52.w,
                  decoration: BoxDecoration(
                    border: Border.all(color: borderColor),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      transitionBuilder: (child, anim) => ScaleTransition(scale: anim, child: child),
                      child: Icon(
                        isWishlisted ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                        key: ValueKey<bool>(isWishlisted),
                        color: isWishlisted ? accentColor : textColor,
                        size: 22.sp,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 14.w),
              Expanded(
                child: _PressableScale(
                  onTap: () {
                    HapticFeedback.mediumImpact();
                    _showAddedToBagNotice(buttonBg, buttonText);
                  },
                  child: Container(
                    height: 54.h,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: buttonBg,
                      borderRadius: BorderRadius.circular(28.r),
                    ),
                    child: CustomText(
                      text: 'ADD TO BAG',
                      color: buttonText,
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.4,
                    ),
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

class _GlassIconButton extends StatelessWidget {
  final IconData icon;
  final Color tint;
  final Color iconColor;
  final VoidCallback onTap;

  const _GlassIconButton({
    required this.icon,
    required this.tint,
    required this.iconColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ClipOval(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: Material(
          color: tint,
          child: InkWell(
            onTap: onTap,
            child: SizedBox(
              width: 38.w,
              height: 38.w,
              child: Icon(icon, size: 18.sp, color: iconColor),
            ),
          ),
        ),
      ),
    );
  }
}

class _StepperButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _StepperButton({required this.icon, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      customBorder: const CircleBorder(),
      onTap: onTap,
      child: SizedBox(
        width: 34.w,
        height: 38.h,
        child: Icon(icon, size: 16.sp, color: color),
      ),
    );
  }
}

class _RatingSummaryInline extends StatelessWidget {
  final double rating;
  final int reviewCount;
  final Color accentColor;
  final Color textColor;

  const _RatingSummaryInline({
    required this.rating,
    required this.reviewCount,
    required this.accentColor,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _StarRow(rating: rating, size: 14.sp, color: accentColor),
        SizedBox(width: 8.w),
        CustomText(
          text: '$rating ($reviewCount reviews)',
          fontSize: 12.sp,
          color: textColor,
        ),
      ],
    );
  }
}

class _StarRow extends StatelessWidget {
  final double rating;
  final double size;
  final Color color;

  const _StarRow({required this.rating, required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    final double rounded = (rating * 2).round() / 2;
    final int fullStars = rounded.floor();
    final bool hasHalf = (rounded - fullStars) == 0.5;
    final int emptyStars = 5 - fullStars - (hasHalf ? 1 : 0);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (int i = 0; i < fullStars; i++) Icon(Icons.star_rounded, size: size, color: color),
        if (hasHalf) Icon(Icons.star_half_rounded, size: size, color: color),
        for (int i = 0; i < emptyStars; i++) Icon(Icons.star_outline_rounded, size: size, color: color),
      ],
    );
  }
}

class _TrustBadge extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color accentColor;
  final Color textColor;

  const _TrustBadge({
    required this.icon,
    required this.label,
    required this.accentColor,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 18.h),
        child: Column(
          children: [
            Icon(icon, color: accentColor, size: 20.sp),
            SizedBox(height: 8.h),
            CustomText(
              text: label,
              fontSize: 10.5.sp,
              color: textColor,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _ExpandableSection extends StatefulWidget {
  final String title;
  final String body;
  final Color textColor;
  final Color subTextColor;

  const _ExpandableSection({
    required this.title,
    required this.body,
    required this.textColor,
    required this.subTextColor,
  });

  @override
  State<_ExpandableSection> createState() => _ExpandableSectionState();
}

class _ExpandableSectionState extends State<_ExpandableSection> {
  bool expanded = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: () => setState(() => expanded = !expanded),
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 18.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CustomText(
                  text: widget.title,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                  color: widget.textColor,
                ),
                AnimatedRotation(
                  turns: expanded ? 0.5 : 0,
                  duration: const Duration(milliseconds: 220),
                  child: Icon(Icons.expand_more_rounded, size: 20.sp, color: widget.textColor),
                ),
              ],
            ),
          ),
        ),
        AnimatedSize(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOut,
          child: expanded
              ? Padding(
                  padding: EdgeInsets.only(bottom: 18.h),
                  child: CustomText(
                    text: widget.body,
                    fontSize: 13.5.sp,
                    color: widget.subTextColor,
                    textAlign: TextAlign.justify,
                  ),
                )
              : const SizedBox(width: double.infinity, height: 0),
        ),
      ],
    );
  }
}

class _PressableScale extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;

  const _PressableScale({required this.child, required this.onTap});

  @override
  State<_PressableScale> createState() => _PressableScaleState();
}

class _PressableScaleState extends State<_PressableScale> {
  bool pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: (_) => setState(() => pressed = true),
      onTapUp: (_) => setState(() => pressed = false),
      onTapCancel: () => setState(() => pressed = false),
      child: AnimatedScale(
        scale: pressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: widget.child,
      ),
    );
  }
}

class _RevealOnScroll extends StatefulWidget {
  final Widget child;

  const _RevealOnScroll({required this.child});

  @override
  State<_RevealOnScroll> createState() => _RevealOnScrollState();
}

class _RevealOnScrollState extends State<_RevealOnScroll> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;
  final GlobalKey _key = GlobalKey();
  ScrollPosition? _position;
  bool _triggered = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 480));
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _slide = Tween<Offset>(begin: const Offset(0, 0.06), end: Offset.zero)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _position?.removeListener(_checkVisibility);
    _position = Scrollable.of(context).position;
    _position!.addListener(_checkVisibility);
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkVisibility());
  }

  @override
  void dispose() {
    _position?.removeListener(_checkVisibility);
    _controller.dispose();
    super.dispose();
  }

  void _checkVisibility() {
    if (_triggered || !mounted) return;
    final renderObject = _key.currentContext?.findRenderObject();
    if (renderObject is! RenderBox || !renderObject.attached) return;
    final double viewportHeight = MediaQuery.of(context).size.height;
    final double top = renderObject.localToGlobal(Offset.zero).dy;
    if (top < viewportHeight * 0.88) {
      _triggered = true;
      _controller.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(
        position: _slide,
        child: KeyedSubtree(key: _key, child: widget.child),
      ),
    );
  }
}

class _FloatingNotice extends StatelessWidget {
  final String text;
  final Color bgColor;
  final Color textColor;

  const _FloatingNotice({required this.text, required this.bgColor, required this.textColor});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 14.h),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(14.r),
          boxShadow: [
            BoxShadow(
              // ignore: deprecated_member_use
              color: Colors.black.withOpacity(0.18),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle_rounded, size: 16.sp, color: textColor),
            SizedBox(width: 8.w),
            Text(
              text,
              style: TextStyle(color: textColor, fontSize: 13.sp, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }
}

class _Review {
  final String name;
  final double rating;
  final String date;
  final String comment;
  final bool verified;
  final int helpfulCount;

  const _Review({
    required this.name,
    required this.rating,
    required this.date,
    required this.comment,
    required this.verified,
    required this.helpfulCount,
  });
}

const List<_Review> _mockReviews = [
  _Review(
    name: 'Amara J.',
    rating: 5,
    date: 'Aug 2026',
    comment: 'Feels exactly as premium as it looks in the photos. Packaging alone made it feel worth the price.',
    verified: true,
    helpfulCount: 18,
  ),
  _Review(
    name: 'Diego R.',
    rating: 5,
    date: 'Jul 2026',
    comment: 'Shipping was fast and the quality is noticeably better than similar items I have bought before.',
    verified: true,
    helpfulCount: 11,
  ),
  _Review(
    name: 'Priya S.',
    rating: 4,
    date: 'Jul 2026',
    comment: 'Very happy with it overall, only wish there were more color options.',
    verified: false,
    helpfulCount: 4,
  ),
];

const List<double> _ratingDistribution = [0.78, 0.15, 0.04, 0.02, 0.01];

class _ReviewsSection extends StatelessWidget {
  final double rating;
  final int reviewCount;
  final Color accentColor;
  final Color textColor;
  final Color subTextColor;
  final Color borderColor;

  const _ReviewsSection({
    required this.rating,
    required this.reviewCount,
    required this.accentColor,
    required this.textColor,
    required this.subTextColor,
    required this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomText(
          text: 'Ratings & Reviews',
          fontSize: 17.sp,
          fontWeight: FontWeight.w500,
          color: textColor,
        ),
        SizedBox(height: 20.h),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Column(
              children: [
                CustomText(
                  text: rating.toString(),
                  fontSize: 34.sp,
                  fontWeight: FontWeight.w300,
                  color: textColor,
                ),
                SizedBox(height: 4.h),
                _StarRow(rating: rating, size: 13.sp, color: accentColor),
                SizedBox(height: 4.h),
                CustomText(
                  text: '$reviewCount reviews',
                  fontSize: 11.sp,
                  color: subTextColor,
                ),
              ],
            ),
            SizedBox(width: 28.w),
            Expanded(
              child: Column(
                children: [
                  for (int i = 0; i < 5; i++)
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 3.h),
                      child: Row(
                        children: [
                          CustomText(
                            text: '${5 - i}',
                            fontSize: 10.sp,
                            color: subTextColor,
                          ),
                          SizedBox(width: 6.w),
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(3.r),
                              child: LinearProgressIndicator(
                                value: _ratingDistribution[i],
                                minHeight: 5.h,
                                backgroundColor: borderColor,
                                color: accentColor,
                              ),
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
        SizedBox(height: 28.h),
        for (final review in _mockReviews) ...[
          _ReviewCard(
            review: review,
            accentColor: accentColor,
            textColor: textColor,
            subTextColor: subTextColor,
          ),
          SizedBox(height: 20.h),
        ],
        Center(
          child: TextButton(
            onPressed: () {},
            style: TextButton.styleFrom(
              foregroundColor: textColor,
              padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 18.w),
            ),
            child: CustomText(
              text: 'See all $reviewCount reviews',
              fontSize: 12.5.sp,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.3,
              color: textColor,
            ),
          ),
        ),
      ],
    );
  }
}

class _ReviewCard extends StatelessWidget {
  final _Review review;
  final Color accentColor;
  final Color textColor;
  final Color subTextColor;

  const _ReviewCard({
    required this.review,
    required this.accentColor,
    required this.textColor,
    required this.subTextColor,
  });

  @override
  Widget build(BuildContext context) {
    final initials = review.name.trim().isNotEmpty ? review.name.trim()[0].toUpperCase() : '?';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 34.w,
              height: 34.w,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                // ignore: deprecated_member_use
                color: accentColor.withOpacity(0.14),
                shape: BoxShape.circle,
              ),
              child: Text(
                initials,
                style: TextStyle(
                  color: accentColor,
                  fontWeight: FontWeight.w600,
                  fontSize: 13.sp,
                ),
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CustomText(
                        text: review.name,
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w600,
                        color: textColor,
                      ),
                      if (review.verified) ...[
                        SizedBox(width: 6.w),
                        Icon(Icons.verified_rounded, size: 13.sp, color: accentColor),
                      ],
                    ],
                  ),
                  SizedBox(height: 2.h),
                  Row(
                    children: [
                      _StarRow(rating: review.rating, size: 11.sp, color: accentColor),
                      SizedBox(width: 8.w),
                      CustomText(text: review.date, fontSize: 10.5.sp, color: subTextColor),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        SizedBox(height: 10.h),
        CustomText(
          text: review.comment,
          fontSize: 13.sp,
          color: subTextColor,
          textAlign: TextAlign.justify,
        ),
        SizedBox(height: 10.h),
        Row(
          children: [
            Icon(Icons.thumb_up_outlined, size: 13.sp, color: subTextColor),
            SizedBox(width: 6.w),
            CustomText(
              text: 'Helpful (${review.helpfulCount})',
              fontSize: 11.sp,
              color: subTextColor,
            ),
          ],
        ),
      ],
    );
  }
}