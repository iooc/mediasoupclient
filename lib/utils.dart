import 'dart:convert';

import 'dart:math' as Math;

clone(data, defaultValue) {
  // if (typeof data === 'undefined')
  // 	return defaultValue;

  return jsonDecode(jsonEncode(data));
}

/// Generates a random positive integer.
int generateRandomNumber() {
  return Math.Random().nextInt(10000000);
}
