import '../../../../core/utils/typedef.dart';
import '../entities/movie.dart';
import '../repositories/i_movie_repository.dart';

class GetTrendingMovies {
  final IMovieRepository repository;

  GetTrendingMovies(this.repository);

  ResultFuture<List<Movie>> call() async {
    return await repository.getTrendingMovies();
  }
}