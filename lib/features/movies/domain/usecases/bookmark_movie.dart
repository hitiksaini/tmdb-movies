import '../../../../core/utils/typedef.dart';
import '../entities/movie.dart';
import '../repositories/i_movie_repository.dart';

class BookmarkMovie {
  final IMovieRepository repository;

  BookmarkMovie(this.repository);

  ResultFuture<void> call(Movie movie) async {
    return await repository.bookmarkMovie(movie);
  }
}