import 'package:equatable/equatable.dart';
import '../../domain/entities/movie.dart';

abstract class MovieState extends Equatable {
  const MovieState();

  @override
  List<Object?> get props => [];
}

class MovieInitial extends MovieState {}

class MovieLoading extends MovieState {}

class MovieError extends MovieState {
  final String message;

  const MovieError(this.message);

  @override
  List<Object?> get props => [message];
}

class TrendingMoviesLoaded extends MovieState {
  final List<Movie> movies;

  const TrendingMoviesLoaded(this.movies);

  @override
  List<Object?> get props => [movies];
}

class NowPlayingMoviesLoaded extends MovieState {
  final List<Movie> movies;

  const NowPlayingMoviesLoaded(this.movies);

  @override
  List<Object?> get props => [movies];
}

class SearchMoviesLoaded extends MovieState {
  final List<Movie> movies;
  final String query;

  const SearchMoviesLoaded(this.movies, this.query);

  @override
  List<Object?> get props => [movies, query];
}

class MovieDetailsLoaded extends MovieState {
  final Movie movie;

  const MovieDetailsLoaded(this.movie);

  @override
  List<Object?> get props => [movie];
}

class BookmarkedMoviesLoaded extends MovieState {
  final List<Movie> movies;

  const BookmarkedMoviesLoaded(this.movies);

  @override
  List<Object?> get props => [movies];
}

class MovieBookmarked extends MovieState {}

class BookmarkRemoved extends MovieState {}

class SearchCleared extends MovieState {}
