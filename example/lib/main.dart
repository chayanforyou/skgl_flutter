import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_advanced_segment/flutter_advanced_segment.dart';
import 'package:skgl_flutter_example/pages/about.dart';
import 'package:skgl_flutter_example/pages/generate.dart';
import 'package:skgl_flutter_example/pages/validate.dart';
import 'package:skgl_flutter_example/resources/colors.dart';
import 'package:skgl_flutter_example/resources/themes.dart';
import 'package:window_manager/window_manager.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (!kIsWeb && (Platform.isMacOS || Platform.isWindows || Platform.isLinux)) {
    await windowManager.ensureInitialized();

    const kSize = Size(800, 480);
    WindowOptions windowOptions = const WindowOptions(
      center: true,
      skipTaskbar: false,
      fullScreen: false,
      size: kSize,
      minimumSize: kSize,
      titleBarStyle: TitleBarStyle.normal,
      title: 'SKGL (flutter) UI',
    );

    windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.show();
      await windowManager.focus();
    });
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: Themes.appTheme(context),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final _selectedSegment = ValueNotifier(0);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: ColoredBox(
                color: segmentBackgroundColor,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: AdvancedSegment(
                    controller: _selectedSegment,
                    segments: const {
                      0: 'About',
                      1: 'Generate',
                      2: 'Validate',
                    },
                    shadow: null,
                    sliderOffset: 0.0,
                    borderRadius: BorderRadius.zero,
                    sliderColor: backgroundColor,
                    backgroundColor: segmentBackgroundColor,
                  ),
                ),
              ),
            ),
            SliverFillRemaining(
              hasScrollBody: false,
              child: ValueListenableBuilder(
                valueListenable: _selectedSegment,
                builder: (_, key, __) {
                  switch (key) {
                    case 1:
                      return const GeneratePage();
                    case 2:
                      return const ValidatePage();
                    default:
                      return const AboutPage();
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
