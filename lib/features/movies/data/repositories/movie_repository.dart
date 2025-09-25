import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../../../core/utils/typedef.dart';
import '../../domain/entities/movie.dart';
import '../../domain/repositories/i_movie_repository.dart';
import '../datasources/movie_local_data_source.dart';
import '../datasources/movie_remote_data_source.dart';
import '../models/movie_model.dart';

class MovieRepository implements IMovieRepository {
  final MovieRemoteDataSource remoteDataSource;
  final MovieLocalDataSource localDataSource;
  final NetworkInfo networkInfo;

  MovieRepository({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });

  @override
  ResultFuture<List<Movie>> getTrendingMovies() async {
    try {
      // First try to get local data
      try {
        final localMovies = await localDataSource.getCachedMovies('trending');
        // If we have local data, return it immediately
        if (localMovies.isNotEmpty) {
          // If we're online, fetch fresh data in background
          if (await networkInfo.isConnected) {
            _updateTrendingMoviesInBackground();
          }
          return Right(localMovies.map((model) => model.toEntity()).toList());
        }
      } on CacheException {
        // If no local data, continue to fetch from network
      }

      // If no local data or empty cache, try network
      if (await networkInfo.isConnected) {
        final remoteMovies = await remoteDataSource.getTrendingMovies();
        await localDataSource.cacheMovies('trending', remoteMovies);
        return Right(remoteMovies.map((model) => model.toEntity()).toList());
      } else {
        return const Left(
          NetworkFailure(
            'No internet connection and no cached data available (The API is blocked on jio networks)',
          ),
        );
      }
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  Future<void> _updateTrendingMoviesInBackground() async {
    try {
      final remoteMovies = await remoteDataSource.getTrendingMovies();
      await localDataSource.cacheMovies('trending', remoteMovies);
    } catch (_) {
      // Ignore background update errors
    }
  }

  @override
  ResultFuture<List<Movie>> getNowPlayingMovies() async {
    try {
      // First try to get local data
      try {
        final localMovies = await localDataSource.getCachedMovies(
          'now_playing',
        );
        // If we have local data, return it immediately
        if (localMovies.isNotEmpty) {
          // If we're online, fetch fresh data in background
          if (await networkInfo.isConnected) {
            _updateNowPlayingMoviesInBackground();
          }
          return Right(localMovies.map((model) => model.toEntity()).toList());
        }
      } on CacheException {
        // If no local data, continue to fetch from network
      }

      // If no local data or empty cache, try network
      if (await networkInfo.isConnected) {
        final remoteMovies = await remoteDataSource.getNowPlayingMovies();
        await localDataSource.cacheMovies('now_playing', remoteMovies);
        return Right(remoteMovies.map((model) => model.toEntity()).toList());
      } else {
        return const Left(
          NetworkFailure(
            'No internet connection and no cached data available (The API is blocked on jio networks)',
          ),
        );
      }
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  Future<void> _updateNowPlayingMoviesInBackground() async {
    try {
      final remoteMovies = await remoteDataSource.getNowPlayingMovies();
      await localDataSource.cacheMovies('now_playing', remoteMovies);
    } catch (_) {
      // Ignore background update errors
    }
  }

  @override
  ResultFuture<List<Movie>> searchMovies(String query) async {
    try {
      // First try local search
      try {
        final localMovies = await localDataSource.searchLocalMovies(query);
        if (localMovies.isNotEmpty) {
          return Right(localMovies.map((model) => model.toEntity()).toList());
        }
      } on CacheException {
        // If local search fails, continue to network search
      }

      // If no local results or local search failed, try network
      if (await networkInfo.isConnected) {
        final movies = await remoteDataSource.searchMovies(query);
        return Right(movies.map((model) => model.toEntity()).toList());
      } else {
        return const Left(
          NetworkFailure('No internet connection and no local results found'),
        );
      }
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  ResultFuture<Movie> getMovieDetails(int movieId) async {
    try {
      if (await networkInfo.isConnected) {
        final movie = await remoteDataSource.getMovieDetails(movieId);
        return Right(movie.toEntity());
      } else {
        return const Left(NetworkFailure('No internet connection'));
      }
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  ResultFuture<void> bookmarkMovie(Movie movie) async {
    try {
      final movieModel = MovieModel.fromEntity(movie);
      await localDataSource.bookmarkMovie(movieModel);
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  ResultFuture<void> removeBookmark(int movieId) async {
    try {
      await localDataSource.removeBookmark(movieId);
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  ResultFuture<List<Movie>> getBookmarkedMovies() async {
    try {
      final bookmarkedMovies = await localDataSource.getBookmarkedMovies();
      return Right(bookmarkedMovies.map((model) => model.toEntity()).toList());
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }
}
