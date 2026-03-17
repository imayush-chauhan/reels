import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class ReelAvatar extends StatelessWidget {
  final String imageUrl;
  final double radius;

  const ReelAvatar({
    super.key,
    required this.imageUrl,
    this.radius = 20,
  });

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: radius,
      backgroundColor: Colors.white24,
      child: ClipOval(
        child: imageUrl.isNotEmpty
            ? CachedNetworkImage(
                imageUrl: imageUrl,
                width: radius * 2,
                height: radius * 2,
                fit: BoxFit.cover,
                errorWidget: (_, __, ___) => _placeholder(),
              )
            : _placeholder(),
      ),
    );
  }

  Widget _placeholder() {
    return Container(
      width: radius * 2,
      height: radius * 2,
      color: Colors.white12,
      child: Icon(
        Icons.person,
        size: radius,
        color: Colors.white54,
      ),
    );
  }
}
