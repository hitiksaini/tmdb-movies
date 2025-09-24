import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/movie_bloc.dart';
import '../bloc/movie_event.dart';
import '../bloc/movie_state.dart';
import '../widgets/movie_list.dart';
import '../widgets/search_bar_widget.dart';
import 'movie_details_page.dart';

class SearchPage extends StatelessWidget {
  const SearchPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          SearchBarWidget(
            onSearchChanged: (query) {
              context.read<MovieBloc>().add(SearchMoviesEvent(query));
            },
            onClearSearch: () {
              context.read<MovieBloc>().add(ClearSearchEvent());
            },
          ),
          Expanded(
            child: BlocBuilder<MovieBloc, MovieState>(
              builder: (context, state) {
                final bloc = context.read<MovieBloc>();
                final cachedState = bloc.searchState;
                final bookmarks = bloc.bookmarksState?.movies ?? [];
                final isLoading =
                    state is MovieLoading && state.tab == MovieTab.search;
                final isError =
                    state is MovieError && state.tab == MovieTab.search;

                if (cachedState != null && cachedState.movies.isNotEmpty) {
                  return Stack(
                    children: [
                      MovieList(
                        movies: cachedState.movies,
                        onMovieTap: (movie) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  MovieDetailsPage(movieId: movie.id),
                            ),
                          );
                        },
                        onBookmarkTap: (movie, isBookmarked) {
                          if (isBookmarked) {
                            context.read<MovieBloc>().add(
                              RemoveBookmarkEvent(movie.id),
                            );
                          } else {
                            context.read<MovieBloc>().add(
                              BookmarkMovieEvent(movie),
                            );
                          }
                        },
                        isBookmarked: (movie) =>
                            bookmarks.any((m) => m.id == movie.id),
                      ),
                      if (cachedState.isLoading || isLoading)
                        const Positioned.fill(
                          child: IgnorePointer(
                            child: Center(child: CircularProgressIndicator()),
                          ),
                        ),
                    ],
                  );
                }

                if (isError) {
                  return _buildErrorState(
                    // ignore: unnecessary_cast
                    message: (state as MovieError).message,
                  );
                }

                if (isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (cachedState != null && cachedState.movies.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search, size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        Text(
                          'Search for movies',
                          style: TextStyle(fontSize: 18, color: Colors.grey),
                        ),
                      ],
                    ),
                  );
                }

                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.search, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text(
                        'Search for movies',
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState({required String message}) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.grey[600]),
          const SizedBox(height: 16),
          Text(
            'Error: $message',
            style: const TextStyle(color: Colors.red),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
