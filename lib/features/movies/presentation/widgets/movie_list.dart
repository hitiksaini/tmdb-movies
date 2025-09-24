import 'package:flutter/material.dart';
import '../../domain/entities/movie.dart';
import 'movie_card.dart';

class MovieList extends StatelessWidget {
  final List<Movie> movies;
  final Function(Movie)? onMovieTap;
  final Function(Movie)? onBookmarkTap;
  final bool Function(Movie)? isBookmarked;

  const MovieList({
    super.key,
    required this.movies,
    this.onMovieTap,
    this.onBookmarkTap,
    this.isBookmarked,
  });

  @override
  Widget build(BuildContext context) {
    if (movies.isEmpty) {
      return const Center(
        child: Text(
          'No movies found',
          style: TextStyle(fontSize: 18, color: Colors.grey),
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16.0),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.7,
      ),
      itemCount: movies.length,
      itemBuilder: (context, index) {
        final movie = movies[index];
        return MovieCard(
          movie: movie,
          onTap: () => onMovieTap?.call(movie),
          onBookmark: onBookmarkTap != null
              ? () => onBookmarkTap!.call(movie)
              : null,
          isBookmarked: isBookmarked?.call(movie) ?? false,
        );
      },
    );
  }
}
