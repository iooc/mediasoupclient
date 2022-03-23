import 'dart:convert';

import 'dart:math' as math;

clone(data, defaultValue) {
  // if (typeof data === 'undefined')
  // 	return defaultValue;

  return jsonDecode(jsonEncode(data));
}

/// Generates a random positive integer.
int generateRandomNumber() {
  return math.Random().nextInt(10000000);
}

extension ListExtension<T> on List<T> {
  T? firstWhereOrNull(bool Function(T element) test) {
    for (var element in this) {
      if (test(element)) return element;
    }
    return null;
  }
}
