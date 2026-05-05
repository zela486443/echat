import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum ConnectivityStatus { isConnected, isDisconnected, isChecking }

final connectivityProvider = StreamProvider<ConnectivityStatus>((ref) async* {
  final connectivity = Connectivity();
  
  // connectivity_plus 5.0.0+ returns List<ConnectivityResult>
  yield* connectivity.onConnectivityChanged.map((results) {
    if (results.contains(ConnectivityResult.none) || results.isEmpty) {
      return ConnectivityStatus.isDisconnected;
    } else {
      return ConnectivityStatus.isConnected;
    }
  });
});
