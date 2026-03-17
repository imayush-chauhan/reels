import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String message;
  const Failure(this.message);

  @override
  List<Object?> get props => [message];
}

class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'Network error occurred.']);
}

class FirestoreFailure extends Failure {
  const FirestoreFailure([super.message = 'Firestore error occurred.']);
}

class VideoCacheFailure extends Failure {
  const VideoCacheFailure([super.message = 'Video cache error occurred.']);
}

class VideoPlaybackFailure extends Failure {
  const VideoPlaybackFailure([super.message = 'Video playback error occurred.']);
}

class UnknownFailure extends Failure {
  const UnknownFailure([super.message = 'An unknown error occurred.']);
}
