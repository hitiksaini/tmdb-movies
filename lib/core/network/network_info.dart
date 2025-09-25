import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../constants/api_constants.dart';

abstract class NetworkInfo {
  Future<bool> get isConnected;
}

class NetworkInfoImpl implements NetworkInfo {
  final Connectivity connectivity;
  DateTime? _lastCheck;
  bool _lastResult = false;

  NetworkInfoImpl(this.connectivity);

  @override
  Future<bool> get isConnected async {
    final now = DateTime.now();
    if (_lastCheck != null &&
        now.difference(_lastCheck!) < const Duration(seconds: 5)) {
      return _lastResult;
    }

    final result = await connectivity.checkConnectivity();
    if (result == ConnectivityResult.none) {
      _lastResult = false;
      _lastCheck = now;
      return false;
    }

    try {
      final lookup = await InternetAddress.lookup(ApiConstants.apiHost);
      if (lookup.isEmpty || lookup.first.rawAddress.isEmpty) {
        _lastResult = false;
        _lastCheck = now;
        return false;
      }

      final client = HttpClient()
        ..connectionTimeout = const Duration(seconds: 5);
      try {
        final uri = Uri.https(ApiConstants.apiHost, '/3/configuration', {
          ApiConstants.apiKeyParam: ApiConstants.apiKey,
        });
        final request = await client.getUrl(uri);
        request.headers.set(HttpHeaders.acceptHeader, 'application/json');
        final response = await request.close();
        await response.drain();
        _lastResult = response.statusCode >= 200 && response.statusCode < 500;
      } finally {
        client.close(force: true);
      }
    } on SocketException {
      _lastResult = false;
    } catch (_) {
      _lastResult = false;
    }

    _lastCheck = DateTime.now();
    return _lastResult;
  }
}
