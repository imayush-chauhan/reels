import 'package:reels/core/errors/exceptions.dart';
import 'package:reels/core/errors/failures.dart';
import 'package:reels/core/utils/app_logger.dart';
import 'package:reels/core/utils/either.dart';
import 'package:reels/data/datasources/local/video_cache_datasource.dart';
import 'package:reels/data/datasources/remote/reels_remote_datasource.dart';
import 'package:reels/domain/entities/reel_entity.dart';
import 'package:reels/domain/repositories/reels_repository.dart';

class ReelsRepositoryImpl implements ReelsRepository {
  final ReelsRemoteDataSource _remoteDataSource;
  final VideoCacheDataSource _cacheDataSource;

  ReelsRepositoryImpl({
    required ReelsRemoteDataSource remoteDataSource,
    required VideoCacheDataSource cacheDataSource,
  })  : _remoteDataSource = remoteDataSource,
        _cacheDataSource = cacheDataSource;

  @override
  Future<Either<Failure, List<ReelEntity>>> fetchReels({
    int limit = 10,
    String? lastDocumentId,
  }) async {
    try {
      final models = await _remoteDataSource.fetchReels(
        limit: limit,
        lastDocumentId: lastDocumentId,
      );
      return right(models);
    } on FirestoreException catch (e) {
      AppLogger.error('Repository: Firestore error', e);
      return left(FirestoreFailure(e.message));
    } catch (e) {
      AppLogger.error('Repository: Unknown error fetching reels', e);
      return left(const UnknownFailure());
    }
  }

  @override
  Future<Either<Failure, ReelEntity>> toggleLike(
      String reelId, bool isLiked) async {
    try {
      final model = await _remoteDataSource.toggleLike(reelId, isLiked);
      return right(model.copyWith(isLiked: !isLiked));
    } on FirestoreException catch (e) {
      AppLogger.error('Repository: Error toggling like', e);
      return left(FirestoreFailure(e.message));
    } catch (e) {
      AppLogger.error('Repository: Unknown error toggling like', e);
      return left(const UnknownFailure());
    }
  }

  @override
  Future<String?> getCachedVideoPath(String videoUrl) {
    return _cacheDataSource.getCachedVideoPath(videoUrl);
  }

  @override
  Future<Either<Failure, String>> cacheVideo(String videoUrl) async {
    try {
      final path = await _cacheDataSource.cacheVideo(videoUrl);
      return right(path);
    } on CacheException catch (e) {
      AppLogger.error('Repository: Cache error', e);
      return left(VideoCacheFailure(e.message));
    } catch (e) {
      AppLogger.error('Repository: Unknown caching error', e);
      return left(const UnknownFailure());
    }
  }
}
