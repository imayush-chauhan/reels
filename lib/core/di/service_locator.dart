import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get_it/get_it.dart';
import 'package:reels/data/datasources/local/video_cache_datasource.dart';
import 'package:reels/data/datasources/remote/reels_remote_datasource.dart';
import 'package:reels/data/repositories/reels_repository_impl.dart';
import 'package:reels/domain/repositories/reels_repository.dart';
import 'package:reels/domain/repositories/reels_repository.dart';
import 'package:reels/domain/usecases/cache_video_usecase.dart';
import 'package:reels/domain/usecases/fetch_reels_usecase.dart';
import 'package:reels/domain/usecases/toggle_like_usecase.dart';
import 'package:reels/presentation/viewmodels/reels_viewmodel.dart';

final sl = GetIt.instance;

Future<void> setupServiceLocator() async {
  // ─── External ────────────────────────────────────────────────────────────
  sl.registerLazySingleton<FirebaseFirestore>(
    () => FirebaseFirestore.instance,
  );

  // ─── Data Sources ────────────────────────────────────────────────────────
  sl.registerLazySingleton<ReelsRemoteDataSource>(
    () => ReelsRemoteDataSourceImpl(firestore: sl()),
  );

  sl.registerLazySingleton<VideoCacheDataSource>(
    () => VideoCacheDataSourceImpl(),
  );

  // ─── Repository ──────────────────────────────────────────────────────────
  sl.registerLazySingleton<ReelsRepository>(
    () => ReelsRepositoryImpl(
      remoteDataSource: sl(),
      cacheDataSource: sl(),
    ),
  );

  // ─── Use Cases ───────────────────────────────────────────────────────────
  sl.registerLazySingleton(() => FetchReelsUseCase(sl()));
  sl.registerLazySingleton(() => ToggleLikeUseCase(sl()));
  sl.registerLazySingleton(() => CacheVideoUseCase(sl()));

  // ─── ViewModel ───────────────────────────────────────────────────────────
  sl.registerFactory(
    () => ReelsViewModel(
      fetchReelsUseCase: sl(),
      toggleLikeUseCase: sl(),
      cacheVideoUseCase: sl(),
      reelsRepository: sl(), // for lightweight getCachedVideoPath checks
    ),
  );
}
