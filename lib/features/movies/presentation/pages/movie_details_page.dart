import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:share_plus/share_plus.dart';
import '../../../../core/constants/api_constants.dart';
import '../../domain/entities/movie.dart';
import '../bloc/movie_bloc.dart';
import '../bloc/movie_event.dart';
import '../bloc/movie_state.dart';

class MovieDetailsPage extends StatefulWidget {
  final Movie movie;

  const MovieDetailsPage({super.key, required this.movie});

  @override
  State<MovieDetailsPage> createState() => _MovieDetailsPageState();
}

class _MovieDetailsPageState extends State<MovieDetailsPage> {
  @override
  void initState() {
    super.initState();
    final bloc = context.read<MovieBloc>();
    final cachedDetails = bloc.detailsState;
    if (cachedDetails == null || cachedDetails.movie.id != widget.movie.id) {
      bloc.add(PrimeMovieDetailsEvent(widget.movie));
      bloc.add(LoadMovieDetailsEvent(widget.movie.id));
    }
  }

  void _shareMovie(Movie movie) {
    final deepLink = 'tmdbmovies://movie/${movie.id}';
    final shareText =
        '''
        🎬 ${movie.title}

        ${movie.overview ?? 'No overview available'}

        ⭐ Rating: ${movie.voteAverage.toStringAsFixed(1)}/10
        📅 Released: ${movie.releaseDate ?? 'Unknown'}

        Check out this movie in the TmDB Movies app!
        Deep link: $deepLink

        #Movies #TmDB
        ''';

    Share.share(shareText, subject: 'Check out this movie: ${movie.title}');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<MovieBloc, MovieState>(
        builder: (context, state) {
          final bloc = context.read<MovieBloc>();
          MovieDetailsLoaded? cachedState = bloc.detailsState;
          if (cachedState != null && cachedState.movie.id != widget.movie.id) {
            cachedState = null;
          }
          final isLoading =
              state is MovieLoading && state.tab == MovieTab.details;
          final isError = state is MovieError && state.tab == MovieTab.details;

          if (cachedState != null) {
            final movie = cachedState.movie;
            return CustomScrollView(
              slivers: [
                SliverAppBar(
                  expandedHeight: 300,
                  pinned: true,
                  actions: [
                    IconButton(
                      icon: const Icon(Icons.share),
                      onPressed: () {
                        _shareMovie(movie);
                      },
                    ),
                    IconButton(
                      icon: Icon(
                        cachedState.isBookmarked
                            ? Icons.bookmark
                            : Icons.bookmark_border,
                        color: cachedState.isBookmarked
                            ? Colors.yellow
                            : Colors.white,
                      ),
                      onPressed: () {
                        if (cachedState!.isBookmarked) {
                          context.read<MovieBloc>().add(
                            RemoveBookmarkEvent(movie.id),
                          );
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Movie removed from bookmarks!'),
                              duration: Duration(seconds: 2),
                            ),
                          );
                        } else {
                          context.read<MovieBloc>().add(
                            BookmarkMovieEvent(movie),
                          );
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Movie bookmarked!'),
                              duration: Duration(seconds: 2),
                            ),
                          );
                        }
                      },
                    ),
                  ],
                  flexibleSpace: FlexibleSpaceBar(
                    background: movie.backdropPath != null
                        ? CachedNetworkImage(
                            imageUrl:
                                '${ApiConstants.imageBaseUrl}${movie.backdropPath}',
                            fit: BoxFit.cover,
                            errorWidget: (context, url, error) => Container(
                              color: Colors.grey[800],
                              child: const Icon(
                                Icons.movie,
                                size: 100,
                                color: Colors.grey,
                              ),
                            ),
                          )
                        : Container(
                            color: Colors.grey[800],
                            child: const Icon(
                              Icons.movie,
                              size: 100,
                              color: Colors.grey,
                            ),
                          ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          movie.title,
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Released: ${movie.releaseDate ?? 'Unknown'}',
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            RatingBarIndicator(
                              rating: movie.voteAverage / 2,
                              itemBuilder: (context, index) =>
                                  const Icon(Icons.star, color: Colors.amber),
                              itemCount: 5,
                              itemSize: 24.0,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              '${movie.voteAverage.toStringAsFixed(1)}/10',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '(${movie.voteCount} votes)',
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        const Text(
                          'Overview',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          movie.overview ?? 'No overview available',
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 24),
                        const Text(
                          'Movie Details',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildDetailRow('Original Title', movie.originalTitle),
                        _buildDetailRow(
                          'Language',
                          movie.originalLanguage.toUpperCase(),
                        ),
                        _buildDetailRow(
                          'Popularity',
                          movie.popularity.toStringAsFixed(1),
                        ),
                        _buildDetailRow(
                          'Adult Content',
                          movie.adult ? 'Yes' : 'No',
                        ),
                      ],
                    ),
                  ),
                ),
                if (cachedState.isLoading || isLoading)
                  const SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(child: CircularProgressIndicator()),
                  ),
              ],
            );
          }

          if (isError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    // ignore: unnecessary_cast
                    'Error: ${(state as MovieError).message}',
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context.read<MovieBloc>().add(
                        LoadMovieDetailsEvent(widget.movie.id),
                      );
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          WidgetsBinding.instance.addPostFrameCallback((_) {
            context.read<MovieBloc>().add(
              LoadMovieDetailsEvent(widget.movie.id),
            );
          });

          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 16, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
