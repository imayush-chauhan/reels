import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ReelsInitialLoader extends StatelessWidget {
  const ReelsInitialLoader({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: Shimmer.fromColors(
        baseColor: Colors.grey.shade900,
        highlightColor: Colors.grey.shade700,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Full background
            Container(color: Colors.grey[900]),

            // Bottom info skeleton
            Positioned(
              left: 16,
              bottom: MediaQuery.of(context).padding.bottom + 100,
              right: 80,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Avatar + username row
                  Row(
                    children: [
                      _ShimmerBox(width: 38, height: 38, borderRadius: 19),
                      const SizedBox(width: 10),
                      _ShimmerBox(width: 120, height: 14, borderRadius: 6),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _ShimmerBox(width: double.infinity, height: 13, borderRadius: 6),
                  const SizedBox(height: 6),
                  _ShimmerBox(width: 200, height: 13, borderRadius: 6),
                  const SizedBox(height: 12),
                  _ShimmerBox(width: 140, height: 12, borderRadius: 6),
                ],
              ),
            ),

            // Right action bar skeleton
            Positioned(
              right: 16,
              bottom: MediaQuery.of(context).padding.bottom + 100,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(4, (i) => Padding(
                  padding: const EdgeInsets.only(bottom: 24),
                  child: _ShimmerBox(width: 36, height: 36, borderRadius: 18),
                )),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ShimmerBox extends StatelessWidget {
  final double width;
  final double height;
  final double borderRadius;

  const _ShimmerBox({
    required this.width,
    required this.height,
    this.borderRadius = 4,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    );
  }
}
