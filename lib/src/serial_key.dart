import 'dart:math';

import 'math_helpers.dart';
import 'serial_key_helpers.dart';

class SerialKey {
  final String text;
  final int duration;
  final DateTime createdOn;
  final Set<int> features;

  SerialKey._(this.text, this.duration, this.createdOn, this.features);

  factory SerialKey(String key, [String secret = '']) {
    if (!RegExp(r'[a-z]{5}-?[a-z]{5}-?[a-z]{5}-?[a-z]{5}', caseSensitive: false).hasMatch(key)) {
      throw InvalidSerialKeyException();
    }

    final leanKey = key.replaceAll('-', '').toUpperCase();
    final decoded = SerialKeyHelpers.decode(leanKey, secret);

    final decodedHash8 = decoded.substring(0, 9);
    final calculatedHash8 = MathHelpers.hash8(decoded.substring(9, 9 + 19)).substring(0, 9);

    if (decodedHash8 != calculatedHash8) {
      throw InvalidSerialKeyException();
    }

    final duration = int.parse(decoded.substring(17, 17 + 3));
    final createdOn = DateTime.parse(decoded.substring(9, 9 + 8));
    final featureInt = int.parse(decoded.substring(20, 20 + 3));
    final features =
        List.generate(8, (index) => index).where((i) => (featureInt & (1 << (7 - i))) != 0).map((i) => i + 1).toSet();

    return SerialKey._(key, duration, createdOn, features);
  }

  static SerialKey build(String secret, {SerialKeyBuildConfig? config}) {
    config ??= SerialKeyBuildConfig();

    final r = Random().nextInt(100000);
    final key = SerialKeyHelpers.encode(secret, config.createdOn, config.duration, config.features, r);

    return SerialKey._(config.chunk ? _chunkString(key, 5) : key, config.duration, config.createdOn, config.features);
  }

  static String _chunkString(String input, int chunkSize) {
    String chunks = input.replaceAllMapped(RegExp('.{$chunkSize}'), (match) => '${match.group(0)}-');
    return chunks.substring(0, chunks.length - 1);
  }

  DateTime get expiresOn => createdOn.add(Duration(days: duration));

  bool calculateIsExpired({DateTime? relativeTo}) {
    relativeTo ??= DateTime.now();
    return relativeTo.isAfter(expiresOn);
  }

  int calculateDaysLeft({DateTime? relativeTo}) {
    relativeTo ??= DateTime.now();
    final from = DateTime(relativeTo.year, relativeTo.month, relativeTo.day);
    final to = DateTime(expiresOn.year, expiresOn.month, expiresOn.day);
    return to.difference(from).inDays;
  }

  @override
  String toString() {
    return 'SerialKey(key: $text, duration: $duration, createdOn: $createdOn, features: $features)';
  }
}

class InvalidSerialKeyException implements Exception {
  final String message;

  InvalidSerialKeyException({String? message}) : message = message ?? 'The specified key is invalid.';
}

class SerialKeyBuildConfig {
  final int duration;
  final DateTime createdOn;
  final Set<int> features;
  final bool chunk;

  SerialKeyBuildConfig({
    Set<int>? features,
    DateTime? createdOn,
    this.duration = 30,
    this.chunk = true,
  })  : features = features ?? {},
        createdOn = createdOn ?? DateTime.now() {

    assert(duration >= 0 && duration <= 999, 'The duration of a license key should be in the range 0..999');
    assert(!this.features.any((feature) => feature < 1 || feature > 8), 'Features are expected to be in the range 1..8');
  }
}
