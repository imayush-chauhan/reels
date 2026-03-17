import 'package:flutter/material.dart';
import 'package:reels/domain/entities/reel_entity.dart';
import 'package:reels/presentation/viewmodels/video_controller_state.dart';
import 'package:reels/presentation/widgets/reel_video_player.dart';
import 'package:reels/presentation/widgets/reel_action_bar.dart';
import 'package:reels/presentation/widgets/reel_info_overlay.dart';

class ReelPageItem extends StatefulWidget {
  final ReelEntity reel;
  final VideoControllerState? controllerState;
  final bool isMuted;
  final VoidCallback onLike;
  final VoidCallback onMute;

  const ReelPageItem({
    super.key,
    required this.reel,
    required this.controllerState,
    required this.isMuted,
    required this.onLike,
    required this.onMute,
  });

  @override
  State<ReelPageItem> createState() => _ReelPageItemState();
}

class _ReelPageItemState extends State<ReelPageItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _doubleTapAnimController;
  bool _showHeart = false;
  Offset _heartPosition = Offset.zero;

  @override
  void initState() {
    super.initState();
    _doubleTapAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          setState(() => _showHeart = false);
          _doubleTapAnimController.reset();
        }
      });
  }

  @override
  void dispose() {
    _doubleTapAnimController.dispose();
    super.dispose();
  }

  void _onDoubleTap(TapDownDetails details) {
    if (!widget.reel.isLiked) {
      widget.onLike();
    }
    setState(() {
      _showHeart = true;
      _heartPosition = details.localPosition;
    });
    _doubleTapAnimController.forward();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onDoubleTapDown: _onDoubleTap,
      onDoubleTap: () {}, // required for onDoubleTapDown to fire
      onTap: _handleSingleTap,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // ── Video Layer ──────────────────────────────────────────────────
          ReelVideoPlayer(
            reel: widget.reel,
            controllerState: widget.controllerState,
          ),

          // ── Bottom Gradient ──────────────────────────────────────────────
          const _BottomGradient(),

          // ── Info Overlay (left side) ─────────────────────────────────────
          Positioned(
            left: 0,
            right: 72,
            bottom: 0,
            child: ReelInfoOverlay(reel: widget.reel),
          ),

          // ── Action Bar (right side) ───────────────────────────────────────
          Positioned(
            right: 8,
            bottom: 80,
            child: ReelActionBar(
              reel: widget.reel,
              isMuted: widget.isMuted,
              onLike: widget.onLike,
              onMute: widget.onMute,
            ),
          ),

          // ── Double Tap Heart Animation ────────────────────────────────────
          if (_showHeart)
            _DoubleTapHeart(
              position: _heartPosition,
              animation: _doubleTapAnimController,
            ),
        ],
      ),
    );
  }

  void _handleSingleTap() {
    final controller = widget.controllerState?.controller;
    if (controller == null) return;
    if (controller.value.isPlaying) {
      controller.pause();
    } else {
      controller.play();
    }
  }
}

// ─── Bottom Gradient ──────────────────────────────────────────────────────────

class _BottomGradient extends StatelessWidget {
  const _BottomGradient();

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      height: MediaQuery.of(context).size.height * 0.45,
      child: IgnorePointer(
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
              colors: [
                Color(0xCC000000),
                Color(0x88000000),
                Colors.transparent,
              ],
              stops: [0.0, 0.5, 1.0],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Double Tap Heart ─────────────────────────────────────────────────────────

class _DoubleTapHeart extends StatelessWidget {
  final Offset position;
  final AnimationController animation;

  const _DoubleTapHeart({
    required this.position,
    required this.animation,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: position.dx - 50,
      top: position.dy - 50,
      child: IgnorePointer(
        child: AnimatedBuilder(
          animation: animation,
          builder: (_, __) {
            final scale = Tween<double>(begin: 0.3, end: 1.5)
                .chain(CurveTween(curve: Curves.elasticOut))
                .evaluate(animation);
            final opacity = Tween<double>(begin: 1.0, end: 0.0)
                .chain(CurveTween(curve: const Interval(0.6, 1.0)))
                .evaluate(animation);

            return Opacity(
              opacity: opacity,
              child: Transform.scale(
                scale: scale,
                child: const Icon(
                  Icons.favorite,
                  color: Colors.white,
                  size: 100,
                  shadows: [
                    Shadow(blurRadius: 20, color: Colors.black54),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
