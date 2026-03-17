import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:video_player/video_player.dart';
import 'package:reels/core/constants/app_constants.dart';
import 'package:reels/core/utils/app_logger.dart';
import 'package:reels/domain/entities/reel_entity.dart';
import 'package:reels/domain/repositories/reels_repository.dart';
import 'package:reels/domain/usecases/cache_video_usecase.dart';
import 'package:reels/domain/usecases/fetch_reels_usecase.dart';
import 'package:reels/domain/usecases/toggle_like_usecase.dart';
import 'package:reels/presentation/viewmodels/video_controller_state.dart';

enum ReelsLoadingState { initial, loading, loaded, loadingMore, error }

class ReelsViewModel extends ChangeNotifier {
  final FetchReelsUseCase _fetchReelsUseCase;
  final ToggleLikeUseCase _toggleLikeUseCase;
  final CacheVideoUseCase _cacheVideoUseCase;

  /// Direct repository reference used only for the lightweight
  /// [ReelsRepository.getCachedVideoPath] check (read-only, no download).
  final ReelsRepository _reelsRepository;

  ReelsViewModel({
    required FetchReelsUseCase fetchReelsUseCase,
    required ToggleLikeUseCase toggleLikeUseCase,
    required CacheVideoUseCase cacheVideoUseCase,
    required ReelsRepository reelsRepository,
  })  : _fetchReelsUseCase = fetchReelsUseCase,
        _toggleLikeUseCase = toggleLikeUseCase,
        _cacheVideoUseCase = cacheVideoUseCase,
        _reelsRepository = reelsRepository;

  // ─── State ───────────────────────────────────────────────────────────────
  ReelsLoadingState _loadingState = ReelsLoadingState.initial;
  ReelsLoadingState get loadingState => _loadingState;

  List<ReelEntity> _reels = [];
  List<ReelEntity> get reels => List.unmodifiable(_reels);

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  int _currentIndex = 0;
  int get currentIndex => _currentIndex;

  bool _hasMore = true;
  bool get hasMore => _hasMore;

  bool _isMuted = false;
  bool get isMuted => _isMuted;

  // Map from reel index → video controller state
  final Map<int, VideoControllerState> _controllerStates = {};
  Map<int, VideoControllerState> get controllerStates =>
      Map.unmodifiable(_controllerStates);

  // Track ongoing cache operations to avoid duplicates
  final Set<String> _cachingUrls = {};

  // ─── Public API ──────────────────────────────────────────────────────────

  /// Initial load. Called once on screen mount.
  Future<void> loadReels() async {
    if (_loadingState == ReelsLoadingState.loading) return;
    _setLoadingState(ReelsLoadingState.loading);

    final result = await _fetchReelsUseCase(
      const FetchReelsParams(limit: AppConstants.reelsPageSize),
    );

    result.fold(
      (failure) {
        _errorMessage = failure.message;
        _setLoadingState(ReelsLoadingState.error);
      },
      (reels) {
        // Always store as an explicit growable list so index-assignment
        // in toggleLike (and future mutations) never throws on fixed-length lists.
        _reels = List<ReelEntity>.of(reels);
        _hasMore = reels.length == AppConstants.reelsPageSize;
        _setLoadingState(ReelsLoadingState.loaded);
        _initializeControllersAround(0);
      },
    );
  }

  /// Load next page when approaching the end.
  Future<void> loadMoreReels() async {
    if (!_hasMore) return;
    if (_loadingState == ReelsLoadingState.loadingMore) return;
    if (_reels.isEmpty) return;

    _setLoadingState(ReelsLoadingState.loadingMore);

    final result = await _fetchReelsUseCase(
      FetchReelsParams(
        limit: AppConstants.reelsPageSize,
        lastDocumentId: _reels.last.id,
      ),
    );

    result.fold(
      (failure) {
        _errorMessage = failure.message;
        _setLoadingState(ReelsLoadingState.loaded); // keep showing existing
      },
      (newReels) {
        // Spread into a new growable list to preserve mutability.
        _reels = List<ReelEntity>.of([..._reels, ...newReels]);
        _hasMore = newReels.length == AppConstants.reelsPageSize;
        _setLoadingState(ReelsLoadingState.loaded);
        _initializeControllersAround(_currentIndex);
      },
    );
  }

  /// Called when the PageView scrolls to a new index.
  Future<void> onPageChanged(int index) async {
    final previous = _currentIndex;
    _currentIndex = index;

    // Pause the previous video
    _pauseController(previous);

    // Play the current video
    await _playController(index);

    // Preload surrounding videos
    _initializeControllersAround(index);

    // Dispose controllers that are far away
    _disposeDistantControllers(index);

    // Load more if near end
    if (index >= _reels.length - 3) {
      loadMoreReels();
    }

    notifyListeners();
  }

