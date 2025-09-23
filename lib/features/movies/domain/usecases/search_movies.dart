import '../../../../core/utils/typedef.dart';
import '../entities/movie.dart';
import '../repositories/i_movie_repository.dart';

class SearchMovies {
  final IMovieRepository repository;

  SearchMovies(this.repository);

  ResultFuture<List<Movie>> call(String query) async {
    return await repository.searchMovies(query);
  }
}
