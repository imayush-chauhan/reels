import 'package:reels/core/errors/failures.dart';
import 'package:reels/core/utils/either.dart';
import 'package:reels/domain/entities/reel_entity.dart';
import 'package:reels/domain/repositories/reels_repository.dart';

class ToggleLikeParams {
  final String reelId;
  final bool currentlyLiked;

  const ToggleLikeParams({
    required this.reelId,
    required this.currentlyLiked,
  });
}

class ToggleLikeUseCase {
  final ReelsRepository _repository;

  ToggleLikeUseCase(this._repository);

  Future<Either<Failure, ReelEntity>> call(ToggleLikeParams params) {
    return _repository.toggleLike(params.reelId, params.currentlyLiked);
  }
}
