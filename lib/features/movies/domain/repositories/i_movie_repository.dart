import '../../../../core/utils/typedef.dart';
import '../entities/movie.dart';

abstract class IMovieRepository {
  ResultFuture<List<Movie>> getTrendingMovies();
  ResultFuture<List<Movie>> getNowPlayingMovies();
  ResultFuture<List<Movie>> searchMovies(String query);
  ResultFuture<Movie> getMovieDetails(int movieId);
  ResultFuture<void> bookmarkMovie(Movie movie);
  ResultFuture<void> removeBookmark(int movieId);
  ResultFuture<List<Movie>> getBookmarkedMovies();
}
