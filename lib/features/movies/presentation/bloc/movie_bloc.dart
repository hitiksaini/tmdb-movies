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
    on<ExecuteSearchEvent>(_onExecuteSearch);
    on<LoadMovieDetailsEvent>(_onLoadMovieDetails);
    on<BookmarkMovieEvent>(_onBookmarkMovie);
    on<RemoveBookmarkEvent>(_onRemoveBookmark);
    on<LoadBookmarkedMoviesEvent>(_onLoadBookmarkedMovies);
    on<ClearSearchEvent>(_onClearSearch);
  }

  TrendingMoviesLoaded? _trendingState;
  NowPlayingMoviesLoaded? _nowPlayingState;
  SearchMoviesLoaded? _searchState;
  MovieDetailsLoaded? _detailsState;
  BookmarkedMoviesLoaded? _bookmarksState;

  TrendingMoviesLoaded? get trendingState => _trendingState;
  NowPlayingMoviesLoaded? get nowPlayingState => _nowPlayingState;
  SearchMoviesLoaded? get searchState => _searchState;
  MovieDetailsLoaded? get detailsState => _detailsState;
  BookmarkedMoviesLoaded? get bookmarksState => _bookmarksState;

  MoviesTabState? getStateForTab(MovieTab tab) {
    switch (tab) {
      case MovieTab.trending:
        return _trendingState;
      case MovieTab.nowPlaying:
        return _nowPlayingState;
      case MovieTab.search:
        return _searchState;
      case MovieTab.details:
        return _detailsState;
      case MovieTab.bookmarks:
        return _bookmarksState;
    }
  }

  Future<void> _onLoadTrendingMovies(
    LoadTrendingMoviesEvent event,
    Emitter<MovieState> emit,
  ) async {
    if (_trendingState != null) {
      _trendingState = _trendingState!.copyWith(isLoading: true);
      emit(_trendingState!);
    } else {
      emit(MovieLoading(MovieTab.trending));
    }

    final result = await getTrendingMovies();
    result.fold(
      (failure) {
        final state = MovieError(failure.message, MovieTab.trending);
        emit(state);
      },
      (movies) {
        _trendingState = TrendingMoviesLoaded(movies);
        emit(_trendingState!);
      },
    );
  }

  Future<void> _onLoadNowPlayingMovies(
    LoadNowPlayingMoviesEvent event,
    Emitter<MovieState> emit,
  ) async {
    if (_nowPlayingState != null) {
      _nowPlayingState = _nowPlayingState!.copyWith(isLoading: true);
      emit(_nowPlayingState!);
    } else {
      emit(MovieLoading(MovieTab.nowPlaying));
    }

    final result = await getNowPlayingMovies();
    result.fold(
      (failure) {
        final state = MovieError(failure.message, MovieTab.nowPlaying);
        emit(state);
      },
      (movies) {
        _nowPlayingState = NowPlayingMoviesLoaded(movies);
        emit(_nowPlayingState!);
      },
    );
  }

  Future<void> _onSearchMovies(
    SearchMoviesEvent event,
    Emitter<MovieState> emit,
  ) async {
    _debounceTimer?.cancel();

    if (event.query.isEmpty) {
      _searchState = null;
      emit(SearchCleared());
      return;
    }

    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      add(ExecuteSearchEvent(event.query));
    });
  }

  Future<void> _onExecuteSearch(
    ExecuteSearchEvent event,
    Emitter<MovieState> emit,
  ) async {
    final currentCache = _searchState;
    if (currentCache != null) {
      _searchState = currentCache.copyWith(
        isLoading: true,
        query: event.query,
      );
      emit(_searchState!);
    } else {
      emit(MovieLoading(MovieTab.search));
    }

    final result = await searchMovies(event.query);
    if (!emit.isDone) {
      result.fold(
        (failure) {
          emit(MovieError(failure.message, MovieTab.search));
        },
        (movies) {
          _searchState = SearchMoviesLoaded(movies, event.query);
          emit(_searchState!);
        },
      );
    }
  }

  Future<void> _onLoadMovieDetails(
    LoadMovieDetailsEvent event,
    Emitter<MovieState> emit,
  ) async {
    try {
      if (_detailsState != null) {
        _detailsState = _detailsState!.copyWith(isLoading: true);
        emit(_detailsState!);
      } else {
        emit(MovieLoading(MovieTab.details));
      }

      final result = await getMovieDetails(event.movieId);
      if (result.isLeft()) {
        final failure = result.fold((l) => l, (r) => null);
        if (failure != null) {
          emit(MovieError(failure.message, MovieTab.details));
          return;
        }
      }

      final movie = result.fold((l) => null, (r) => r);
      if (movie == null) return;

      final bookmarkResult = await getBookmarkedMovies();
      final isBookmarked = bookmarkResult.fold(
        (failure) => false,
        (bookmarkedMovies) => bookmarkedMovies.any((m) => m.id == movie.id),
      );

      if (!emit.isDone) {
        _detailsState = MovieDetailsLoaded(movie, isBookmarked: isBookmarked);
        emit(_detailsState!);
      }
    } catch (e) {
      if (!emit.isDone) {
        emit(MovieError(e.toString(), MovieTab.details));
      }
    }
  }

  Future<void> _onBookmarkMovie(
    BookmarkMovieEvent event,
    Emitter<MovieState> emit,
  ) async {
    try {
      final previousState = state;

      final result = await bookmarkMovie(event.movie);
      if (result.isLeft()) {
        final failure = result.fold((l) => l, (r) => null);
        if (failure != null && !emit.isDone) {
          emit(MovieError(failure.message, MovieTab.bookmarks));
          return;
        }
      }

      final bookmarksResult = await getBookmarkedMovies();
      if (!emit.isDone) {
        bookmarksResult.fold(
          (failure) => emit(MovieError(failure.message, MovieTab.bookmarks)),
          (movies) {
            _bookmarksState = BookmarkedMoviesLoaded(movies);
            emit(_bookmarksState!);
          },
        );
      }

      if (_detailsState != null &&
          _detailsState!.movie.id == event.movie.id &&
          !emit.isDone) {
        _detailsState = _detailsState!.copyWith(isBookmarked: true);
        emit(_detailsState!);
      }

      if (!emit.isDone) {
        if (previousState is TrendingMoviesLoaded) {
          emit(previousState);
        } else if (previousState is NowPlayingMoviesLoaded) {
          emit(previousState);
        }
      }
    } catch (e) {
      if (!emit.isDone) {
        emit(MovieError(e.toString(), MovieTab.bookmarks));
      }
    }
  }

  Future<void> _onRemoveBookmark(
    RemoveBookmarkEvent event,
    Emitter<MovieState> emit,
  ) async {
    try {
      final previousState = state;

      final result = await removeBookmark(event.movieId);
      if (result.isLeft()) {
        final failure = result.fold((l) => l, (r) => null);
        if (failure != null && !emit.isDone) {
          emit(MovieError(failure.message, MovieTab.bookmarks));
          return;
        }
      }

      final bookmarksResult = await getBookmarkedMovies();
      if (!emit.isDone) {
        bookmarksResult.fold(
          (failure) => emit(MovieError(failure.message, MovieTab.bookmarks)),
          (movies) {
            _bookmarksState = BookmarkedMoviesLoaded(movies);
            emit(_bookmarksState!);
          },
        );
      }

      if (_detailsState != null &&
          _detailsState!.movie.id == event.movieId &&
          !emit.isDone) {
        _detailsState = _detailsState!.copyWith(isBookmarked: false);
        emit(_detailsState!);
      }

      if (!emit.isDone) {
        if (previousState is TrendingMoviesLoaded) {
          emit(previousState);
        } else if (previousState is NowPlayingMoviesLoaded) {
          emit(previousState);
        }
      }
    } catch (e) {
      if (!emit.isDone) {
        emit(MovieError(e.toString(), MovieTab.bookmarks));
      }
    }
  }

  Future<void> _onLoadBookmarkedMovies(
    LoadBookmarkedMoviesEvent event,
    Emitter<MovieState> emit,
  ) async {
    if (_bookmarksState != null) {
      _bookmarksState = _bookmarksState!.copyWith(isLoading: true);
      emit(_bookmarksState!);
    } else {
      emit(MovieLoading(MovieTab.bookmarks));
    }

    final result = await getBookmarkedMovies();
    result.fold(
      (failure) => emit(MovieError(failure.message, MovieTab.bookmarks)),
      (movies) {
        _bookmarksState = BookmarkedMoviesLoaded(movies);
        emit(_bookmarksState!);
      },
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
