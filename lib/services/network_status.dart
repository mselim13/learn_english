import 'dart:async';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';

class NetworkStatus {
  NetworkStatus._();

  static final Connectivity _connectivity = Connectivity();

  /// Best-effort: checks connectivity type + a DNS lookup.
  static Future<bool> isOnline() async {
    final result = await _connectivity.checkConnectivity();
    if (result.contains(ConnectivityResult.none)) return false;
    try {
      final r = await InternetAddress.lookup('example.com')
          .timeout(const Duration(seconds: 2));
      return r.isNotEmpty && r.first.rawAddress.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  /// Emits online/offline changes (debounced by DNS lookup).
  static Stream<bool> onlineStream({Duration debounce = const Duration(milliseconds: 350)}) {
    late StreamController<bool> controller;
    Timer? timer;
    bool? last;
    StreamSubscription<List<ConnectivityResult>>? sub;

    Future<void> emit() async {
      final v = await isOnline();
      if (v == last) return;
      last = v;
      controller.add(v);
    }

    controller = StreamController<bool>.broadcast(
      onListen: () async {
        await emit();
        sub = _connectivity.onConnectivityChanged.listen((_) {
          timer?.cancel();
          timer = Timer(debounce, () {
            emit();
          });
        });
      },
      onCancel: () {
        timer?.cancel();
        timer = null;
        sub?.cancel();
        sub = null;
      },
    );

    return controller.stream;
  }
}

