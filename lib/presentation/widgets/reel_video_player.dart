import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:video_player/video_player.dart';
import 'package:reels/domain/entities/reel_entity.dart';
import 'package:reels/presentation/viewmodels/video_controller_state.dart';

class ReelVideoPlayer extends StatelessWidget {
  final ReelEntity reel;
  final VideoControllerState? controllerState;

  const ReelVideoPlayer({
    super.key,
    required this.reel,
    required this.controllerState,
  });

  @override
  Widget build(BuildContext context) {
    final status = controllerState?.status ?? VideoLoadingStatus.idle;
    final controller = controllerState?.controller;

    return switch (status) {
      VideoLoadingStatus.ready when controller != null =>
        _VideoReadyLayer(controller: controller),
      VideoLoadingStatus.error => _VideoErrorLayer(reel: reel),
      _ => _VideoLoadingLayer(reel: reel),
    };
  }
}

// ─── Ready: actual video ──────────────────────────────────────────────────────

class _VideoReadyLayer extends StatelessWidget {
  final VideoPlayerController controller;

  const _VideoReadyLayer({required this.controller});

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: FittedBox(
        fit: BoxFit.cover,
        child: SizedBox(
          width: controller.value.size.width,
          height: controller.value.size.height,
          child: VideoPlayer(controller),
        ),
      ),
    );
  }
}

// ─── Loading: thumbnail + shimmer ────────────────────────────────────────────

class _VideoLoadingLayer extends StatelessWidget {
  final ReelEntity reel;

  const _VideoLoadingLayer({required this.reel});

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        if (reel.thumbnailUrl.isNotEmpty)
          CachedNetworkImage(
            imageUrl: reel.thumbnailUrl,
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
            errorWidget: (_, __, ___) => const ColoredBox(color: Colors.black),
          )
        else
          const ColoredBox(color: Colors.black12),
        // Subtle loading indicator
        const Positioned(
          bottom: 200,
          left: 0,
          right: 0,
          child: Center(
            child: SizedBox(
              width: 28,
              height: 28,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: Colors.white60,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Error layer ─────────────────────────────────────────────────────────────

class _VideoErrorLayer extends StatelessWidget {
  final ReelEntity reel;

  const _VideoErrorLayer({required this.reel});

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        if (reel.thumbnailUrl.isNotEmpty)
          ColorFiltered(
            colorFilter: const ColorFilter.mode(
              Colors.black38,
              BlendMode.darken,
            ),
            child: CachedNetworkImage(
              imageUrl: reel.thumbnailUrl,
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
              errorWidget: (_, __, ___) => const ColoredBox(color: Colors.black),
            ),
          )
        else
          const ColoredBox(color: Colors.black),
        const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.wifi_off_rounded, color: Colors.white54, size: 36),
              SizedBox(height: 8),
              Text(
                'Could not load video',
                style: TextStyle(color: Colors.white54, fontSize: 13),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
