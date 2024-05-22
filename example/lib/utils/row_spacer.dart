import 'package:flutter/material.dart';

class RowSpacer extends TableRow {
  final int cellCount;

  RowSpacer._({required this.cellCount})
      : super(children: List.generate(cellCount, (_) => const SizedBox(height: 8)));

  factory RowSpacer.one() => RowSpacer._(cellCount: 1);
  factory RowSpacer.two() => RowSpacer._(cellCount: 2);
  factory RowSpacer.three() => RowSpacer._(cellCount: 3);
}
