import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as parser;
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../utils/file_helper.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as p;


class DocsPage extends StatefulWidget {

  final String sciezka;

  DocsPage({this.sciezka = ""}); // domyślnie root

  @override
  _DocsPageState createState() => _DocsPageState();
}

String normalizePath(String path) {
  return path.replaceAll(RegExp(r'^/+'), '').replaceAll(RegExp(r'/+$'), '') + '/'; // usuwa / z początku i końca
}

class _DocsPageState extends State<DocsPage> {
  List<String> pliki = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    pobierzPliki();
  }

  Future<void> pobierzPliki() async {
    final response = await http.get(
      Uri.parse("https://www.cam-sat.pl/docs/${normalizePath(widget.sciezka)}"),
    );

    if (response.statusCode == 200) {
      final document = parser.parse(response.body);
      final wiersze = document.querySelectorAll('table tr');
      final List<String> folders = [];
      final List<String> files = [];

      for (var wiersz in wiersze) {
        final link = wiersz.querySelector('td a');
        if (link != null) {
          final href = link.attributes['href'];
          if (href != null &&
              !href.startsWith('?') &&
              href != '/' &&
              href != '../' &&
              href != '/docs/') {
            if (href.endsWith('/')) {
              folders.add(href);
            } else {
              files.add(href);
            }
          }
        }
      }

      folders.sort();
      files.sort();

      setState(() {
        pliki = [...folders, ...files];
        loading = false;
      });
    } else {
      setState(() {
        loading = false;
      });
    }
  }

  // 👇 To jest dobrze umieszczony dodajPlik()
  Future<void> dodajPlik() async {
    final result = await FilePicker.platform.pickFiles();

    if (result != null && result.files.single.path != null) {
      final file = result.files.single;
      final uri = Uri.parse('https://www.cam-sat.pl/push/upload_file.php');
      final request = http.MultipartRequest('POST', uri);

      request.files.add(await http.MultipartFile.fromPath(
        'plik',
        file.path!,
        filename: p.basename(file.path!),
      ));

      request.fields['sciezka'] = normalizePath(widget.sciezka);

      final response = await request.send();

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("✅ Plik dodany!"),
        ));
        pobierzPliki();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("❌ Błąd podczas dodawania pliku"),
        ));
      }
    }
  }

  void otworzPlik(String nazwa) async {
    final url = "https://www.cam-sat.pl/docs/${normalizePath(widget.sciezka)}$nazwa";
    await otworzPlikZUrl(context, url);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.sciezka.isEmpty
            ? "Dokumenty"
            : "📁 ${widget.sciezka.split('/').where((e) => e.isNotEmpty).last}"),
        actions: [
          IconButton(
            icon: Icon(Icons.upload_file),
            onPressed: dodajPlik,
            tooltip: 'Dodaj plik',
          ),
        ],
      ),
      body: loading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: pliki.length,
              itemBuilder: (context, index) {
                final nazwa = pliki[index];
                final isFolder = nazwa.endsWith('/');
                final nazwaWidoczna =
                    Uri.decodeFull(isFolder ? nazwa.replaceAll('/', '') : nazwa);

                IconData ikona;
                if (isFolder) {
                  ikona = FontAwesomeIcons.folderOpen;
                } else if (nazwa.endsWith('.pdf')) {
                  ikona = FontAwesomeIcons.filePdf;
                } else if (nazwa.endsWith('.doc') || nazwa.endsWith('.docx')) {
                  ikona = FontAwesomeIcons.fileWord;
                } else if (nazwa.endsWith('.xls') || nazwa.endsWith('.xlsx')) {
                  ikona = FontAwesomeIcons.fileExcel;
                } else if (nazwa.endsWith('.jpg') ||
                    nazwa.endsWith('.jpeg') ||
                    nazwa.endsWith('.png')) {
                  ikona = FontAwesomeIcons.fileImage;
                } else if (nazwa.endsWith('.zip') ||
                    nazwa.endsWith('.rar') ||
                    nazwa.endsWith('.7z')) {
                  ikona = FontAwesomeIcons.fileZipper;
                } else if (nazwa.endsWith('.exe') || nazwa.endsWith('.apk')) {
                  ikona = FontAwesomeIcons.fileCode;
                } else {
                  ikona = FontAwesomeIcons.fileLines;
                }

                return ListTile(
                  leading: FaIcon(
                    ikona,
                    color: isFolder ? Colors.orangeAccent : Colors.indigo,
                    size: 28,
                  ),
                  title: Text(nazwaWidoczna),
                  subtitle: isFolder ? Text("Folder") : null,
                  onTap: () {
                    if (isFolder) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DocsPage(
                            sciezka: widget.sciezka + nazwa,
                          ),
                        ),
                      );
                    } else {
                      otworzPlik(nazwa);
                    }
                  },
                );
              },
            ),
    );
  }
}

