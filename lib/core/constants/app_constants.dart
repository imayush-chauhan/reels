class AppConstants {
  AppConstants._();

  // Firestore
  static const String reelsCollection = 'reels';
  static const int reelsPageSize = 10;

  // Video Preloading
  static const int preloadAheadCount = 3;
  static const int preloadBehindCount = 1;

  // Cache
  static const String videoCacheDir = 'video_cache';
  static const int maxCachedVideos = 20;
  static const int maxCacheSizeBytes = 500 * 1024 * 1024; // 500 MB

  // UI
  static const double likeIconSize = 32.0;
  static const double actionIconSize = 28.0;
  static const double usernameTextSize = 14.0;
  static const double captionTextSize = 13.0;

  // Animation durations
  static const Duration likeAnimationDuration = Duration(milliseconds: 300);
  static const Duration fadeInDuration = Duration(milliseconds: 400);
}
