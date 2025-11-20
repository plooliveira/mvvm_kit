import 'package:flutter/foundation.dart';

void debugLog(String message, {bool ifTrue = true}) {
  if (kDebugMode && ifTrue) {
    debugPrint(message);
  }
}
