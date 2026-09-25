import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final connectivityProvider = NotifierProvider<ConnectivityNotifier, bool>(() {
  return ConnectivityNotifier();
});

class ConnectivityNotifier extends Notifier<bool> {
  @override
  bool build() {
    _init();
    return true;
  }

  void _init() {
    Connectivity().onConnectivityChanged.listen((results) {
      // If none of the results indicate an active connection, we are offline.
      final isOffline = results.isEmpty || results.every((r) => r == ConnectivityResult.none);
      state = !isOffline;
    });
    
    // Check initial state
    Connectivity().checkConnectivity().then((results) {
      final isOffline = results.isEmpty || results.every((r) => r == ConnectivityResult.none);
      state = !isOffline;
    });
  }
}
