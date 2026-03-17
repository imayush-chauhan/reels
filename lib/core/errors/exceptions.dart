class FirestoreException implements Exception {
  final String message;
  const FirestoreException([this.message = 'Firestore error occurred.']);

  @override
  String toString() => 'FirestoreException: $message';
}

class NetworkException implements Exception {
  final String message;
  const NetworkException([this.message = 'Network error occurred.']);

  @override
  String toString() => 'NetworkException: $message';
}

class CacheException implements Exception {
  final String message;
  const CacheException([this.message = 'Cache error occurred.']);

  @override
  String toString() => 'CacheException: $message';
}

class VideoPlaybackException implements Exception {
  final String message;
  const VideoPlaybackException([this.message = 'Video playback error.']);

  @override
  String toString() => 'VideoPlaybackException: $message';
}
