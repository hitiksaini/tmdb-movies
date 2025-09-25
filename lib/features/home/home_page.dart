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

  final List<String> _tabTitles = ['Trending', 'Now Playing', 'Search'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabTitles.length, vsync: this);
    _tabController.addListener(_handleTabControllerChange);
    _loadInitialData();
  }

  void _handleTabControllerChange() {
    if (!_tabController.indexIsChanging) {
      setState(() {
        _currentIndex = _tabController.index;
      });
      _handleTabChange(_tabController.index);
    }
  }

  void _loadInitialData() {
    final bloc = context.read<MovieBloc>();
    bloc.add(LoadTrendingMoviesEvent());
    bloc.add(LoadBookmarkedMoviesEvent());
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabControllerChange);
    _tabController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final state = context.read<MovieBloc>().state;
    if (state is! TrendingMoviesLoaded && state is! NowPlayingMoviesLoaded) {
      _handleTabChange(_currentIndex);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 24,
        title: Row(children: [Text(_tabTitles[_currentIndex])]),
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
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => BookmarksPage()),
              );
            },
            icon: Icon(Icons.bookmark_added_outlined),
          ),
        ],
        actionsPadding: EdgeInsets.symmetric(horizontal: 12),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildTrendingTab(),
          _buildNowPlayingTab(),
          const SearchPage(),
        ],
      ),
    );
  }

  Widget _buildTrendingTab() {
    return BlocBuilder<MovieBloc, MovieState>(
      builder: (context, state) {
        final bloc = context.read<MovieBloc>();
        final cachedState = bloc.trendingState;
        final bookmarks = bloc.bookmarksState?.movies ?? [];
        final isLoading =
            state is MovieLoading && state.tab == MovieTab.trending;
        final isError = state is MovieError && state.tab == MovieTab.trending;

        if (cachedState != null && cachedState.movies.isNotEmpty) {
          return Stack(
            children: [
              MovieList(
                movies: cachedState.movies,
                onMovieTap: (movie) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MovieDetailsPage(movie: movie),
                    ),
                  );
                },
                onBookmarkTap: (movie, isCurrentlyBookmarked) {
                  if (isCurrentlyBookmarked) {
                    context.read<MovieBloc>().add(
                      RemoveBookmarkEvent(movie.id),
                    );
                  } else {
                    context.read<MovieBloc>().add(BookmarkMovieEvent(movie));
                  }
                },
                isBookmarked: (movie) => bookmarks.any((m) => m.id == movie.id),
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
          // ignore: unnecessary_cast
          final message = (state as MovieError).message;
          return _buildErrorState(
            message: message,
            onRetry: () =>
                context.read<MovieBloc>().add(LoadTrendingMoviesEvent()),
          );
        }

        if (isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (cachedState != null && cachedState.movies.isEmpty) {
          return _buildEmptyState('No movies found');
        }

        WidgetsBinding.instance.addPostFrameCallback((_) {
          context.read<MovieBloc>().add(LoadTrendingMoviesEvent());
        });

        return const Center(child: CircularProgressIndicator());
      },
    );
  }

  Widget _buildNowPlayingTab() {
    return BlocBuilder<MovieBloc, MovieState>(
      builder: (context, state) {
        final bloc = context.read<MovieBloc>();
        final cachedState = bloc.nowPlayingState;
        final bookmarks = bloc.bookmarksState?.movies ?? [];
        final isLoading =
            state is MovieLoading && state.tab == MovieTab.nowPlaying;
        final isError = state is MovieError && state.tab == MovieTab.nowPlaying;

        if (cachedState != null && cachedState.movies.isNotEmpty) {
          return Stack(
            children: [
              MovieList(
                movies: cachedState.movies,
                onMovieTap: (movie) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MovieDetailsPage(movie: movie),
                    ),
                  );
                },
                onBookmarkTap: (movie, isCurrentlyBookmarked) {
                  if (isCurrentlyBookmarked) {
                    context.read<MovieBloc>().add(
                      RemoveBookmarkEvent(movie.id),
                    );
                  } else {
                    context.read<MovieBloc>().add(BookmarkMovieEvent(movie));
                  }
                },
                isBookmarked: (movie) => bookmarks.any((m) => m.id == movie.id),
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
          // ignore: unnecessary_cast
          final message = (state as MovieError).message;
          return _buildErrorState(
            message: message,
            onRetry: () =>
                context.read<MovieBloc>().add(LoadNowPlayingMoviesEvent()),
          );
        }

        if (isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (cachedState != null && cachedState.movies.isEmpty) {
          return _buildEmptyState('No movies found');
        }

        WidgetsBinding.instance.addPostFrameCallback((_) {
          context.read<MovieBloc>().add(LoadNowPlayingMoviesEvent());
        });

        return const Center(child: CircularProgressIndicator());
      },
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

  Widget _buildEmptyState(String message) {
    return Center(
      child: Text(
        message,
        style: const TextStyle(fontSize: 18, color: Colors.grey),
      ),
    );
  }

  void _handleTabChange(int index) {
    final currentState = context.read<MovieBloc>().state;
    switch (index) {
      case 0:
        if (currentState is! TrendingMoviesLoaded) {
          context.read<MovieBloc>().add(LoadTrendingMoviesEvent());
        }
        break;
      case 1:
        if (currentState is! NowPlayingMoviesLoaded) {
          context.read<MovieBloc>().add(LoadNowPlayingMoviesEvent());
        }
        break;
      case 2:
        break;
    }
  }
}
