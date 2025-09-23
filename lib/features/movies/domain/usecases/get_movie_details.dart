import '../../../../core/utils/typedef.dart';
import '../entities/movie.dart';
import '../repositories/i_movie_repository.dart';

class GetMovieDetails {
  final IMovieRepository repository;

  GetMovieDetails(this.repository);

  ResultFuture<Movie> call(int movieId) async {
    return await repository.getMovieDetails(movieId);
  }
}