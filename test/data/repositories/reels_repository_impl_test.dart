import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:reels/core/errors/exceptions.dart';
import 'package:reels/data/datasources/local/video_cache_datasource.dart';
import 'package:reels/data/datasources/remote/reels_remote_datasource.dart';
import 'package:reels/data/models/reel_model.dart';
import 'package:reels/data/repositories/reels_repository_impl.dart';

import 'reels_repository_impl_test.mocks.dart';

@GenerateMocks([ReelsRemoteDataSource, VideoCacheDataSource])
void main() {
  late ReelsRepositoryImpl repository;
  late MockReelsRemoteDataSource mockRemote;
  late MockVideoCacheDataSource mockCache;

  final tModel = ReelModel(
    id: 'reel_1',
    videoUrl: 'https://example.com/video.mp4',
    thumbnailUrl: 'https://example.com/thumb.jpg',
    username: 'testuser',
    avatarUrl: 'https://example.com/avatar.jpg',
    caption: 'Test caption',
    audioName: 'Test Audio',
    likesCount: 500,
    commentsCount: 20,
    sharesCount: 10,
  );

  setUp(() {
    mockRemote = MockReelsRemoteDataSource();
    mockCache = MockVideoCacheDataSource();
    repository = ReelsRepositoryImpl(
      remoteDataSource: mockRemote,
      cacheDataSource: mockCache,
    );
  });

  group('fetchReels', () {
    test('returns Right(List<ReelEntity>) on success', () async {
      when(mockRemote.fetchReels(limit: anyNamed('limit')))
          .thenAnswer((_) async => [tModel]);

      final result = await repository.fetchReels();

      expect(result.isRight, true);
      expect(result.right.length, 1);
      expect(result.right.first.id, 'reel_1');
    });

    test('returns Left(FirestoreFailure) on FirestoreException', () async {
      when(mockRemote.fetchReels(limit: anyNamed('limit')))
          .thenThrow(const FirestoreException('DB down'));

      final result = await repository.fetchReels();

      expect(result.isLeft, true);
      expect(result.left.message, 'DB down');
    });

    test('returns Left(UnknownFailure) on unexpected error', () async {
      when(mockRemote.fetchReels(limit: anyNamed('limit')))
          .thenThrow(Exception('unknown'));

      final result = await repository.fetchReels();

      expect(result.isLeft, true);
    });
  });

  group('toggleLike', () {
    test('returns Right(ReelEntity) with toggled like', () async {
      when(mockRemote.toggleLike('reel_1', false))
          .thenAnswer((_) async => tModel);

      final result = await repository.toggleLike('reel_1', false);

      expect(result.isRight, true);
      expect(result.right.isLiked, true); // was false, now toggled
    });

    test('returns Left(FirestoreFailure) on error', () async {
      when(mockRemote.toggleLike(any, any))
          .thenThrow(const FirestoreException('Cannot like'));

      final result = await repository.toggleLike('reel_1', false);

      expect(result.isLeft, true);
      expect(result.left.message, 'Cannot like');
    });
  });

  group('getCachedVideoPath', () {
    test('returns path when cache hit', () async {
      when(mockCache.getCachedVideoPath(any))
          .thenAnswer((_) async => '/cache/video.mp4');

      final path = await repository.getCachedVideoPath('https://example.com/v.mp4');
      expect(path, '/cache/video.mp4');
    });

    test('returns null when cache miss', () async {
      when(mockCache.getCachedVideoPath(any)).thenAnswer((_) async => null);

      final path = await repository.getCachedVideoPath('https://example.com/v.mp4');
      expect(path, isNull);
    });
  });

  group('cacheVideo', () {
    test('returns Right(path) on success', () async {
      when(mockCache.cacheVideo(any))
          .thenAnswer((_) async => '/cache/video.mp4');

      final result = await repository.cacheVideo('https://example.com/v.mp4');
      expect(result.isRight, true);
      expect(result.right, '/cache/video.mp4');
    });

    test('returns Left(VideoCacheFailure) on CacheException', () async {
      when(mockCache.cacheVideo(any)).thenThrow(const CacheException('Disk full'));

      final result = await repository.cacheVideo('https://example.com/v.mp4');
      expect(result.isLeft, true);
      expect(result.left.message, 'Disk full');
    });
  });
}
