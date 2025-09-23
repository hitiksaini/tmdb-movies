import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../movies/presentation/bloc/movie_bloc.dart';
import '../movies/presentation/bloc/movie_event.dart';
import '../movies/presentation/bloc/movie_state.dart';
import '../movies/presentation/pages/bookmarks_page.dart';
import '../movies/presentation/pages/movie_details_page.dart';
import '../movies/presentation/pages/search_page.dart';
import '../movies/presentation/widgets/movie_list.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _currentIndex = 0;

  final List<String> _tabTitles = [
    'Trending',
    'Now Playing',
    'Search',
    'Bookmarks',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabTitles.length, vsync: this);
    _loadInitialData();
  }

  void _loadInitialData() {
    context.read<MovieBloc>().add(LoadTrendingMoviesEvent());
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_tabTitles[_currentIndex]),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: false,
          labelColor: Colors.blue,
          unselectedLabelColor: Colors.grey,
          indicatorColor: Colors.blue,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
            _handleTabChange(index);
          },
          tabs: _tabTitles.map((title) => Tab(text: title)).toList(),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildTrendingTab(),
          _buildNowPlayingTab(),
          const SearchPage(),
          const BookmarksPage(),
        ],
      ),
    );
  }

  Widget _buildTrendingTab() {
    return BlocBuilder<MovieBloc, MovieState>(
      builder: (context, state) {
        if (state is MovieLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is TrendingMoviesLoaded) {
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
              context.read<MovieBloc>().add(BookmarkMovieEvent(movie));
            },
          );
        } else if (state is MovieError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Error: ${state.message}',
                  style: const TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    context.read<MovieBloc>().add(LoadTrendingMoviesEvent());
                  },
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildNowPlayingTab() {
    return BlocBuilder<MovieBloc, MovieState>(
      builder: (context, state) {
        if (state is MovieLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is NowPlayingMoviesLoaded) {
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
              context.read<MovieBloc>().add(BookmarkMovieEvent(movie));
            },
          );
        } else if (state is MovieError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Error: ${state.message}',
                  style: const TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    context.read<MovieBloc>().add(LoadNowPlayingMoviesEvent());
                  },
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  void _handleTabChange(int index) {
    switch (index) {
      case 0:
        context.read<MovieBloc>().add(LoadTrendingMoviesEvent());
        break;
      case 1:
        context.read<MovieBloc>().add(LoadNowPlayingMoviesEvent());
        break;
      case 3:
        context.read<MovieBloc>().add(LoadBookmarkedMoviesEvent());
        break;
    }
  }
}
