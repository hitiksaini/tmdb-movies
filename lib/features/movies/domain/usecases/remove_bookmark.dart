import '../../../../core/utils/typedef.dart';
import '../repositories/i_movie_repository.dart';

class RemoveBookmark {
  final IMovieRepository repository;

  RemoveBookmark(this.repository);

  ResultFuture<void> call(int movieId) async {
    return await repository.removeBookmark(movieId);
  }
}
