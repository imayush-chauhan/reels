import 'package:reels/core/errors/failures.dart';
import 'package:reels/core/utils/either.dart';
import 'package:reels/domain/entities/reel_entity.dart';
import 'package:reels/domain/repositories/reels_repository.dart';

class FetchReelsParams {
  final int limit;
  final String? lastDocumentId;

  const FetchReelsParams({this.limit = 10, this.lastDocumentId});
}

class FetchReelsUseCase {
  final ReelsRepository _repository;

  FetchReelsUseCase(this._repository);

  Future<Either<Failure, List<ReelEntity>>> call(FetchReelsParams params) {
    return _repository.fetchReels(
      limit: params.limit,
      lastDocumentId: params.lastDocumentId,
    );
  }
}