  /// Toggle like on a reel (optimistic update).
  Future<void> toggleLike(int index) async {
    final reel = _reels[index];

    // Optimistic update
    _reels[index] = reel.copyWith(
      isLiked: !reel.isLiked,
      likesCount: reel.isLiked ? reel.likesCount - 1 : reel.likesCount + 1,
    );
    notifyListeners();

    final result = await _toggleLikeUseCase(
      ToggleLikeParams(reelId: reel.id, currentlyLiked: reel.isLiked),
    );

    result.fold(
      (failure) {
        // Revert on failure
        AppLogger.warning('Like toggle failed: ${failure.message}');
        _reels[index] = reel;
        notifyListeners();
      },
      (updatedReel) {
        _reels[index] = updatedReel;
        notifyListeners();
      },
    );
  }

  /// Toggle global mute state.
  void toggleMute() {
    _isMuted = !_isMuted;
    for (final state in _controllerStates.values) {
      state.controller?.setVolume(_isMuted ? 0.0 : 1.0);
    }
    notifyListeners();
  }

  /// Get the controller state for a given index, or null.
  VideoControllerState? getControllerState(int index) =>
      _controllerStates[index];

  // ─── Private helpers ─────────────────────────────────────────────────────

  void _setLoadingState(ReelsLoadingState state) {
    _loadingState = state;
    notifyListeners();
  }

  /// Initializes (and preloads) controllers around the given index.
  void _initializeControllersAround(int index) {
    final start = (index - AppConstants.preloadBehindCount).clamp(0, _reels.length - 1);
    final end = (index + AppConstants.preloadAheadCount).clamp(0, _reels.length - 1);

    for (int i = start; i <= end; i++) {
      if (!_controllerStates.containsKey(i) ||
          _controllerStates[i]!.status == VideoLoadingStatus.idle) {
        _initializeController(i);
      }
    }
  }

  Future<void> _initializeController(int index) async {
    if (index < 0 || index >= _reels.length) return;
    final reel = _reels[index];

    AppLogger.info('Initializing controller for index $index: ${reel.videoUrl}');

    _controllerStates[index] = const VideoControllerState(
      status: VideoLoadingStatus.loading,
    );
    notifyListeners();

    try {
      // Try to get a cached path first
      String? cachedPath = await _getCachedPath(reel.videoUrl);

      VideoPlayerController controller;
      if (cachedPath != null) {
        AppLogger.debug('Using cached video for index $index');
        controller = VideoPlayerController.contentUri(
          Uri.parse('file://$cachedPath'),
        );
      } else {
        AppLogger.debug('Streaming video for index $index');
        controller = VideoPlayerController.networkUrl(
          Uri.parse(reel.videoUrl),
        );
        // Cache in background without blocking playback
        _cacheInBackground(reel.videoUrl);
      }

      await controller.initialize();
      controller.setLooping(true);
      controller.setVolume(_isMuted ? 0.0 : 1.0);

      _controllerStates[index] = VideoControllerState(
        controller: controller,
        status: VideoLoadingStatus.ready,
      );

      // Auto-play if this is the current index
      if (index == _currentIndex) {
        await controller.play();
      }

      notifyListeners();
    } catch (e) {
      AppLogger.error('Failed to initialize controller at index $index', e);
      _controllerStates[index] = VideoControllerState(
        status: VideoLoadingStatus.error,
        errorMessage: e.toString(),
      );
      notifyListeners();
    }
  }

  /// Checks the local disk cache only — does NOT download anything.
  /// Uses [ReelsRepository.getCachedVideoPath] directly, which is a fast
  /// file-existence check (O(1) MD5 lookup), so it never blocks initialisation
  /// of other controllers the way calling [CacheVideoUseCase] would.
  Future<String?> _getCachedPath(String url) =>
      _reelsRepository.getCachedVideoPath(url);

  void _cacheInBackground(String url) {
    if (_cachingUrls.contains(url)) return;
    _cachingUrls.add(url);
    _cacheVideoUseCase(url).then((_) => _cachingUrls.remove(url));
  }

  Future<void> _playController(int index) async {
    final state = _controllerStates[index];
    if (state?.isReady == true) {
      await state!.controller!.play();
      AppLogger.debug('Playing index $index');
    }
  }

  void _pauseController(int index) {
    final state = _controllerStates[index];
    if (state?.isReady == true) {
      state!.controller!.pause();
      AppLogger.debug('Paused index $index');
    }
  }

  void _disposeDistantControllers(int currentIndex) {
    // Keep window must be strictly larger than the init window so we never
    // dispose a controller that _initializeControllersAround just created.
    // Init window  : [index - behind,       index + ahead      ]
    // Dispose window: [index - behind - 1,  index + ahead + 1  ]
    final keepStart =
        (currentIndex - AppConstants.preloadBehindCount - 1).clamp(0, _reels.length);
    final keepEnd =
        (currentIndex + AppConstants.preloadAheadCount + 1).clamp(0, _reels.length);

    final toDispose = _controllerStates.keys
        .where((i) => i < keepStart || i > keepEnd)
        .toList();

    for (final i in toDispose) {
      final state = _controllerStates.remove(i);
      state?.controller?.dispose();
      AppLogger.debug('Disposed controller at index $i');
    }
  }

  @override
  void dispose() {
    for (final state in _controllerStates.values) {
      state.controller?.dispose();
    }
    _controllerStates.clear();
    super.dispose();
  }
}
