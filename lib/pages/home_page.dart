import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:nhac/components/home/home_content.dart';
import 'package:nhac/components/profile_content.dart';
import 'package:nhac/components/botoes/botao_nhac.dart';
import 'package:nhac/controllers/cart_provider.dart';
import 'package:nhac/controllers/endereco_provider.dart';
import 'package:nhac/controllers/user_provider.dart';
import 'package:nhac/pages/carrinho_page.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  int _selectedIndex = 0;
  late PageController _pageController;
  final ScrollController _scrollController = ScrollController();
  bool _isScrolledDown = false;
  late final AnimationController _cartBarController;
  final NumberFormat currencyFormat =
      NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _selectedIndex);
    _cartBarController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    if (_selectedIndex == 1) {
      _cartBarController.forward();
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userProvider = context.read<UserProvider>();
      final cartProvider = context.read<CartProvider>();
      final enderecoProvider = context.read<EnderecoProvider>();

      userProvider.iniciarEscutaUsuario();
      cartProvider.iniciarEscutaCarrinho();
      enderecoProvider.iniciarEscutaEnderecos();

      cartProvider.addListener(_onCartChanged);
    });
  }

  void _onCartChanged() {
    if (!mounted) return;

    if (_selectedIndex == 1) {
      final cart = context.read<CartProvider>();
      if (cart.itens.isNotEmpty) {
        if (_cartBarController.status != AnimationStatus.forward &&
            _cartBarController.value != 1.0) {
          _cartBarController.forward();
        }
      } else {
        if (_cartBarController.status != AnimationStatus.reverse &&
            _cartBarController.value != 0.0) {
          _cartBarController.animateBack(0,
              duration: const Duration(milliseconds: 150));
        }
      }
    }
  }

  @override
  void dispose() {
    try {
      context.read<CartProvider>().removeListener(_onCartChanged);
    } catch (_) {}
    _pageController.dispose();
    _scrollController.dispose();
    _cartBarController.dispose();
    super.dispose();
  }

  void _scrollToTop() {
    _scrollController.animateTo(
      0.0,
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeOutCubic,
    );
  }

  IconData _getIconForIndex(int index) {
    switch (index) {
      case 0:
        return Icons.house_outlined;
      case 1:
        return Icons.shopping_cart_outlined;
      case 2:
        return Icons.shopping_bag_outlined;
      case 3:
        return Icons.person_outline;
      default:
        return Icons.house_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      extendBody: true,
      backgroundColor: const Color(0xFFFFE7E5),
      body: NotificationListener<ScrollNotification>(
        onNotification: (notification) {
          if (notification is ScrollUpdateNotification &&
              notification.metrics.axis == Axis.vertical) {
            if (notification.metrics.pixels > 150 && !_isScrolledDown) {
              setState(() {
                _isScrolledDown = true;
              });
            } else if (notification.metrics.pixels <= 150 && _isScrolledDown) {
              setState(() {
                _isScrolledDown = false;
              });
            }
          }
          return false;
        },
        child: PrimaryScrollController(
          controller: _scrollController,
          child: Stack(
            children: [
              PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (index) {
                  setState(() {
                    _selectedIndex = index;
                  });
                },
                children: [
                  const HomeContent(),
                  CarrinhoPage(isActive: _selectedIndex == 1),
                  _buildPlaceholderContent(2),
                  const ProfileContent(),
                ],
              ),
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                height: 40.h,
                child: IgnorePointer(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          const Color(0xFFFFE7E5).withValues(alpha: 0.7),
                          const Color(0xFFFFE7E5).withValues(alpha: 0.6),
                          const Color(0xFFFFE7E5).withValues(alpha: 0.0),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                height: 50.h + bottomPadding,
                child: IgnorePointer(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          const Color(0xFFFFE7E5).withValues(alpha: 0.0),
                          const Color(0xFFFFE7E5).withValues(alpha: 0.6),
                          const Color(0xFFFFE7E5),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              AnimatedPositioned(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOutCubic,
                bottom: _isScrolledDown
                    ? (bottomPadding + 10.h + 75.h + 16.h)
                    : (bottomPadding + 10.h + 12.5.h),
                right: 24.w + (75.w / 2) - 25.w,
                child: GestureDetector(
                  onTap: _isScrolledDown ? _scrollToTop : null,
                  child: Container(
                    width: 50.w,
                    height: 50.w,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF6961),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFFF6961).withValues(alpha: 0.3),
                          blurRadius: 10.r,
                          offset: Offset(0, 4.h),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.arrow_upward_rounded,
                      color: Colors.white,
                      size: 24.sp,
                    ),
                  ),
                ),
              ),
              AnimatedBuilder(
                animation: _cartBarController,
                builder: (context, child) {
                  final t =
                      Curves.easeOutCubic.transform(_cartBarController.value);
                  final baseBottom = bottomPadding + 95.h;
                  final interpolatedBottom = (baseBottom - 80.h) + (80.h * t);
                  final scaleX = 0.2 + 0.8 * t;
                  final opacity = t.clamp(0.0, 1.0);

                  if (t == 0) return const SizedBox.shrink();

                  return Positioned(
                    bottom: interpolatedBottom,
                    left: 24.w,
                    right: 24.w,
                    child: Transform.scale(
                      scaleX: scaleX,
                      scaleY: 1.0,
                      child: Opacity(
                        opacity: opacity,
                        child: Consumer<CartProvider>(
                          builder: (context, cart, _) => _buildCartTotalBar(
                            cart.valorTotal,
                            onPressed: () {
                              if (_selectedIndex == 1) {
                                context.push('/checkout');
                              } else {
                                context.push('/carrinho');
                              }
                            },
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
              AnimatedPositioned(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOutCubic,
                bottom: bottomPadding + 10.h,
                left: _isScrolledDown
                    ? MediaQuery.of(context).size.width - 24.w - 75.w
                    : 24.w,
                right: 24.w,
                child: AnimatedBuilder(
                  animation: _cartBarController,
                  builder: (context, child) {
                    final t = _cartBarController.value;
                    final bounceAmount = math.sin(t * math.pi) * 8.h;
                    final isReversing =
                        _cartBarController.status == AnimationStatus.reverse;
                    final offsetY = isReversing ? bounceAmount : -bounceAmount;
                    return Transform.translate(
                      offset: Offset(0, offsetY),
                      child: child,
                    );
                  },
                  child: _buildDynamicNavBar(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholderContent(int index) {
    return Stack(
      children: [
        Center(
          child: Text(
            'tela $index',
            style: TextStyle(color: const Color(0xFF5D201C), fontSize: 24.sp),
          ),
        ),
        Positioned(
          top: 257.h,
          left: 70.w,
          width: 232.w,
          height: 200.h,
          child: const Image(
            image: AssetImage('assets/construction.gif'),
            fit: BoxFit.fitHeight,
          ),
        ),
      ],
    );
  }

  Widget _buildDynamicNavBar() {
    return GestureDetector(
      onTap: () {
        if (_isScrolledDown) {
          _scrollToTop();
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        height: 75.h,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(50.r),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF5D201C).withValues(alpha: 0.1),
              blurRadius: 15.r,
              offset: Offset(0, 9.h),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(50.r),
          child: AnimatedCrossFade(
            duration: const Duration(milliseconds: 300),
            crossFadeState: _isScrolledDown
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            alignment: Alignment.center,
            layoutBuilder:
                (topChild, topChildKey, bottomChild, bottomChildKey) {
              return Stack(
                alignment: Alignment.center,
                children: [
                  Positioned(
                    key: bottomChildKey,
                    top: 0,
                    bottom: 0,
                    child: bottomChild,
                  ),
                  Positioned(
                    key: topChildKey,
                    child: topChild,
                  ),
                ],
              );
            },
            firstChild: SizedBox(
              width: MediaQuery.of(context).size.width - 48.w,
              height: 75.h,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const NeverScrollableScrollPhysics(),
                child: SizedBox(
                  width: MediaQuery.of(context).size.width - 48.w,
                  height: 75.h,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildNavItem(
                          icon: Icons.house_outlined, label: 'Home', index: 0),
                      _buildNavItem(
                          icon: Icons.shopping_cart_outlined,
                          label: 'Carrinho',
                          index: 1),
                      _buildNavItem(
                          icon: Icons.shopping_bag_outlined,
                          label: 'N sei',
                          index: 2),
                      _buildNavItem(
                          icon: Icons.person_outline,
                          label: 'Perfil',
                          index: 3),
                    ],
                  ),
                ),
              ),
            ),
            secondChild: SizedBox(
              width: 75.w,
              height: 75.h,
              child: Center(
                child: Icon(
                  _getIconForIndex(_selectedIndex),
                  size: 28.sp,
                  color: const Color(0xFFFF6961),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
      {required IconData icon, required String label, required int index}) {
    final isSelected = _selectedIndex == index;

    return GestureDetector(
      onTap: () {
        final oldIndex = _selectedIndex;
        setState(() {
          _selectedIndex = index;
        });
        _pageController.animateToPage(
          index,
          duration: const Duration(milliseconds: 400),
          curve: Curves.fastOutSlowIn,
        );

        if (index == 1) {
          final cart = context.read<CartProvider>();
          if (cart.itens.isNotEmpty) {
            _cartBarController.forward();
          }
        } else if (oldIndex == 1) {
          _cartBarController.animateBack(0,
              duration: const Duration(milliseconds: 150));
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 400),
        curve: Curves.fastOutSlowIn,
        padding: EdgeInsets.symmetric(
          horizontal: isSelected ? 20.w : 12.w,
          vertical: 12.h,
        ),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFFFEBD9) : Colors.transparent,
          borderRadius: BorderRadius.circular(50.r),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            index == 1
                ? Selector<CartProvider, int>(
                    selector: (context, provider) => provider.totalDeUnidades,
                    builder: (context, count, child) {
                      return Badge(
                        label: count > 0 ? Text(count.toString()) : null,
                        isLabelVisible: count > 0,
                        backgroundColor: const Color(0xFFFF6961),
                        child: Icon(
                          icon,
                          size: 28.sp,
                          color: isSelected
                              ? const Color(0xFFFF6961)
                              : const Color(0xFFA0A0A0),
                        ),
                      );
                    },
                  )
                : Icon(
                    icon,
                    size: 28.sp,
                    color: isSelected
                        ? const Color(0xFFFF6961)
                        : const Color(0xFFA0A0A0),
                  ),
            AnimatedSize(
              duration: const Duration(milliseconds: 400),
              curve: Curves.fastOutSlowIn,
              child: SizedBox(
                width: isSelected ? null : 0,
                child: isSelected
                    ? Padding(
                        padding: EdgeInsets.only(left: 8.w),
                        child: Text(
                          label,
                          maxLines: 1,
                          overflow: TextOverflow.clip,
                          style: TextStyle(
                            color: const Color(0xFFFF6961),
                            fontWeight: FontWeight.w600,
                            fontSize: 15.sp,
                          ),
                        ),
                      )
                    : const SizedBox.shrink(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCartTotalBar(double total, {required VoidCallback onPressed}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(50.r),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF5D201C).withValues(alpha: 0.1),
            blurRadius: 15.r,
            offset: Offset(0, 9.h),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Total com frete',
                    style: TextStyle(color: Colors.grey, fontSize: 12.sp)),
                _AnimatedTotalText(
                    total: total, currencyFormat: currencyFormat),
              ],
            ),
          ),
          BotaoNhac(
            label: 'Continuar',
            onPressed: onPressed,
            fontSize: 15.sp,
          ),
        ],
      ),
    );
  }
}

class _AnimatedTotalText extends StatefulWidget {
  final double total;
  final NumberFormat currencyFormat;

  const _AnimatedTotalText({
    required this.total,
    required this.currencyFormat,
  });

  @override
  State<_AnimatedTotalText> createState() => _AnimatedTotalTextState();
}

class _AnimatedTotalTextState extends State<_AnimatedTotalText>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _bounceAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _bounceAnimation = Tween<double>(begin: 0.0, end: 0.0).animate(_controller);
  }

  @override
  void didUpdateWidget(_AnimatedTotalText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.total != oldWidget.total) {
      final isIncreasing = widget.total > oldWidget.total;

      final double bounceDist = isIncreasing ? -4.0 : 4.0;

      _bounceAnimation = TweenSequence<double>([
        TweenSequenceItem(
          tween: Tween(begin: 0.0, end: bounceDist)
              .chain(CurveTween(curve: Curves.easeOutCubic)),
          weight: 30,
        ),
        TweenSequenceItem(
          tween: Tween(begin: bounceDist, end: 0.0)
              .chain(CurveTween(curve: Curves.elasticOut)),
          weight: 70,
        ),
      ]).animate(_controller);

      _controller.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _bounceAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _bounceAnimation.value),
          child: Text(
            widget.currencyFormat.format(widget.total),
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16.sp,
              color: Colors.black,
            ),
          ),
        );
      },
    );
  }
}
