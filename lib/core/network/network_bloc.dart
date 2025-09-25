import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

abstract class NetworkEvent {}

class NetworkObserveEvent extends NetworkEvent {}
class NetworkNotifyEvent extends NetworkEvent {
  final bool isConnected;
  NetworkNotifyEvent(this.isConnected);
}

class NetworkState {
  final bool isConnected;
  const NetworkState({required this.isConnected});
}

class NetworkBloc extends Bloc<NetworkEvent, NetworkState> {
  final Connectivity connectivity;
  StreamSubscription? _subscription;

  NetworkBloc(this.connectivity) : super(const NetworkState(isConnected: true)) {
    on<NetworkObserveEvent>(_onObserve);
    on<NetworkNotifyEvent>(_onNotify);
    add(NetworkObserveEvent());
  }

  Future<void> _onObserve(NetworkObserveEvent event, Emitter<NetworkState> emit) async {
    _subscription?.cancel();
    _subscription = connectivity.onConnectivityChanged.listen((result) {
      add(NetworkNotifyEvent(result != ConnectivityResult.none));
    });

    final result = await connectivity.checkConnectivity();
    add(NetworkNotifyEvent(result != ConnectivityResult.none));
  }

  void _onNotify(NetworkNotifyEvent event, Emitter<NetworkState> emit) {
    emit(NetworkState(isConnected: event.isConnected));
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}

