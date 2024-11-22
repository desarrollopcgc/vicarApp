import 'package:about/about.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:package_info_plus/package_info_plus.dart';

class AboutAppScreen extends StatefulWidget {
  const AboutAppScreen({super.key});

  @override
  State<AboutAppScreen> createState() => _AboutAppScreenState();
}

class _AboutAppScreenState extends State<AboutAppScreen> {
  String version = '';
  String buildNumber = ' ';
  String year = DateTime.now().year.toString();
  String author = 'PC Grupo Consultor S.A.S';

  @override
  void initState() {
    super.initState();
    _initPackageInfo();
  }

  Future<void> _initPackageInfo() async {
    final PackageInfo info = await PackageInfo.fromPlatform();
    setState(() {
      version = info.version;
      buildNumber = info.buildNumber;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background image layer
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/pcbackground.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Stack(children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 0),
              child: AboutPage(
                values: {
                  'version': version,
                  'buildNumber': buildNumber,
                  'year': year,
                  'author': author,
                },
                title: const Text(
                  'Acerca de',
                  style: TextStyle(fontFamily: 'Poppins'),
                ),
                applicationVersion:
                    'Version {{ version }} - Build #{{ buildNumber }}',
                applicationDescription: const Text(
                  'EmcoApp, aplicación diseñada para facilitar la experiencia de nuestros clientes y empleados. Los clientes pueden acceder a nuestro catálogo, solicitar cotizaciones y obtener información sobre nuestros productos de manera rápida y eficiente. Los empleados, por su parte, encontrarán una plataforma para mantenerse informados sobre políticas, documentos y certificaciones.',
                  textAlign: TextAlign.justify,
                ),
                applicationIcon:
                    Image.asset('assets/images/vicarback2.jpg', height: 150),
                applicationLegalese: 'Copyright © {{ author }}, {{ year }}',
                children: <Widget>[
                  /*
                  const MarkdownPageListTile(
                    filename: 'README.md',
                    title: Text('View Readme'),
                    icon: Icon(Icons.all_inclusive),
                  ),
                  const MarkdownPageListTile(
                    filename: 'CHANGELOG.md',
                    title: Text('View Changelog'),
                    icon: Icon(Icons.view_list),
                  ),
                  const MarkdownPageListTile(
                    filename: 'LICENSE.md',
                    title: Text('View License'),
                    icon: Icon(Icons.description),
                  ),
                  const MarkdownPageListTile(
                    filename: 'CONTRIBUTING.md',
                    title: Text('Contributing'),
                    icon: Icon(Icons.share),
                  ),
                  const MarkdownPageListTile(
                    filename: 'CODE_OF_CONDUCT.md',
                    title: Text('Code of conduct'),
                    icon: Icon(Icons.sentiment_satisfied),
                  ),
                  const LicensesPageListTile(
                    title: Text('Open source Licenses'),
                    icon: Icon(Icons.favorite),
                  ),*/
                  const SizedBox(height: 100), // Space between columns
                  GestureDetector(
                    onTap: _openPCGCWeb,
                    child: Image.asset(
                      'assets/images/pcpowered.png',
                      height: 92,
                      fit: BoxFit.contain,
                    ),
                  ),
                ],
              ),
            ),
          ]),
        ],
      ),
    );
  }
}

//Navigate to PCGC web
_openPCGCWeb() async {
  final Uri url = Uri.parse('https://pcgrupoconsultor.com.co/');
  if (!await launchUrl(url)) {
    throw Exception('No se pudo abrir $url');
  }
}
