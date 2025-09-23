import '../../../../core/utils/typedef.dart';
import '../entities/movie.dart';
import '../repositories/i_movie_repository.dart';

class GetNowPlayingMovies {
  final IMovieRepository repository;

  GetNowPlayingMovies(this.repository);

  ResultFuture<List<Movie>> call() async {
    return await repository.getNowPlayingMovies();
  }
}