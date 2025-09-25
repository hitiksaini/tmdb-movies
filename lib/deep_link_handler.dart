// ignore_for_file: empty_catches

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:uni_links/uni_links.dart';
import 'features/movies/presentation/bloc/movie_bloc.dart';
import 'features/movies/presentation/bloc/movie_event.dart';
import 'features/movies/presentation/pages/movie_details_page.dart';

class DeepLinkHandler extends StatefulWidget {
  final Widget child;
  final MovieBloc movieBloc;
  final GlobalKey<NavigatorState> navigatorKey;

  const DeepLinkHandler({
    super.key,
    required this.child,
    required this.movieBloc,
    required this.navigatorKey,
  });

  @override
  State<DeepLinkHandler> createState() => _DeepLinkHandlerState();
}

class _DeepLinkHandlerState extends State<DeepLinkHandler> {
  StreamSubscription<Uri?>? _linkSubscription;

  @override
  void initState() {
    super.initState();
    _initDeepLinks();
  }

  Future<void> _initDeepLinks() async {
    try {
      final initialUri = await getInitialUri();
      if (!mounted) return;
      if (initialUri != null) {
        _handleUri(initialUri);
      }
    } on PlatformException {}

    _linkSubscription?.cancel();
    _linkSubscription = uriLinkStream.listen((uri) {
      if (uri != null) {
        _handleUri(uri);
      }
    }, onError: (_) {});
  }

  void _handleUri(Uri uri) {
    if (uri.scheme != 'tmdbmovies') return;
    if (uri.host == 'movie') {
      final idSegment = uri.pathSegments.isNotEmpty
          ? uri.pathSegments.first
          : '';
      final movieId = int.tryParse(idSegment);
      if (movieId == null) return;

      final bloc = widget.movieBloc;
      bloc.add(LoadMovieDetailsByIdEvent(movieId));

      WidgetsBinding.instance.addPostFrameCallback((_) {
        final navigator = widget.navigatorKey.currentState;
        if (navigator == null) return;
        navigator.push(
          MaterialPageRoute(
            settings: RouteSettings(name: 'deeplink-movie-$movieId'),
            builder: (_) => MovieDetailsPage(movieId: movieId),
          ),
        );
      });
    }
  }

  @override
  void dispose() {
    _linkSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
