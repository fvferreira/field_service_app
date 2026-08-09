import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityService {
  final Connectivity _connectivity = Connectivity();

  StreamSubscription<List<ConnectivityResult>>? _subscription;

  void startListening(Future<void> Function() onConnected) {
    _subscription = _connectivity.onConnectivityChanged.listen((results) async {
      final hasConnection = results.any(
        (result) => result != ConnectivityResult.none,
      );

      if (hasConnection) {
        await onConnected();
      }
    });
  }

  Future<void> dispose() async {
    await _subscription?.cancel();
  }
}
