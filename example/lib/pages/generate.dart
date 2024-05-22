import 'package:flutter/material.dart';
import 'package:skgl_flutter_example/resources/colors.dart';
import 'package:skgl_flutter_example/utils/extension.dart';
import 'package:skgl_flutter_example/utils/row_spacer.dart';
import 'package:skgl_flutter_example/widgets/feature_select_chip.dart';
import 'package:skgl_flutter/skgl_flutter.dart';

class GeneratePage extends StatefulWidget {
  const GeneratePage({super.key});

  @override
  State<GeneratePage> createState() => _GeneratePageState();
}

class _GeneratePageState extends State<GeneratePage> with RestorationMixin {
  final _secretController = TextEditingController();
  final _expiryDateController = TextEditingController();
  final _keyCountController = TextEditingController();
  final _resultTextController = TextEditingController();
  Set<int> _features = {};
  bool _isChunked = true;

  @override
  String? get restorationId => 'generate';

  final _expiryDate = RestorableDateTime(DateTime.now().add(const Duration(days: 7)));
  late final _restorableDatePickerRouteFuture = RestorableRouteFuture<DateTime?>(
    onComplete: _selectDate,
    onPresent: (NavigatorState navigator, Object? arguments) {
      return navigator.restorablePush(
        _datePickerRoute,
        arguments: _expiryDate.value.millisecondsSinceEpoch,
      );
    },
  );

  @pragma('vm:entry-point')
  static Route<DateTime> _datePickerRoute(BuildContext context, Object? arguments) {
    return DialogRoute<DateTime>(
      context: context,
      builder: (BuildContext context) {
        return DatePickerDialog(
          restorationId: 'date_picker_dialog',
          initialEntryMode: DatePickerEntryMode.calendarOnly,
          initialDate: DateTime.fromMillisecondsSinceEpoch(arguments! as int),
          firstDate: DateTime.now(),
          lastDate: DateTime.now().add(const Duration(days: 999)),
        );
      },
    );
  }

  @override
  void restoreState(RestorationBucket? oldBucket, bool initialRestore) {
    registerForRestoration(_expiryDate, 'selected_date');
    registerForRestoration(_restorableDatePickerRouteFuture, 'date_picker_route_future');
  }

  void _selectDate(DateTime? newSelectedDate) {
    if (newSelectedDate != null) {
      setState(() => _expiryDate.value = newSelectedDate);
    }
  }

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _expiryDateController.text = _expiryDate.value.toDate();
      _keyCountController.text = '1';
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Flex(
        direction: context.isPlatformMobile() ? Axis.vertical : Axis.horizontal,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Flexible(
            child: Table(
              defaultVerticalAlignment: TableCellVerticalAlignment.middle,
              columnWidths: const {
                0: FlexColumnWidth(1),
                1: FlexColumnWidth(2),
              },
              children: [
                TableRow(
                  children: [
                    const Text('Secret'),
                    TextField(controller: _secretController),
                  ],
                ),
                RowSpacer.two(),
                TableRow(
                  children: [
                    const Text('Expiry date'),
                    TextField(
                      readOnly: true,
                      controller: _expiryDateController,
                      decoration: const InputDecoration(
                        suffixIconConstraints: BoxConstraints(),
                        suffixIcon: Padding(
                          padding: EdgeInsets.only(right: 10),
                          child: Icon(Icons.calendar_month, color: Colors.black54),
                        ),
                      ),
                      onTap: () {
                        _restorableDatePickerRouteFuture.present();
                      },
                    ),
                  ],
                ),
                RowSpacer.two(),
                TableRow(
                  children: [
                    const Text('Features'),
                    FeatureSelectChip(
                      items: List.generate(8, (index) => index + 1).toSet(),
                      onSelectionChanged: (features) {
                        setState(() => _features = features);
                      },
                    ),
                  ],
                ),
                RowSpacer.two(),
                TableRow(
                  children: [
                    const Text('# of keys'),
                    TextField(controller: _keyCountController),
                  ],
                ),
                RowSpacer.two(),
                TableRow(
                  children: [
                    const Text('Options'),
                    CheckboxListTile(
                      dense: true,
                      title: const Text('Chunked'),
                      value: _isChunked,
                      contentPadding: EdgeInsets.zero,
                      onChanged: (chunked) {
                        if (chunked == null) return;
                        setState(() => _isChunked = chunked);
                      },
                      controlAffinity: ListTileControlAffinity.leading,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ],
                ),
                RowSpacer.two(),
                TableRow(
                  children: [
                    const SizedBox.shrink(),
                    Align(
                      alignment: Alignment.centerRight,
                      child: ElevatedButton(
                        onPressed: _generate,
                        style: ElevatedButton.styleFrom(
                          foregroundColor: whiteBackgroundColor,
                          backgroundColor: primaryColor,
                        ),
                        child: const Text('Generate'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          context.isPlatformMobile() ? const SizedBox(height: 16) : const SizedBox(width: 16),
          Flexible(
            child: TextField(
              controller: _resultTextController,
              minLines: null,
              maxLines: null,
              expands: true,
              keyboardType: TextInputType.multiline,
              textAlignVertical: TextAlignVertical.top,
              decoration: const InputDecoration(
                filled: true,
                fillColor: Colors.white,
                hintStyle: TextStyle(overflow: TextOverflow.visible),
                border: OutlineInputBorder(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _generate() {
    final keyCount = int.tryParse(_keyCountController.text) ?? 1;
    _resultTextController.text = List.generate(keyCount, (index) {
      return SerialKey.build(_secretController.text,
          config: SerialKeyBuildConfig(
            duration: _calculateDaysUntilExpiry(_expiryDate.value),
            features: _features,
            chunk: _isChunked,
          )).text;
    }).join('\n');
  }

  /// https://stackoverflow.com/a/67679455/5280371
  int _calculateDaysUntilExpiry(DateTime expiryDate) {
    expiryDate = DateUtils.dateOnly(expiryDate);
    return expiryDate.difference(DateUtils.dateOnly(DateTime.now())).inDays;
  }
}
