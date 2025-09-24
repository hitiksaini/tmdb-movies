import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:hive/hive.dart';
import '../../features/movies/data/datasources/movie_local_data_source.dart';
import '../../features/movies/data/datasources/movie_remote_data_source.dart';
import '../../features/movies/data/repositories/movie_repository.dart';
import '../../features/movies/domain/repositories/i_movie_repository.dart';
import '../../features/movies/domain/usecases/bookmark_movie.dart';
import '../../features/movies/domain/usecases/get_bookmarked_movies.dart';
import '../../features/movies/domain/usecases/get_movie_details.dart';
import '../../features/movies/domain/usecases/get_now_playing_movies.dart';
import '../../features/movies/domain/usecases/get_trending_movies.dart';
import '../../features/movies/domain/usecases/remove_bookmark.dart';
import '../../features/movies/domain/usecases/search_movies.dart';
import '../../features/movies/presentation/bloc/movie_bloc.dart';
import '../constants/app_constants.dart';
import '../network/network_info.dart';
import '../network/network_bloc.dart';

final GetIt getIt = GetIt.instance;

Future<void> setupDependencyInjection() async {
  // External dependencies
  getIt.registerLazySingleton(() => Dio());
  getIt.registerLazySingleton(() => Connectivity());

  // Core
  getIt.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl(getIt()));

  // Hive boxes
  await Hive.openBox(AppConstants.movieBoxName);
  await Hive.openBox(AppConstants.bookmarkBoxName);

  // Data sources
  getIt.registerLazySingleton<MovieRemoteDataSource>(
    () => MovieRemoteDataSourceImpl(getIt()),
  );

  getIt.registerLazySingleton<MovieLocalDataSource>(
    () => MovieLocalDataSourceImpl(),
  );

  // Repository
  getIt.registerLazySingleton<IMovieRepository>(
    () => MovieRepository(
      remoteDataSource: getIt(),
      localDataSource: getIt(),
      networkInfo: getIt(),
    ),
  );

  // Use cases
  getIt.registerLazySingleton(() => GetTrendingMovies(getIt()));
  getIt.registerLazySingleton(() => GetNowPlayingMovies(getIt()));
  getIt.registerLazySingleton(() => SearchMovies(getIt()));
  getIt.registerLazySingleton(() => BookmarkMovie(getIt()));
  getIt.registerLazySingleton(() => RemoveBookmark(getIt()));
  getIt.registerLazySingleton(() => GetBookmarkedMovies(getIt()));
  getIt.registerLazySingleton(() => GetMovieDetails(getIt()));

  // Bloc's
  getIt.registerFactory(
    () => MovieBloc(
      getTrendingMovies: getIt(),
      getNowPlayingMovies: getIt(),
      searchMovies: getIt(),
      bookmarkMovie: getIt(),
      removeBookmark: getIt(),
      getBookmarkedMovies: getIt(),
      getMovieDetails: getIt(),
    ),
  );

  // Network Bloc
  getIt.registerLazySingleton(() => NetworkBloc(getIt<Connectivity>()));
}
