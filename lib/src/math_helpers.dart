class MathHelpers {
  static const String BASE26_CHARS = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";
  static final BigInt BIGINTEGER_26 = BigInt.from(26);

  static int modulo(int n, int base) {
    return n - (base * (n / base).floor());
  }

  static int modulo10(int n) {
    return modulo(n, 10);
  }

  static String base10To26(BigInt n) {
    var sb = StringBuffer();

    BigInt rem;
    var num = n;
    while (num >= BIGINTEGER_26) {
      rem = num % BIGINTEGER_26;
      sb.write(BASE26_CHARS[rem.toInt()]);
      num = (num - rem) ~/ BIGINTEGER_26;
    }
    sb.write(BASE26_CHARS[num.toInt()]);

    return sb.toString().split('').reversed.join();
  }

  static BigInt base26To10(String s) {
    var res = BigInt.zero;
    for (int i = 0; i < s.length; i++) {
      BigInt p = BIGINTEGER_26.pow(s.length - i - 1);
      res += p * BigInt.from(BASE26_CHARS.indexOf(s[i]));
    }
    return res;
  }

  static String hash25(String s) {
    if (s.isEmpty) {
      throw ArgumentError('String to be hashed is empty.');
    }

    var nBlocks = s.length ~/ 5;
    var hash = '';
    if (s.length <= 5) {
      hash = hash8(s);
    } else {
      for (int i = 0; i < nBlocks; i++) {
        hash += hash8(i == nBlocks - 1 ? s.substring((nBlocks - 1) * 5) : s.substring(i * 5, (i * 5) + 5));
      }
    }
    return hash;
  }

  static String hash8(String s, {int exclusiveUpperLimit = 1000000000}) {
    if (s.isEmpty) {
      throw ArgumentError('String to be hashed is empty.');
    }

    var hash = 0;

    final buf = s.codeUnits;
    for (var byte in buf) {
      hash += byte;
      hash += hash << 10;
      hash ^= (hash >> 6);
    }

    hash += hash << 3;
    hash ^= (hash >> 11);
    hash += hash << 15;

    final lHash = hash & 0xFFFFFFFF;

    var res = lHash % exclusiveUpperLimit;
    if (res == 0) {
      res = 1;
    }

    var check = exclusiveUpperLimit ~/ res;
    if (check > 1) {
      res *= check;
    }

    if (exclusiveUpperLimit == res) {
      res ~/= 10;
    }

    return res.toString();
  }
}