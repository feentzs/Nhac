import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class HomeSkeleton extends StatelessWidget {
  const HomeSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16.0),

            Row(
              children: [
                _buildCircleSkeleton(40),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildBoxSkeleton(width: 80, height: 10),
                    const SizedBox(height: 6),
                    _buildBoxSkeleton(width: 150, height: 14),
                  ],
                )
              ],
            ),
            const SizedBox(height: 24.0),

            _buildBoxSkeleton(width: double.infinity, height: 50, borderRadius: 50),
            const SizedBox(height: 24.0),

            _buildBoxSkeleton(width: double.infinity, height: 180, borderRadius: 20),
            const SizedBox(height: 32.0),
  
            _buildBoxSkeleton(width: 200, height: 20),
            const SizedBox(height: 16.0),
            Row(
              children: [
                _buildProductCardSkeleton(),
                const SizedBox(width: 16),
                _buildProductCardSkeleton(),
              ],
            ),
            const SizedBox(height: 32.0),

            _buildBoxSkeleton(width: 180, height: 20),
            const SizedBox(height: 16.0),
            Row(
              children: [
                _buildProductCardSkeleton(),
                const SizedBox(width: 16),
                _buildProductCardSkeleton(),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBoxSkeleton({double? width, double? height, double borderRadius = 8}) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
    );
  }

  Widget _buildCircleSkeleton(double size) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Container(
        width: size,
        height: size,
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
        ),
      ),
    );
  }

  Widget _buildProductCardSkeleton() {
    return Container(
      width: 160,
      padding: const EdgeInsets.all(0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildBoxSkeleton(width: 160, height: 120, borderRadius: 20),
          const SizedBox(height: 12),
          _buildBoxSkeleton(width: 120, height: 14),
          const SizedBox(height: 6),
          _buildBoxSkeleton(width: 60, height: 12),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildBoxSkeleton(width: 50, height: 16),
              _buildCircleSkeleton(24),
            ],
          )
        ],
      ),
    );
  }
}
