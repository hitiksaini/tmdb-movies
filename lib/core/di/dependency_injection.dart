import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../network/network_info.dart';

final GetIt getIt = GetIt.instance;

Future<void> setupDependencyInjection() async {
  // External dependencies
  getIt.registerLazySingleton(() => Dio());
  getIt.registerLazySingleton(() => Connectivity());

  // Core
  getIt.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl(getIt()));
}
