import 'package:connectivity_plus/connectivity_plus.dart';

/// Abstraction de la vérification de connectivité, pour pouvoir
/// être mockée facilement dans les tests des repositories.
abstract class NetworkInfo {
  Future<bool> get isConnected;
}

class NetworkInfoImpl implements NetworkInfo {
  const NetworkInfoImpl(this._connectivity);

  final Connectivity _connectivity;

  @override
  Future<bool> get isConnected async {
    final result = await _connectivity.checkConnectivity();
    return !result.contains(ConnectivityResult.none);
  }
}
