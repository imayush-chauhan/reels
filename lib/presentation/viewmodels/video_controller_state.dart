import 'package:video_player/video_player.dart';

enum VideoLoadingStatus { idle, loading, ready, error }

class VideoControllerState {
  final VideoPlayerController? controller;
  final VideoLoadingStatus status;
  final String? errorMessage;

  const VideoControllerState({
    this.controller,
    this.status = VideoLoadingStatus.idle,
    this.errorMessage,
  });

  bool get isReady =>
      status == VideoLoadingStatus.ready && controller != null;

  VideoControllerState copyWith({
    VideoPlayerController? controller,
    VideoLoadingStatus? status,
    String? errorMessage,
  }) {
    return VideoControllerState(
      controller: controller ?? this.controller,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
