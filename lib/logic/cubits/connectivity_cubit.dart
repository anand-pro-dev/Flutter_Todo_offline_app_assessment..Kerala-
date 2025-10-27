import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ConnectivityCubit extends Cubit<bool> {
  final Connectivity _connectivity = Connectivity();
  StreamSubscription<List<ConnectivityResult>>? _subscription;

  ConnectivityCubit() : super(true) {
    _init();
  }

  void _init() {
    // Listen to connectivity changes
    _subscription = _connectivity.onConnectivityChanged.listen((results) {
      final connected = results.isNotEmpty &&
          results.any((res) => res != ConnectivityResult.none);
      emit(connected);
    });

    // Perform initial check
    _connectivity.checkConnectivity().then((results) {
      final connected = results.isNotEmpty &&
          results.any((res) => res != ConnectivityResult.none);
      emit(connected);
    });
  }

  /// Stream to expose connectivity updates for other components (e.g., for showing banners)
  Stream<bool> get connectivityStream =>
      _connectivity.onConnectivityChanged.map(
        (results) =>
            results.isNotEmpty &&
            results.any((res) => res != ConnectivityResult.none),
      );

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
