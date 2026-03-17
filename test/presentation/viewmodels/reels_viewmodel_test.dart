import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:reels/core/utils/either.dart';
import 'package:reels/core/errors/failures.dart';
import 'package:reels/domain/entities/reel_entity.dart';
import 'package:reels/domain/usecases/cache_video_usecase.dart';
import 'package:reels/domain/usecases/fetch_reels_usecase.dart';
import 'package:reels/domain/usecases/toggle_like_usecase.dart';
import 'package:reels/presentation/viewmodels/reels_viewmodel.dart';

import 'reels_viewmodel_test.mocks.dart';

@GenerateMocks([FetchReelsUseCase, ToggleLikeUseCase, CacheVideoUseCase])
void main() {
  late ReelsViewModel viewModel;
  late MockFetchReelsUseCase mockFetchReels;
  late MockToggleLikeUseCase mockToggleLike;
  late MockCacheVideoUseCase mockCacheVideo;

  final tReels = List.generate(
    3,
    (i) => ReelEntity(
      id: 'reel_$i',
      videoUrl: 'https://example.com/video_$i.mp4',
      thumbnailUrl: 'https://example.com/thumb_$i.jpg',
      username: 'user_$i',
      avatarUrl: 'https://example.com/avatar_$i.jpg',
      caption: 'Caption $i',
      audioName: 'Audio $i',
      likesCount: 100 * i,
      commentsCount: 10 * i,
      sharesCount: 5 * i,
    ),
  );

  setUp(() {
    mockFetchReels = MockFetchReelsUseCase();
    mockToggleLike = MockToggleLikeUseCase();
    mockCacheVideo = MockCacheVideoUseCase();

    viewModel = ReelsViewModel(
      fetchReelsUseCase: mockFetchReels,
      toggleLikeUseCase: mockToggleLike,
      cacheVideoUseCase: mockCacheVideo,
    );

    // Default cache stub
    when(mockCacheVideo.call(any))
        .thenAnswer((_) async => right('cached_path'));
  });

  tearDown(() => viewModel.dispose());

  group('loadReels', () {
    test('starts in initial state', () {
      expect(viewModel.loadingState, ReelsLoadingState.initial);
      expect(viewModel.reels, isEmpty);
    });

    test('emits loaded state and populates reels on success', () async {
      when(mockFetchReels(any)).thenAnswer((_) async => right(tReels));

      await viewModel.loadReels();

      expect(viewModel.loadingState, ReelsLoadingState.loaded);
      expect(viewModel.reels.length, 3);
      expect(viewModel.reels.first.id, 'reel_0');
    });

    test('emits error state on failure', () async {
      when(mockFetchReels(any))
          .thenAnswer((_) async => left(const FirestoreFailure('DB error')));

      await viewModel.loadReels();

      expect(viewModel.loadingState, ReelsLoadingState.error);
      expect(viewModel.errorMessage, 'DB error');
      expect(viewModel.reels, isEmpty);
    });

    test('does not fetch again while already loading', () async {
      // Simulate in-flight request
      when(mockFetchReels(any)).thenAnswer(
        (_) => Future.delayed(
          const Duration(milliseconds: 200),
          () => right(tReels),
        ),
      );

      final f1 = viewModel.loadReels();
      final f2 = viewModel.loadReels(); // should be ignored
      await Future.wait([f1, f2]);

      verify(mockFetchReels(any)).called(1);
    });
  });

  group('toggleLike', () {
    setUp(() async {
      when(mockFetchReels(any)).thenAnswer((_) async => right(tReels));
      await viewModel.loadReels();
    });

    test('optimistically updates like state', () async {
      final originalCount = viewModel.reels[0].likesCount;
      final originalLiked = viewModel.reels[0].isLiked;

      when(mockToggleLike(any)).thenAnswer(
        (_) async => right(
          tReels[0].copyWith(
            isLiked: !originalLiked,
            likesCount: originalLiked
                ? originalCount - 1
                : originalCount + 1,
          ),
        ),
      );

      await viewModel.toggleLike(0);

      expect(viewModel.reels[0].isLiked, !originalLiked);
      expect(
        viewModel.reels[0].likesCount,
        originalLiked ? originalCount - 1 : originalCount + 1,
      );
    });

    test('reverts to original on failure', () async {
      final original = viewModel.reels[0];

      when(mockToggleLike(any))
          .thenAnswer((_) async => left(const NetworkFailure()));

      await viewModel.toggleLike(0);

      expect(viewModel.reels[0].isLiked, original.isLiked);
      expect(viewModel.reels[0].likesCount, original.likesCount);
    });
  });

  group('toggleMute', () {
    test('toggles isMuted state', () {
      expect(viewModel.isMuted, false);
      viewModel.toggleMute();
      expect(viewModel.isMuted, true);
      viewModel.toggleMute();
      expect(viewModel.isMuted, false);
    });
  });

  group('loadMoreReels', () {
    setUp(() async {
      when(mockFetchReels(any)).thenAnswer((_) async => right(tReels));
      await viewModel.loadReels();
    });

    test('does not load more when hasMore is false', () async {
      // Only 3 reels returned but page size is 10 → hasMore = false
      await viewModel.loadMoreReels();
      // fetchReels was only called once (initial)
      verify(mockFetchReels(any)).called(1);
    });
  });
}
