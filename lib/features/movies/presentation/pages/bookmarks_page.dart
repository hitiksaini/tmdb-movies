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
    context.read<MovieBloc>().add(LoadBookmarkedMoviesEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Bookmarked Movies')),
      body: BlocBuilder<MovieBloc, MovieState>(
        builder: (context, state) {
          if (state is MovieLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is BookmarkedMoviesLoaded) {
            if (state.movies.isEmpty) {
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

            return MovieList(
              movies: state.movies,
              onMovieTap: (movie) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MovieDetailsPage(movieId: movie.id),
                  ),
                );
              },
              onBookmarkTap: (movie) {
                context.read<MovieBloc>().add(RemoveBookmarkEvent(movie.id));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Movie removed from bookmarks!'),
                    duration: Duration(seconds: 2),
                  ),
                );
                // Reload bookmarks after removal
                Future.delayed(const Duration(milliseconds: 500), () {
                  context.read<MovieBloc>().add(LoadBookmarkedMoviesEvent());
                });
              },
              isBookmarked: (_) =>
                  true, // All movies in bookmarks are bookmarked
            );
          } else if (state is MovieError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.grey[600]),
                  const SizedBox(height: 16),
                  Text(
                    'Error: ${state.message}',
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context.read<MovieBloc>().add(
                        LoadBookmarkedMoviesEvent(),
                      );
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}
