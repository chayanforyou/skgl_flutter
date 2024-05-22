import 'package:intl/intl.dart';

import 'math_helpers.dart';

class SerialKeyHelpers {
  static final DateFormat DATE_FORMATTER = DateFormat('yyyyMMdd');

  static String decode(String key, String secret) {
    final info = MathHelpers.base26To10(key).toString();

    if (secret.isEmpty) {
      return info;
    } else {
      final slice = info.substring(9);
      final secretHash25 = MathHelpers.hash25(secret);

      var decodedSlice = '';
      for (int i = 0; i < slice.length; i++) {
        int n = int.parse(slice[i]) - int.parse(secretHash25[MathHelpers.modulo(i, secretHash25.length)]);
        decodedSlice += MathHelpers.modulo10(n).toString();
      }

      return info.substring(0, 9) + decodedSlice;
    }
  }

  static String encode(String secret, DateTime createdOn, int duration, Set<int> features, int r) {
    var result = 0;

    result += int.parse(DATE_FORMATTER.format(createdOn));
    result *= 1000;

    result += duration;
    result *= 1000;

    result += features.fold(0, (acc, n) => acc | (1 << (8 - n)));
    result *= 100000;

    result += r;

    final resultHash = MathHelpers.hash8(result.toString());
    final resultString = result.toString();

    if (secret.isEmpty) {
      return MathHelpers.base10To26(BigInt.parse(resultHash + resultString));
    } else {
      String secretHash = MathHelpers.hash25(secret);
      StringBuffer slice = StringBuffer();

      for (int i = 0; i < resultString.length; i++) {
        int resultPart = int.parse(resultString[i]);
        int secretPart = int.parse(secretHash[MathHelpers.modulo(i, secretHash.length)]);
        slice.write(MathHelpers.modulo10(resultPart + secretPart));
      }
      return MathHelpers.base10To26(BigInt.parse(resultHash + slice.toString()));
    }
  }
}