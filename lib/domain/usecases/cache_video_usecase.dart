import 'package:reels/core/errors/failures.dart';
import 'package:reels/core/utils/either.dart';
import 'package:reels/domain/repositories/reels_repository.dart';

class CacheVideoUseCase {
  final ReelsRepository _repository;

  CacheVideoUseCase(this._repository);

  Future<Either<Failure, String>> call(String videoUrl) {
    return _repository.cacheVideo(videoUrl);
  }
}
