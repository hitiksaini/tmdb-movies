import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:tmdb_movies/features/home/home_page.dart';
import 'core/di/dependency_injection.dart';
import 'core/network/network_bloc.dart';
import 'features/movies/presentation/bloc/movie_bloc.dart';
import 'deep_link_handler.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await setupDependencyInjection();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();
  late final MovieBloc _movieBloc;
  late final NetworkBloc _networkBloc;

  @override
  void initState() {
    super.initState();
    _movieBloc = getIt<MovieBloc>();
    _networkBloc = getIt<NetworkBloc>();
  }

  @override
  void dispose() {
    _movieBloc.close();
    _networkBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<MovieBloc>.value(value: _movieBloc),
        BlocProvider<NetworkBloc>.value(value: _networkBloc),
      ],
      child: MaterialApp(
        navigatorKey: _navigatorKey,
        title: 'TmDB Movies - Hitik',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blue,
          brightness: Brightness.dark,
          scaffoldBackgroundColor: const Color(0xFF0E1116),
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFF161B22),
            elevation: 0,
            centerTitle: true,
          ),
          bottomNavigationBarTheme: const BottomNavigationBarThemeData(
            backgroundColor: Color(0xFF161B22),
            selectedItemColor: Colors.blue,
            unselectedItemColor: Colors.grey,
          ),
        ),
        home: DeepLinkHandler(
          navigatorKey: _navigatorKey,
          movieBloc: _movieBloc,
          child: const HomePage(),
        ),
      ),
    );
  }
}
