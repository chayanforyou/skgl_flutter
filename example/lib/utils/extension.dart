import 'dart:io';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

extension ContextExtensions on BuildContext {

  bool isPlatformMobile() {
    return !kIsWeb && (Platform.isAndroid || Platform.isIOS);
  }

  bool isDesktop() {
    final query = MediaQuery.of(this);
    final size = query.size;
    final diagonal = sqrt((size.width * size.width) + (size.height * size.height));
    return diagonal > 1080.0;
  }
}

extension DateTimeExtensions on DateTime {
  String toDate() {
    return DateFormat('dd/MM/yyyy').format(this);
  }
}