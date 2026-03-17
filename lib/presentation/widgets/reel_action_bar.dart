import 'package:flutter/material.dart';
import 'package:reels/core/utils/format_utils.dart';
import 'package:reels/domain/entities/reel_entity.dart';
import 'package:reels/presentation/widgets/reel_avatar.dart';

class ReelActionBar extends StatelessWidget {
  final ReelEntity reel;
  final bool isMuted;
  final VoidCallback onLike;
  final VoidCallback onMute;

  const ReelActionBar({
    super.key,
    required this.reel,
    required this.isMuted,
    required this.onLike,
    required this.onMute,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // ── Like ────────────────────────────────────────────────────────────
        _LikeButton(
          isLiked: reel.isLiked,
          likesCount: reel.likesCount,
          onLike: onLike,
        ),

        const SizedBox(height: 20),

        // ── Comment ─────────────────────────────────────────────────────────
        _ActionButton(
          icon: Icons.chat_bubble_rounded,
          label: FormatUtils.formatCount(reel.commentsCount),
          onTap: () {},
        ),

        const SizedBox(height: 20),

        // ── Share ────────────────────────────────────────────────────────────
        _ActionButton(
          icon: Icons.reply_rounded,
          label: FormatUtils.formatCount(reel.sharesCount),
          mirrorIcon: true,
          onTap: () {},
        ),

        const SizedBox(height: 20),

        // ── Mute ─────────────────────────────────────────────────────────────
        _ActionButton(
          icon: isMuted ? Icons.volume_off_rounded : Icons.volume_up_rounded,
          label: '',
          onTap: onMute,
        ),

        const SizedBox(height: 24),

        // ── Spinning vinyl record ─────────────────────────────────────────────
        _SpinningVinyl(imageUrl: reel.avatarUrl),
      ],
    );
  }
}

// ─── Like button with animated heart ─────────────────────────────────────────

class _LikeButton extends StatefulWidget {
  final bool isLiked;
  final int likesCount;
  final VoidCallback onLike;

  const _LikeButton({
    required this.isLiked,
    required this.likesCount,
    required this.onLike,
  });

  @override
  State<_LikeButton> createState() => _LikeButtonState();
}

class _LikeButtonState extends State<_LikeButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _scaleAnimation = TweenSequence([
      TweenSequenceItem(
          tween: Tween<double>(begin: 1.0, end: 1.4)
              .chain(CurveTween(curve: Curves.easeOut)),
          weight: 50),
      TweenSequenceItem(
          tween: Tween<double>(begin: 1.4, end: 1.0)
              .chain(CurveTween(curve: Curves.easeIn)),
          weight: 50),
    ]).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap() {
    _controller.forward(from: 0);
    widget.onLike();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleTap,
      child: Column(
        children: [
          ScaleTransition(
            scale: _scaleAnimation,
            child: Icon(
              widget.isLiked ? Icons.favorite : Icons.favorite_border,
              color: widget.isLiked ? Colors.red : Colors.white,
              size: 34,
              shadows: const [Shadow(blurRadius: 4, color: Colors.black54)],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            FormatUtils.formatCount(widget.likesCount),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              shadows: [Shadow(blurRadius: 4, color: Colors.black54)],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Generic icon + label action button ──────────────────────────────────────

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool mirrorIcon;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.mirrorIcon = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Transform(
            alignment: Alignment.center,
            transform: mirrorIcon
                ? (Matrix4.identity()..scale(-1.0, 1.0, 1.0))
                : Matrix4.identity(),
            child: Icon(
              icon,
              color: Colors.white,
              size: 30,
              shadows: const [Shadow(blurRadius: 4, color: Colors.black54)],
            ),
          ),
          if (label.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
                shadows: [Shadow(blurRadius: 4, color: Colors.black54)],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ─── Spinning vinyl / disc ────────────────────────────────────────────────────

class _SpinningVinyl extends StatefulWidget {
  final String imageUrl;
  const _SpinningVinyl({required this.imageUrl});

  @override
  State<_SpinningVinyl> createState() => _SpinningVinylState();
}

class _SpinningVinylState extends State<_SpinningVinyl>
    with SingleTickerProviderStateMixin {
  late final AnimationController _rotationController;

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
  }

  @override
  void dispose() {
    _rotationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RotationTransition(
      turns: _rotationController,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white24, width: 3),
        ),
        child: ClipOval(
          child: ReelAvatar(imageUrl: widget.imageUrl, radius: 22),
        ),
      ),
    );
  }
}
