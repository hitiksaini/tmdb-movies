import 'package:equatable/equatable.dart';
import '../../domain/entities/movie.dart';

abstract class MovieEvent extends Equatable {
  const MovieEvent();

  @override
  List<Object?> get props => [];
}

class LoadTrendingMoviesEvent extends MovieEvent {}

class LoadNowPlayingMoviesEvent extends MovieEvent {}

class SearchMoviesEvent extends MovieEvent {
  final String query;

  const SearchMoviesEvent(this.query);

  @override
  List<Object?> get props => [query];
}

class ExecuteSearchEvent extends MovieEvent {
  final String query;

  const ExecuteSearchEvent(this.query);

  @override
  List<Object?> get props => [query];
}

class LoadMovieDetailsByIdEvent extends MovieEvent {
  final int movieId;

  const LoadMovieDetailsByIdEvent(this.movieId);

  @override
  List<Object?> get props => [movieId];
}

class LoadMovieDetailsEvent extends MovieEvent {
  final Movie movie;

  const LoadMovieDetailsEvent(this.movie);

  @override
  List<Object?> get props => [movie];
}

class BookmarkMovieEvent extends MovieEvent {
  final Movie movie;

  const BookmarkMovieEvent(this.movie);

  @override
  List<Object?> get props => [movie];
}

class RemoveBookmarkEvent extends MovieEvent {
  final int movieId;

  const RemoveBookmarkEvent(this.movieId);

  @override
  List<Object?> get props => [movieId];
}

class LoadBookmarkedMoviesEvent extends MovieEvent {}

class ClearSearchEvent extends MovieEvent {}
