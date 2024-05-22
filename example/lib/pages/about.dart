import 'package:flutter/material.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          'SKGL (flutter) UI',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 6),
        const Text(
          'Using this app to generate & validate serial keys via SKGL',
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        _linkify('https://github.com/chayanforyou/skgl_flutter'),
        _linkify('https://github.com/ravindUwU/skgl-kotlin'),
        _linkify('https://github.com/Cryptolens/SKGL'),
      ],
    );
  }
}

Widget _linkify(String text) {
  return Padding(
    padding: const EdgeInsets.only(top: 6),
    child: Linkify(
      onOpen: (link) async {
        if (!await launchUrl(Uri.parse(link.url))) {
          throw Exception('Could not launch ${link.url}');
        }
      },
      linkStyle: const TextStyle(decoration: TextDecoration.none),
      options: const LinkifyOptions(humanize: false),
      text: text,
    ),
  );
}
