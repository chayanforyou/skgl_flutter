import 'package:flutter/material.dart';
import 'package:skgl_flutter/skgl_flutter.dart';
import 'package:skgl_flutter_example/resources/colors.dart';
import 'package:skgl_flutter_example/utils/extension.dart';
import 'package:skgl_flutter_example/utils/row_spacer.dart';
import 'package:skgl_flutter_example/widgets/feature_select_chip.dart';

class ValidatePage extends StatefulWidget {
  const ValidatePage({super.key});

  @override
  State<ValidatePage> createState() => _ValidatePageState();
}

class _ValidatePageState extends State<ValidatePage> {
  final _keyController = TextEditingController();
  final _secretController = TextEditingController();
  final _durationController = TextEditingController();
  final _createdOnController = TextEditingController();
  final _expiresOnController = TextEditingController();
  final _daysLeftController = TextEditingController();
  bool _isExpired = false;
  Set<int> _features = {};
  bool _isValid = true;
  String _message = "Enter the serial key & secret via the controls on the left an hit \"Validate\"";

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Flex(
        direction: context.isPlatformMobile() ? Axis.vertical : Axis.horizontal,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Flexible(
            flex: 2,
            child: Table(
              defaultVerticalAlignment: TableCellVerticalAlignment.middle,
              columnWidths: const {
                0: FlexColumnWidth(1),
                1: FlexColumnWidth(2),
              },
              children: [
                TableRow(
                  children: [
                    const Text('Key'),
                    TextField(controller: _keyController),
                  ],
                ),
                RowSpacer.two(),
                TableRow(
                  children: [
                    const Text('Secret'),
                    TextField(controller: _secretController),
                  ],
                ),
                RowSpacer.two(),
                TableRow(
                  children: [
                    const SizedBox.shrink(),
                    Align(
                      alignment: Alignment.centerRight,
                      child: ElevatedButton(
                        onPressed: _validate,
                        style: ElevatedButton.styleFrom(
                          foregroundColor: whiteBackgroundColor,
                          backgroundColor: primaryColor,
                        ),
                        child: const Text('Validate'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          context.isPlatformMobile() ? const SizedBox(height: 16) : const SizedBox(width: 16),
          Flexible(
            flex: 3,
            child: Column(
              children: [
                IconButton(
                  onPressed: () {},
                  icon: _isValid ? const Icon(Icons.check) : const Icon(Icons.close),
                ),
                const SizedBox(height: 10),
                Text(
                  _message,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Visibility(
                  visible: _isValid,
                  child: Table(
                    defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                    columnWidths: const {
                      0: FlexColumnWidth(1),
                      1: FlexColumnWidth(2),
                      2: FlexColumnWidth(0.4),
                    },
                    children: [
                      TableRow(
                        children: [
                          const Text('Duration'),
                          TextField(
                            readOnly: true,
                            controller: _durationController,
                          ),
                          const Align(child: Text('days')),
                        ],
                      ),
                      RowSpacer.three(),
                      TableRow(
                        children: [
                          const Text('Created on'),
                          TextField(
                            readOnly: true,
                            controller: _createdOnController,
                            decoration: const InputDecoration(
                              suffixIconConstraints: BoxConstraints(),
                              suffixIcon: Padding(
                                padding: EdgeInsets.only(right: 10),
                                child: Icon(Icons.calendar_month, color: Colors.black54),
                              ),
                            ),
                          ),
                          const SizedBox.shrink(),
                        ],
                      ),
                      RowSpacer.three(),
                      TableRow(
                        children: [
                          const Text('Expires on'),
                          TextField(
                            readOnly: true,
                            controller: _expiresOnController,
                            decoration: const InputDecoration(
                              suffixIconConstraints: BoxConstraints(),
                              suffixIcon: Padding(
                                padding: EdgeInsets.only(right: 10),
                                child: Icon(Icons.calendar_month, color: Colors.black54),
                              ),
                            ),
                          ),
                          const SizedBox.shrink(),
                        ],
                      ),
                      RowSpacer.three(),
                      TableRow(
                        children: [
                          const Text('Days left'),
                          TextField(
                            readOnly: true,
                            controller: _daysLeftController,
                          ),
                          const Align(child: Text('days')),
                        ],
                      ),
                      RowSpacer.three(),
                      TableRow(
                        children: [
                          const Text('Is expired'),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Checkbox(
                              value: _isExpired,
                              onChanged: (_) {},
                              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                          ),
                          const SizedBox.shrink(),
                        ],
                      ),
                      RowSpacer.three(),
                      TableRow(
                        children: [
                          const Text('Features'),
                          FeatureSelectChip(
                            readonly: true,
                            initialItems: _features,
                            items: List.generate(8, (index) => index + 1).toSet(),
                          ),
                          const SizedBox.shrink(),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _validate() {
    try {
      final serial = SerialKey(_keyController.text, _secretController.text);
      _durationController.text = serial.duration.toString();
      _createdOnController.text = serial.createdOn.toDate();
      _expiresOnController.text = serial.expiresOn.toDate();
      _daysLeftController.text = serial.calculateDaysLeft().toString();
      setState(() {
        _features = serial.features;
        _isExpired = serial.calculateIsExpired();

        _isValid = true;
        _message = 'The specified key is valid';
      });
    } on InvalidSerialKeyException catch (e) {
      setState(() {
        _isValid = false;
        _message = '${e.runtimeType}: ${e.message}';
      });
    }
  }
}
