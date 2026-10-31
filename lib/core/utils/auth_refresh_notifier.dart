import 'dart:async';

import 'package:flutter/foundation.dart';

/// Tells the router to re-check its redirect rules whenever the login state
/// changes (user logs in or out).
class AuthRefreshNotifier extends ChangeNotifier {
  AuthRefreshNotifier(Stream<dynamic> stream) {
    _subscription = stream.listen((_) => notifyListeners());
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
