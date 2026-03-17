import 'package:reels/core/utils/either.dart';
import 'package:reels/core/errors/failures.dart';
import 'package:reels/domain/entities/reel_entity.dart';

abstract class ReelsRepository {
  /// Fetches a paginated list of reels from remote source.
  Future<Either<Failure, List<ReelEntity>>> fetchReels({
    int limit,
    String? lastDocumentId,
  });

  /// Toggles the like status of a reel.
  Future<Either<Failure, ReelEntity>> toggleLike(String reelId, bool isLiked);

  /// Returns a cached local file path for a video URL, or null if not cached.
  Future<String?> getCachedVideoPath(String videoUrl);

  /// Caches a video from [videoUrl] to local storage.
  /// Returns the local file path on success.
  Future<Either<Failure, String>> cacheVideo(String videoUrl);
}
