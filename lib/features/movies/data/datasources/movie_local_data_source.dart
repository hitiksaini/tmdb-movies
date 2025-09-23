import 'package:hive/hive.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/error/exceptions.dart';
import '../models/movie_model.dart';

abstract class MovieLocalDataSource {
  Future<void> cacheMovies(String key, List<MovieModel> movies);
  Future<List<MovieModel>> getCachedMovies(String key);
  Future<void> bookmarkMovie(MovieModel movie);
  Future<void> removeBookmark(int movieId);
  Future<List<MovieModel>> getBookmarkedMovies();
  Future<bool> isMovieBookmarked(int movieId);
  Future<void> clearCache();
}

class MovieLocalDataSourceImpl implements MovieLocalDataSource {
  final Box movieBox = Hive.box(AppConstants.movieBoxName);
  final Box bookmarkBox = Hive.box(AppConstants.bookmarkBoxName);

  @override
  Future<void> cacheMovies(String key, List<MovieModel> movies) async {
    try {
      final movieMaps = movies.map((movie) => movie.toJson()).toList();
      await movieBox.put(key, movieMaps);
    } catch (e) {
      throw CacheException('Failed to cache movies: $e');
    }
  }

  @override
  Future<List<MovieModel>> getCachedMovies(String key) async {
    try {
      final movieMaps = movieBox.get(key) as List<dynamic>?;
      if (movieMaps == null) {
        throw CacheException('No cached movies found');
      }
      return movieMaps
          .map(
            (movieMap) =>
                MovieModel.fromJson(Map<String, dynamic>.from(movieMap)),
          )
          .toList();
    } catch (e) {
      throw CacheException('Failed to get cached movies: $e');
    }
  }

  @override
  Future<void> bookmarkMovie(MovieModel movie) async {
    try {
      await bookmarkBox.put(movie.id, movie.toJson());
    } catch (e) {
      throw CacheException('Failed to bookmark movie: $e');
    }
  }

  @override
  Future<void> removeBookmark(int movieId) async {
    try {
      await bookmarkBox.delete(movieId);
    } catch (e) {
      throw CacheException('Failed to remove bookmark: $e');
    }
  }

  @override
  Future<List<MovieModel>> getBookmarkedMovies() async {
    try {
      final bookmarkedMovies = <MovieModel>[];
      for (final key in bookmarkBox.keys) {
        final movieMap = bookmarkBox.get(key);
        if (movieMap != null) {
          bookmarkedMovies.add(
            MovieModel.fromJson(Map<String, dynamic>.from(movieMap)),
          );
        }
      }
      return bookmarkedMovies;
    } catch (e) {
      throw CacheException('Failed to get bookmarked movies: $e');
    }
  }

  @override
  Future<bool> isMovieBookmarked(int movieId) async {
    try {
      return bookmarkBox.containsKey(movieId);
    } catch (e) {
      throw CacheException('Failed to check bookmark status: $e');
    }
  }

  @override
  Future<void> clearCache() async {
    try {
      await movieBox.clear();
    } catch (e) {
      throw CacheException('Failed to clear cache: $e');
    }
  }
}
