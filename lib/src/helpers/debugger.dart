import 'package:flutter/foundation.dart';

void debugLog(String message, {bool condition = true}) {
  if (kDebugMode && condition) {
    debugPrint(message);
  }
}
