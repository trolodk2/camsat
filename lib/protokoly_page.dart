import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';
import 'dodaj_protokol_page.dart'; // to zara trza zrobic

class Protokol {
  final int id;
  final String numer;
  final String data;
  final String pdfPath;

  Protokol({required this.id, required this.numer, required this.data, required this.pdfPath});

  factory Protokol.fromJson(Map<String, dynamic> json) {
    return Protokol(
      id: int.parse(json['id']),
      numer: json['numer_protokolu'],
      data: json['data_dodania'],
      pdfPath: json['pdf_path'] ?? '',
    );
  }
}

class ProtokolyPage extends StatefulWidget {
  @override
  _ProtokolyPageState createState() => _ProtokolyPageState();
}

class _ProtokolyPageState extends State<ProtokolyPage> {
  List<Protokol> protokoly = [];

  @override
  void initState() {
    super.initState();
    fetchProtokoly();
  }

  Future<void> fetchProtokoly() async {
    final response = await http.get(Uri.parse('https://twojastrona.pl/api_pobierz_protokoly.php'));
    if (response.statusCode == 200) {
      final List jsonList = json.decode(response.body);
      setState(() {
        protokoly = jsonList.map((e) => Protokol.fromJson(e)).toList();
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('B³¹d pobierania danych')));
    }
  }

  Future<void> openPDF(String pdfPath) async {
    final url = 'https://twojastrona.pl/uploads/pdf/$pdfPath';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Nie mo¿na otworzyæ PDF')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Protoko³y')),
      body: protokoly.isEmpty
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: protokoly.length,
              itemBuilder: (context, index) {
                final p = protokoly[index];
                return ListTile(
                  title: Text('Protokó³ nr ${p.numer}'),
                  subtitle: Text('Data: ${p.data}'),
                  trailing: Icon(Icons.picture_as_pdf),
                  onTap: () => openPDF(p.pdfPath),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final dodano = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => DodajProtokolPage()),
          );
          if (dodano == true) fetchProtokoly();
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
