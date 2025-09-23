import '../../../../core/utils/typedef.dart';
import '../entities/movie.dart';
import '../repositories/i_movie_repository.dart';

class GetBookmarkedMovies {
  final IMovieRepository repository;

  GetBookmarkedMovies(this.repository);

  ResultFuture<List<Movie>> call() async {
    return await repository.getBookmarkedMovies();
  }
}