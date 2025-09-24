import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/movie_bloc.dart';
import '../bloc/movie_event.dart';
import '../bloc/movie_state.dart';
import '../widgets/movie_list.dart';
import 'movie_details_page.dart';

class BookmarksPage extends StatefulWidget {
  const BookmarksPage({super.key});

  @override
  State<BookmarksPage> createState() => _BookmarksPageState();
}

class _BookmarksPageState extends State<BookmarksPage> {
  @override
  void initState() {
    super.initState();
    final bloc = context.read<MovieBloc>();
    if (bloc.bookmarksState == null) {
      bloc.add(LoadBookmarkedMoviesEvent());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Bookmarked Movies')),
      body: BlocBuilder<MovieBloc, MovieState>(
        builder: (context, state) {
          final bloc = context.read<MovieBloc>();
          final cachedState = bloc.bookmarksState;

          final isLoading =
              state is MovieLoading && state.tab == MovieTab.bookmarks;
          final isError =
              state is MovieError && state.tab == MovieTab.bookmarks;

          if (cachedState != null) {
            if (cachedState.movies.isEmpty && !cachedState.isLoading) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.bookmark_border, size: 64, color: Colors.grey),
                    SizedBox(height: 16),
                    Text(
                      'No bookmarked movies',
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Bookmark movies to see them here',
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ],
                ),
              );
            }

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
                    context.read<MovieBloc>().add(
                      RemoveBookmarkEvent(movie.id),
                    );
                  },
                  isBookmarked: (_) => true,
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
              onRetry: () =>
                  context.read<MovieBloc>().add(LoadBookmarkedMoviesEvent()),
            );
          }

          if (isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          WidgetsBinding.instance.addPostFrameCallback((_) {
            context.read<MovieBloc>().add(LoadBookmarkedMoviesEvent());
          });

          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  Widget _buildErrorState({
    required String message,
    required VoidCallback onRetry,
  }) {
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
          const SizedBox(height: 16),
          ElevatedButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    );
  }
}
