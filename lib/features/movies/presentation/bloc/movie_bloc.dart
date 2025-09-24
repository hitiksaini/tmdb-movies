import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_trending_movies.dart';
import '../../domain/usecases/get_now_playing_movies.dart';
import '../../domain/usecases/search_movies.dart';
import '../../domain/usecases/bookmark_movie.dart';
import '../../domain/usecases/remove_bookmark.dart';
import '../../domain/usecases/get_bookmarked_movies.dart';
import '../../domain/usecases/get_movie_details.dart';
import 'movie_event.dart';
import 'movie_state.dart';

class MovieBloc extends Bloc<MovieEvent, MovieState> {
  final GetTrendingMovies getTrendingMovies;
  final GetNowPlayingMovies getNowPlayingMovies;
  final SearchMovies searchMovies;
  final BookmarkMovie bookmarkMovie;
  final RemoveBookmark removeBookmark;
  final GetBookmarkedMovies getBookmarkedMovies;
  final GetMovieDetails getMovieDetails;

  Timer? _debounceTimer;

  MovieBloc({
    required this.getTrendingMovies,
    required this.getNowPlayingMovies,
    required this.searchMovies,
    required this.bookmarkMovie,
    required this.removeBookmark,
    required this.getBookmarkedMovies,
    required this.getMovieDetails,
  }) : super(MovieInitial()) {
    on<LoadTrendingMoviesEvent>(_onLoadTrendingMovies);
    on<LoadNowPlayingMoviesEvent>(_onLoadNowPlayingMovies);
    on<SearchMoviesEvent>(_onSearchMovies);
    on<LoadMovieDetailsEvent>(_onLoadMovieDetails);
    on<BookmarkMovieEvent>(_onBookmarkMovie);
    on<RemoveBookmarkEvent>(_onRemoveBookmark);
    on<LoadBookmarkedMoviesEvent>(_onLoadBookmarkedMovies);
    on<ClearSearchEvent>(_onClearSearch);
  }

  Future<void> _onLoadTrendingMovies(
    LoadTrendingMoviesEvent event,
    Emitter<MovieState> emit,
  ) async {
    emit(MovieLoading());
    final result = await getTrendingMovies();
    result.fold(
      (failure) => emit(MovieError(failure.message)),
      (movies) => emit(TrendingMoviesLoaded(movies)),
    );
  }

  Future<void> _onLoadNowPlayingMovies(
    LoadNowPlayingMoviesEvent event,
    Emitter<MovieState> emit,
  ) async {
    emit(MovieLoading());
    final result = await getNowPlayingMovies();
    result.fold(
      (failure) => emit(MovieError(failure.message)),
      (movies) => emit(NowPlayingMoviesLoaded(movies)),
    );
  }

  Future<void> _onSearchMovies(
    SearchMoviesEvent event,
    Emitter<MovieState> emit,
  ) async {
    _debounceTimer?.cancel();

    if (event.query.isEmpty) {
      emit(SearchCleared());
      return;
    }

    _debounceTimer = Timer(const Duration(milliseconds: 500), () async {
      if (!emit.isDone) {
        emit(MovieLoading());
        final result = await searchMovies(event.query);
        if (!emit.isDone) {
          result.fold(
            (failure) => emit(MovieError(failure.message)),
            (movies) => emit(SearchMoviesLoaded(movies, event.query)),
          );
        }
      }
    });
  }

  Future<void> _onLoadMovieDetails(
    LoadMovieDetailsEvent event,
    Emitter<MovieState> emit,
  ) async {
    emit(MovieLoading());
    final result = await getMovieDetails(event.movieId);
    result.fold(
      (failure) => emit(MovieError(failure.message)),
      (movie) => emit(MovieDetailsLoaded(movie)),
    );
  }

  Future<void> _onBookmarkMovie(
    BookmarkMovieEvent event,
    Emitter<MovieState> emit,
  ) async {
    final result = await bookmarkMovie(event.movie);
    result.fold(
      (failure) => emit(MovieError(failure.message)),
      (_) {
        // Show a snackbar for feedback
      },
    );
  }

  Future<void> _onRemoveBookmark(
    RemoveBookmarkEvent event,
    Emitter<MovieState> emit,
  ) async {
    final result = await removeBookmark(event.movieId);
    result.fold(
      (failure) => emit(MovieError(failure.message)),
      (_) {
        //  Handle the removal feedback
      },
    );
  }

  Future<void> _onLoadBookmarkedMovies(
    LoadBookmarkedMoviesEvent event,
    Emitter<MovieState> emit,
  ) async {
    emit(MovieLoading());
    final result = await getBookmarkedMovies();
    result.fold(
      (failure) => emit(MovieError(failure.message)),
      (movies) => emit(BookmarkedMoviesLoaded(movies)),
    );
  }

  void _onClearSearch(ClearSearchEvent event, Emitter<MovieState> emit) {
    _debounceTimer?.cancel();
    emit(SearchCleared());
  }

  @override
  Future<void> close() {
    _debounceTimer?.cancel();
    return super.close();
  }
}
