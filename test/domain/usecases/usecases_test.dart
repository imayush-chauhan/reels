import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:reels/core/errors/failures.dart';
import 'package:reels/core/utils/either.dart';
import 'package:reels/domain/entities/reel_entity.dart';
import 'package:reels/domain/repositories/reels_repository.dart';
import 'package:reels/domain/usecases/cache_video_usecase.dart';
import 'package:reels/domain/usecases/fetch_reels_usecase.dart';
import 'package:reels/domain/usecases/toggle_like_usecase.dart';

import 'usecases_test.mocks.dart';

@GenerateMocks([ReelsRepository])
void main() {
  late MockReelsRepository mockRepository;

  final tReel = ReelEntity(
    id: 'r1',
    videoUrl: 'https://example.com/v.mp4',
    thumbnailUrl: 'https://example.com/t.jpg',
    username: 'alice',
    avatarUrl: 'https://example.com/a.jpg',
    caption: 'Hello',
    audioName: 'Song',
    likesCount: 99,
    commentsCount: 5,
    sharesCount: 2,
  );

  setUp(() {
    mockRepository = MockReelsRepository();
  });

  group('FetchReelsUseCase', () {
    late FetchReelsUseCase useCase;

    setUp(() => useCase = FetchReelsUseCase(mockRepository));

    test('calls repository with correct params', () async {
      when(mockRepository.fetchReels(limit: 5))
          .thenAnswer((_) async => right([tReel]));

      final result = await useCase(const FetchReelsParams(limit: 5));

      verify(mockRepository.fetchReels(limit: 5)).called(1);
      expect(result.isRight, true);
    });

    test('propagates failure from repository', () async {
      when(mockRepository.fetchReels(limit: anyNamed('limit')))
          .thenAnswer((_) async => left(const NetworkFailure()));

      final result = await useCase(const FetchReelsParams());
      expect(result.isLeft, true);
    });
  });

  group('ToggleLikeUseCase', () {
    late ToggleLikeUseCase useCase;

    setUp(() => useCase = ToggleLikeUseCase(mockRepository));

    test('calls toggleLike with correct args', () async {
      when(mockRepository.toggleLike('r1', false))
          .thenAnswer((_) async => right(tReel));

      await useCase(const ToggleLikeParams(reelId: 'r1', currentlyLiked: false));

      verify(mockRepository.toggleLike('r1', false)).called(1);
    });
  });

  group('CacheVideoUseCase', () {
    late CacheVideoUseCase useCase;

    setUp(() => useCase = CacheVideoUseCase(mockRepository));

    test('returns cached path on success', () async {
      when(mockRepository.cacheVideo(any))
          .thenAnswer((_) async => right('/path/video.mp4'));

      final result = await useCase('https://example.com/v.mp4');

      expect(result.isRight, true);
      expect(result.right, '/path/video.mp4');
    });
  });
}
