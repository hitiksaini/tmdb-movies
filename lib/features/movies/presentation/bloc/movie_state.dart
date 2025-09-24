import 'package:equatable/equatable.dart';
import '../../domain/entities/movie.dart';

abstract class MovieState extends Equatable {
  const MovieState();

  @override
  List<Object?> get props => [];
}

class MovieInitial extends MovieState {}

class MovieLoading extends MovieState {
  final MovieTab tab;
  const MovieLoading(this.tab);

  @override
  List<Object?> get props => [tab];
}

class MovieError extends MovieState {
  final String message;
  final MovieTab tab;

  const MovieError(this.message, this.tab);

  @override
  List<Object?> get props => [message, tab];
}

enum MovieTab { trending, nowPlaying, search, details, bookmarks }

class MoviesTabState extends MovieState {
  final MovieTab tab;
  final bool isLoading;
  final String? error;
  final bool isFromCache;

  const MoviesTabState({
    required this.tab,
    this.isLoading = false,
    this.error,
    this.isFromCache = false,
  });

  @override
  List<Object?> get props => [tab, isLoading, error, isFromCache];

  MoviesTabState copyWith({bool? isLoading, String? error, bool? isFromCache}) {
    return MoviesTabState(
      tab: tab,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      isFromCache: isFromCache ?? this.isFromCache,
    );
  }
}

class TrendingMoviesLoaded extends MoviesTabState {
  final List<Movie> movies;

  const TrendingMoviesLoaded(
    this.movies, {
    super.isFromCache,
    super.isLoading,
    super.error,
  }) : super(tab: MovieTab.trending);

  @override
  List<Object?> get props => [...super.props, movies];

  @override
  TrendingMoviesLoaded copyWith({
    List<Movie>? movies,
    bool? isLoading,
    String? error,
    bool? isFromCache,
  }) {
    return TrendingMoviesLoaded(
      movies ?? this.movies,
      isFromCache: isFromCache ?? this.isFromCache,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

class NowPlayingMoviesLoaded extends MoviesTabState {
  final List<Movie> movies;

  const NowPlayingMoviesLoaded(
    this.movies, {
    super.isFromCache,
    super.isLoading,
    super.error,
  }) : super(tab: MovieTab.nowPlaying);

  @override
  List<Object?> get props => [...super.props, movies];

  @override
  NowPlayingMoviesLoaded copyWith({
    List<Movie>? movies,
    bool? isLoading,
    String? error,
    bool? isFromCache,
  }) {
    return NowPlayingMoviesLoaded(
      movies ?? this.movies,
      isFromCache: isFromCache ?? this.isFromCache,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

class SearchMoviesLoaded extends MoviesTabState {
  final List<Movie> movies;
  final String query;

  const SearchMoviesLoaded(
    this.movies,
    this.query, {
    super.isFromCache,
    super.isLoading,
    super.error,
  }) : super(tab: MovieTab.search);

  @override
  List<Object?> get props => [...super.props, movies, query];

  @override
  SearchMoviesLoaded copyWith({
    List<Movie>? movies,
    String? query,
    bool? isLoading,
    String? error,
    bool? isFromCache,
  }) {
    return SearchMoviesLoaded(
      movies ?? this.movies,
      query ?? this.query,
      isFromCache: isFromCache ?? this.isFromCache,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

class MovieDetailsLoaded extends MoviesTabState {
  final Movie movie;
  final bool isBookmarked;

  const MovieDetailsLoaded(
    this.movie, {
    this.isBookmarked = false,
    super.isLoading,
    super.error,
  }) : super(tab: MovieTab.details);

  @override
  List<Object?> get props => [...super.props, movie, isBookmarked];

  @override
  MovieDetailsLoaded copyWith({
    Movie? movie,
    bool? isLoading,
    String? error,
    bool? isFromCache,
    bool? isBookmarked,
  }) {
    return MovieDetailsLoaded(
      movie ?? this.movie,
      isBookmarked: isBookmarked ?? this.isBookmarked,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

class BookmarkedMoviesLoaded extends MoviesTabState {
  final List<Movie> movies;

  const BookmarkedMoviesLoaded(this.movies, {super.isLoading, super.error})
    : super(tab: MovieTab.bookmarks);

  @override
  List<Object?> get props => [...super.props, movies];

  @override
  BookmarkedMoviesLoaded copyWith({
    List<Movie>? movies,
    bool? isLoading,
    String? error,
    bool? isFromCache,
  }) {
    return BookmarkedMoviesLoaded(
      movies ?? this.movies,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

class MovieBookmarked extends MovieState {}

class BookmarkRemoved extends MovieState {}

class SearchCleared extends MovieState {}
