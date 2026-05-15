import 'package:shimmer/shimmer.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class BannerItem {
  const BannerItem({
    required this.imageUrl,
  });

  final String imageUrl;
}

class HomeBannerCarousel extends StatefulWidget {
  const HomeBannerCarousel({super.key});

  @override
  State<HomeBannerCarousel> createState() => _HomeBannerCarouselState();
}

class _HomeBannerCarouselState extends State<HomeBannerCarousel> {
  final PageController _pageController = PageController(viewportFraction: 0.9);
  int _currentPage = 0;
  Timer? _timer;

  static const List<BannerItem> _banners = [
    BannerItem(
      imageUrl: 'https://scontent-gru1-2.cdninstagram.com/v/t51.82787-15/670924780_17901783585428033_4922530998420665552_n.jpg?stp=dst-jpg_e35_tt6&_nc_cat=100&ig_cache_key=Mzg4ODQ4ODk3NTM4MDEwNDc1Mg%3D%3D.3-ccb7-5&ccb=7-5&_nc_sid=58cdad&efg=eyJ2ZW5jb2RlX3RhZyI6IkNBUk9VU0VMX0lURU0ueHBpZHMuMTIyNC5zZHIucmVndWxhcl9waG90by5DMyJ9&_nc_ohc=i8JzVpFQUFAQ7kNvwF-S-RN&_nc_oc=AdpHGEJWLmKGv24wrEF7Cpn4A-FV2aJEJMMeDkzJz0aV0U1BebBwJyBfunIICr0s1RSykpsvdarGmVAxoTlk1mvk&_nc_ad=z-m&_nc_cid=0&_nc_zt=23&_nc_ht=scontent-gru1-2.cdninstagram.com&_nc_gid=qYcUt4AEiM7d57vg9kf2_Q&_nc_ss=7a22e&oh=00_Af7AP5fnRqXKRPAOWhRue9FnkfAlIBNiX58AU9lZ2V5atg&oe=6A013FCD',
    ),
    BannerItem(
      imageUrl: 'https://images.unsplash.com/photo-1510812431401-41d2bd2722f3?w=800',
    ),
    BannerItem(
      imageUrl: 'https://images.unsplash.com/photo-1610348725531-843dff563e2c?w=800',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _startAutoPlay();
  }

  void _startAutoPlay() {
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (_pageController.hasClients) {
        int nextPage = _currentPage + 1;
        if (nextPage >= _banners.length) {
          nextPage = 0;
        }
        _pageController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeInOutCubic,
        );
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 180.0,
          child: GestureDetector(
            onPanDown: (_) => _timer?.cancel(),
            child: PageView.builder(
              controller: _pageController,
              clipBehavior: Clip.none,
              physics: const BouncingScrollPhysics(),
              itemCount: _banners.length,
              onPageChanged: (index) => setState(() => _currentPage = index),
              itemBuilder: (context, index) {
                final banner = _banners[index];
                return _BannerCard(banner: banner);
              },
            ),
          ),
        ),
        const SizedBox(height: 12.0),
        _DotsIndicator(
          count: _banners.length,
          currentIndex: _currentPage,
        ),
      ],
    );
  }
}

class _BannerCard extends StatelessWidget {
  const _BannerCard({required this.banner});

  final BannerItem banner;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20.0),
        child: CachedNetworkImage(
          imageUrl: banner.imageUrl,
          fit: BoxFit.cover,
          width: double.infinity,
          placeholder: (context, url) => Shimmer.fromColors(
            baseColor: Colors.grey.shade300,
            highlightColor: Colors.grey.shade100,
            child: Container(
              color: Colors.white,
              width: double.infinity,
              height: double.infinity,
            ),
          ),
          errorWidget: (context, url, error) => Container(
            color: Colors.grey.shade200,
            child: const Icon(Icons.error),
          ),
        ),
      ),
    );
  }
}

class _DotsIndicator extends StatelessWidget {
  const _DotsIndicator({
    required this.count,
    required this.currentIndex,
  });

  final int count;
  final int currentIndex;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (index) {
        final isActive = index == currentIndex;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          margin: const EdgeInsets.symmetric(horizontal: 3.0),
          width: isActive ? 20.0 : 6.0,
          height: 6.0,
          decoration: BoxDecoration(
            color: isActive
                ? const Color(0xFF5D201C)
                : const Color(0xFF5D201C).withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(3.0),
          ),
        );
      }),
    );
  }
}
